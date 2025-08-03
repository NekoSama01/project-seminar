import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      await Future.microtask(() => notifyListeners()); // <-- ใช้ microtask

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
          infoWindow: InfoWindow(
            title: data['name'] ?? 'Unknown Location',
            snippet: data['address'] ?? '',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
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
      await Future.microtask(() => notifyListeners()); // <-- ใช้ microtask
    }
  }

  // ตั้งค่าตำแหน่งปัจจุบัน
  void setCurrentLocation(LatLng location) {
    _currentLocation = location;
    notifyListeners();
  }
}
