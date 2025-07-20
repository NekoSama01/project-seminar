import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/fish_provider.dart';

class FishDetailPage extends StatelessWidget {
  final Map<String, dynamic> fishData;
  final String documentId;

  const FishDetailPage({
    Key? key,
    required this.fishData,
    required this.documentId,
  }) : super(key: key);

  // Helper method to safely convert dynamic list to String list
  List<String> _convertToStringList(dynamic list) {
    if (list == null) return [];
    if (list is List<String>) return list;
    return List<String>.from(list.map((item) => item.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final seasons = _convertToStringList(fishData['seasons']);
    final averageLength = fishData['average length']?.toString() ?? 'N/A';
    final averageWeight = fishData['average weight']?.toString() ?? 'N/A';
    final description = fishData['description']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(fishData['nameTH']?.toString() ?? 'รายละเอียดปลา'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fish Image
            Center(
              child: FutureBuilder<ImageProvider?>(
                future: Provider.of<FishProvider>(context, listen: false)
                    .getFishImage(documentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 40),
                          Text('โหลดรูปภาพไม่สำเร็จ'),
                        ],
                      ),
                    );
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text('ไม่มีรูปภาพ')),
                  );
                },
              ),
            ),
            SizedBox(height: 24),

            // Basic Information Section
            _buildSectionHeader('ข้อมูลพื้นฐาน'),
            _buildDetailItem('ชื่อไทย', fishData['nameTH']?.toString() ?? 'ไม่ระบุ'),
            _buildDetailItem('ชื่ออังกฤษ', fishData['nameEN']?.toString() ?? 'ไม่ระบุ'),
            
            // Measurements
            _buildSectionHeader('ขนาดโดยเฉลี่ย'),
            _buildMeasurementRow(Icons.straighten, '$averageLength cm'),
            _buildMeasurementRow(Icons.monitor_weight, '$averageWeight kg'),

            // Seasons Section
            _buildSectionHeader('ฤดูกาล'),
            if (seasons.isNotEmpty)
              _buildChipList(seasons)
            else
              _buildDetailItem('ฤดูกาล', 'ตลอดปี'),

            // Description Section
            if (description != null && description.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('คำอธิบาย'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[800]),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChipList(List<String> items) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) => Chip(
          label: Text(item),
          backgroundColor: Colors.blue[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        )).toList(),
      ),
    );
  }
}