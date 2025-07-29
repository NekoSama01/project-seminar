import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(13.7563, 100.5018), // Bangkok coordinates
    zoom: 12,
  );

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('spot1'),
      position: LatLng(13.7563, 100.5018),
      infoWindow: InfoWindow(
        title: 'Lumpini Park', 
        snippet: 'Popular fishing spot'
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
      ),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Disable default button
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              // You can store the controller if needed
            },
          ),
          
          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search fishing spots...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.blue[600]),
                  suffixIcon: Icon(Icons.tune, color: Colors.blue[600]),
                ),
                onTap: () {
                  // Handle search tap
                },
              ),
            ),
          ),
          
          // GPS Button (now on bottom-left)
          Positioned(
            bottom: 80,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: Icon(Icons.gps_fixed, color: Colors.blue[600]),
              onPressed: () {
                // Current location functionality
              },
              elevation: 2,
            ),
          ),
          
          // Add Location Button
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blue[600],
              child: Icon(Icons.add_location, color: Colors.white),
              onPressed: () {
                // Add new spot functionality
              },
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}