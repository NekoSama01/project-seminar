// place_details_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class PlacesDetailsResult extends StatelessWidget {
  final PlacesDetailsResponse? placeDetails;

  const PlacesDetailsResult({Key? key, required this.placeDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (placeDetails == null) return SizedBox.shrink();

    final place = placeDetails!.result;
    final photos = place.photos;
    final openingHours = place.openingHours;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัว
          Row(
            children: [
              Expanded(
                child: Text(
                  place.name ?? 'Unknown Place',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          // รูปภาพ (ถ้ามี)
          if (photos != null && photos.isNotEmpty)
            Container(
              height: 150,
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photos.first.photoReference}&key=GOOGLE_API_KEY'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Rating
          if (place.rating != null)
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 4),
                Text('${place.rating} reviews'),
              ],
            ),
          
          SizedBox(height: 8),
          
          // ที่อยู่
          if (place.formattedAddress != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 4),
                Expanded(child: Text(place.formattedAddress!)),
              ],
            ),
          
          SizedBox(height: 8),
          
          // เวลาเปิด-ปิด
          if (openingHours != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  openingHours.openNow ? 'เปิดอยู่' : 'ปิดแล้ว',
                  style: TextStyle(
                    color: openingHours.openNow ? Colors.green : Colors.red),
                ),
                if (openingHours.weekdayText != null)
                  ...openingHours.weekdayText!.map((text) => Text(text)),
              ],
            ),
          
          SizedBox(height: 16),
          
          // ปุ่มไปยังเว็บไซต์
          if (place.website != null)
            ElevatedButton(
              onPressed: () {
                // เปิดเว็บเบราว์เซอร์
              },
              child: Text('Visit Website'),
            ),
        ],
      ),
    );
  }
}