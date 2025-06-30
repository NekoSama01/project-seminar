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
      infoWindow: InfoWindow(title: 'Lumpini Park', snippet: 'Popular fishing spot'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fishing Spots Map',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Disable default button
            markers: _markers,
          ),
          
          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
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
                  icon: Icon(Icons.location_on, color: Colors.blue[600]),
                  suffixIcon: Icon(Icons.tune, color: Colors.blue[600]),
                ),
              ),
            ),
          ),
          
          // GPS Button (now on bottom-left)
          Positioned(
            bottom: 80,  // Positioned above add button
            left: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.blue[400],
              child: Icon(Icons.gps_fixed, color: Colors.white),
              onPressed: () {
                // Current location functionality
              },
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
            ),
          ),
        ],
      ),
    );
  }
}