import 'dart:math' as math;

import 'package:fishing_guide_app/provider/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  CameraPosition? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // ใช้ addPostFrameCallback เพื่อให้ทำงานหลัง build เสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await mapProvider.fetchLocations();

      if (mounted) {
        setState(() {
          if (mapProvider.markersBounds != null &&
              mapProvider.markers.isNotEmpty) {
            _initialPosition = CameraPosition(
              target: _calculateCenter(mapProvider.markersBounds!),
              zoom: _calculateZoomLevel(mapProvider.markersBounds!),
            );
          } else {
            _initialPosition = const CameraPosition(
              target: LatLng(16.74804986504787, 100.19208920772702),
              zoom: 12,
            );
          }
        });
      }
    });
  }

  LatLng _calculateCenter(LatLngBounds bounds) {
    return LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );
  }

  double _calculateZoomLevel(LatLngBounds bounds) {
    const double padding = 100; // padding in pixels
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double latDiff =
        bounds.northeast.latitude - bounds.southwest.latitude;
    final double lngDiff =
        bounds.northeast.longitude - bounds.southwest.longitude;

    final double latZoom =
        (math.log(height * 360 / (256 * latDiff)) / math.ln2) / 2;
    final double lngZoom =
        (math.log(width * 360 / (256 * lngDiff)) / math.ln2) / 2;

    return math.min(latZoom, lngZoom) - math.log(padding / 256) / math.ln2;
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      if (mapProvider.markersBounds != null && mounted) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(mapProvider.markersBounds!, 100),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบ _initialPosition ก่อน build
    if (_initialPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        // ใช้ FutureBuilder เพื่อจัดการสถานะการโหลด
        return FutureBuilder(
          future: provider.isLoading ? null : Future.value(),
          builder: (context, snapshot) {
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
                    initialCameraPosition: _initialPosition!,
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    markers: provider.markers,
                    onMapCreated: _onMapCreated,
                  ),

                  // ปุ่ม GPS
                  Positioned(
                    bottom: 80,
                    left: 20,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.gps_fixed, color: Colors.blue[600]),
                      onPressed: () async {
                        // เรียกตำแหน่งปัจจุบัน
                        if (provider.currentLocation != null) {
                          await _mapController?.animateCamera(
                            CameraUpdate.newLatLng(provider.currentLocation!),
                          );
                        }
                      },
                      elevation: 2,
                    ),
                  ),

                  // ปุ่มเพิ่มสถานที่
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue[600],
                      child: Icon(Icons.add_location, color: Colors.white),
                      onPressed: () {
                        // ไปยังหน้าจอเพิ่มสถานที่ใหม่
                      },
                      elevation: 2,
                    ),
                  ),
                  // Overlay ข้อมูล Marker แบบ Custom
                  if (provider.selectedMarkerData != null &&
                      provider.selectedMarkerPosition != null)
                    Positioned(
                      bottom: 160,
                      left: 20,
                      right: 20,
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start, // <<< ตรงนี้คือจุดสำคัญ
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      provider.selectedMarkerData!['name'] ??
                                          'ไม่มีชื่อ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left, // <<< ชิดซ้าย
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      provider.clearSelectedMarker();
                                    },
                                  ),
                                ],
                              ),
                              if (provider.selectedMarkerData!['address'] !=
                                  null)
                                Text(
                                  provider.selectedMarkerData!['address'],
                                  textAlign: TextAlign.left, // <<< ชิดซ้าย
                                ),
                              if (provider.selectedMarkerData!['Contact'] !=
                                  null)
                                Text(
                                  provider.selectedMarkerData!['Contact'],
                                  textAlign: TextAlign.left, // <<< ชิดซ้าย
                                ),
                              if (provider.selectedMarkerData!['fishs'] !=
                                  null)
                                Text(
                                  provider.selectedMarkerData!['fishs'],
                                  textAlign: TextAlign.left, // <<< ชิดซ้าย
                                ),

                              SizedBox(height: 8),
                              // เพิ่มปุ่มอื่นได้
                              ElevatedButton.icon(
                                icon: Icon(Icons.directions),
                                label: Text('นำทาง'),
                                onPressed: () {
                                  // ไปยังตำแหน่ง marker
                                  final pos = provider.selectedMarkerPosition!;
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(pos),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
