import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<Marker> _allMarkers = {}; // เก็บ marker ทั้งหมด
  Set<Marker> _filteredMarkers = {}; // เก็บ marker ที่กรองแล้ว
  List<Map<String, dynamic>> _allLocations = []; // เก็บข้อมูลทั้งหมด
  String? _currentFilter; // keyword ที่เลือกอยู่
  
  LatLngBounds? _markersBounds;
  bool _isLoading = false;
  String? _errorMessage;
  LatLng? _currentLocation;

  // Getters
  Set<Marker> get markers => _currentFilter == null ? _allMarkers : _filteredMarkers;
  LatLngBounds? get markersBounds => _markersBounds;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  LatLng? get currentLocation => _currentLocation;
  String? get currentFilter => _currentFilter;

  Future<void> fetchLocations() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      await Future.microtask(() => notifyListeners());

      final querySnapshot = await _firestore.collection('locations').get();
      final Set<Marker> newMarkers = {};
      final List<Map<String, dynamic>> locations = [];
      LatLngBounds? bounds;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final lat = data['Latitude'] as double;
        final lng = data['Longitude'] as double;
        final position = LatLng(lat, lng);

        // เก็บข้อมูลสำหรับการค้นหา
        final locationData = {
          ...data,
          'docId': doc.id,
          'position': position,
        };
        locations.add(locationData);

        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: position,
          infoWindow: InfoWindow.noText,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () {
            setSelectedMarker({
              ...data,
              'docId': doc.id,
            }, position);
          },
        );
        newMarkers.add(marker);

        // คำนวณ bounds
        if (bounds == null) {
          bounds = LatLngBounds(northeast: position, southwest: position);
        } else {
          final neLat = bounds.northeast.latitude > position.latitude
              ? bounds.northeast.latitude
              : position.latitude;
          final neLng = bounds.northeast.longitude > position.longitude
              ? bounds.northeast.longitude
              : position.longitude;
          final swLat = bounds.southwest.latitude < position.latitude
              ? bounds.southwest.latitude
              : position.latitude;
          final swLng = bounds.southwest.longitude < position.longitude
              ? bounds.southwest.longitude
              : position.longitude;
          bounds = LatLngBounds(
            northeast: LatLng(neLat, neLng),
            southwest: LatLng(swLat, swLng),
          );
        }
      }

      _allMarkers = newMarkers;
      _allLocations = locations;
      _markersBounds = bounds;
      
      // ถ้ามี filter อยู่ ให้กรองใหม่
      if (_currentFilter != null) {
        _filterMarkersByKeyword(_currentFilter!);
      }
      
    } catch (e) {
      _errorMessage = 'Failed to load locations: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      await Future.microtask(() => notifyListeners());
    }
  }

  // ฟังก์ชันสำหรับกรอง markers ตาม keyword
  void filterMarkers(String? keyword) {
    if (keyword == null || keyword.isEmpty) {
      // แสดงทั้งหมด
      _currentFilter = null;
      _filteredMarkers = {};
      _calculateFilteredBounds(_allMarkers);
    } else {
      _currentFilter = keyword;
      _filterMarkersByKeyword(keyword);
    }
    notifyListeners();
  }

  void _filterMarkersByKeyword(String keyword) {
    final Set<Marker> filtered = {};
    
    for (final location in _allLocations) {
      bool matchFound = false;
      
      // ค้นหาใน fields ต่างๆ
      final searchFields = [
        location['name']?.toString() ?? '',
        location['address']?.toString() ?? '',
        location['fishs']?.toString() ?? '',
        location['season']?.toString() ?? '', // ถ้ามี field season
      ];
      
      for (final field in searchFields) {
        if (field.toLowerCase().contains(keyword.toLowerCase())) {
          matchFound = true;
          break;
        }
      }
      
      if (matchFound) {
        // สร้าง marker สำหรับข้อมูลที่ตรงกัน
        final position = location['position'] as LatLng;
        final marker = Marker(
          markerId: MarkerId(location['docId']),
          position: position,
          infoWindow: InfoWindow.noText,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange, // เปลี่ยนสีเพื่อแสดงว่ากรองแล้ว
          ),
          onTap: () {
            setSelectedMarker({
              ...location,
            }, position);
          },
        );
        filtered.add(marker);
      }
    }
    
    _filteredMarkers = filtered;
    _calculateFilteredBounds(filtered);
  }

  // คำนวณ bounds สำหรับ markers ที่กรองแล้ว
  void _calculateFilteredBounds(Set<Marker> markers) {
    if (markers.isEmpty) return;
    
    LatLngBounds? bounds;
    for (final marker in markers) {
      final position = marker.position;
      if (bounds == null) {
        bounds = LatLngBounds(northeast: position, southwest: position);
      } else {
        final neLat = bounds.northeast.latitude > position.latitude
            ? bounds.northeast.latitude
            : position.latitude;
        final neLng = bounds.northeast.longitude > position.longitude
            ? bounds.northeast.longitude
            : position.longitude;
        final swLat = bounds.southwest.latitude < position.latitude
            ? bounds.southwest.latitude
            : position.latitude;
        final swLng = bounds.southwest.longitude < position.longitude
            ? bounds.southwest.longitude
            : position.longitude;
        bounds = LatLngBounds(
          northeast: LatLng(neLat, neLng),
          southwest: LatLng(swLat, swLng),
        );
      }
    }
    _markersBounds = bounds;
  }

  // ล้างการกรอง
  void clearFilter() {
    filterMarkers(null);
  }

  // ตั้งค่าตำแหน่งปัจจุบัน
  void setCurrentLocation(LatLng location) {
    _currentLocation = location;
    notifyListeners();
  }

  // ข้อมูล Marker ที่ถูกเลือก
  Map<String, dynamic>? _selectedMarkerData;
  LatLng? _selectedMarkerPosition;

  Map<String, dynamic>? get selectedMarkerData => _selectedMarkerData;
  LatLng? get selectedMarkerPosition => _selectedMarkerPosition;

  void setSelectedMarker(Map<String, dynamic> data, LatLng position) {
    _selectedMarkerData = data;
    _selectedMarkerPosition = position;
    notifyListeners();
  }

  void clearSelectedMarker() {
    _selectedMarkerData = null;
    _selectedMarkerPosition = null;
    notifyListeners();
  }

  // สำหรับเก็บตำแหน่งของ markers บนหน้าจอ
  Map<String, Offset> _markerScreenPositions = {};
  Map<String, Offset> get markerScreenPositions => _markerScreenPositions;

  void updateMarkerScreenPosition(String markerId, Offset position) {
    _markerScreenPositions[markerId] = position;
    notifyListeners();
  }

  void clearMarkerScreenPositions() {
    _markerScreenPositions.clear();
    notifyListeners();
  }
}