import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<Marker> _markers = {};
  LatLngBounds? _markersBounds;
  bool _isLoading = false;
  String? _errorMessage;
  LatLng? _currentLocation;

  Set<Marker> get markers => _markers;
  LatLngBounds? get markersBounds => _markersBounds;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  LatLng? get currentLocation => _currentLocation;

  Future<void> fetchLocations() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      await Future.microtask(() => notifyListeners());

      final querySnapshot = await _firestore.collection('locations').get();
      final Set<Marker> newMarkers = {};
      LatLngBounds? bounds;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final lat = data['Latitude'] as double;
        final lng = data['Longitude'] as double;
        final position = LatLng(lat, lng);

        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: position,
          infoWindow: InfoWindow.noText,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () {
            setSelectedMarker({
              ...data, // copy ข้อมูลเดิม
              'docId': doc.id, // เพิ่ม docId
            }, position);
          },
        );
        newMarkers.add(marker);

        if (bounds == null) {
          bounds = LatLngBounds(northeast: position, southwest: position);
        } else {
          final neLat =
              bounds.northeast.latitude > position.latitude
                  ? bounds.northeast.latitude
                  : position.latitude;
          final neLng =
              bounds.northeast.longitude > position.longitude
                  ? bounds.northeast.longitude
                  : position.longitude;
          final swLat =
              bounds.southwest.latitude < position.latitude
                  ? bounds.southwest.latitude
                  : position.latitude;
          final swLng =
              bounds.southwest.longitude < position.longitude
                  ? bounds.southwest.longitude
                  : position.longitude;
          bounds = LatLngBounds(
            northeast: LatLng(neLat, neLng),
            southwest: LatLng(swLat, swLng),
          );
        }
      }

      _markers = newMarkers;
      _markersBounds = bounds;
    } catch (e) {
      _errorMessage = 'Failed to load locations: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      await Future.microtask(() => notifyListeners());
    }
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

  // 🔹 ฟังก์ชัน getPlaceId
  Future<String?> getPlaceId(double lat, double lng) async {
    final String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['place_id'];
        } else {
          debugPrint(
            'Google API error: ${data['status']} ${data['error_message'] ?? ''}',
          );
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in getPlaceId: $e');
    }
    return null;
  }

  // 🔹 ฟังก์ชัน getPlaceId และ update Firestore
  Future<String?> getPlaceIdAndUpdateFirestore(
    String docId,
    double lat,
    double lng,
  ) async {
    final String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final placeId = data['results'][0]['place_id'];

          // อัปเดตลง Firestore
          await _firestore.collection('locations').doc(docId).update({
            'place_id': placeId,
          });

          // อัปเดต selectedMarkerData ถ้าเป็น marker ปัจจุบัน
          if (_selectedMarkerData != null &&
              _selectedMarkerPosition != null &&
              _selectedMarkerData!['docId'] == docId) {
            _selectedMarkerData!['place_id'] = placeId;
            notifyListeners();
          }

          return placeId;
        } else {
          debugPrint(
            'Google API error: ${data['status']} ${data['error_message'] ?? ''}',
          );
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in getPlaceIdAndUpdateFirestore: $e');
    }

    return null;
  }
}
