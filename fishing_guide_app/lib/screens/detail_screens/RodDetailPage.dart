import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/rod_provider.dart';

class RodDetailPage extends StatelessWidget {
  final Map<String, dynamic> rodData;
  final String documentId;

  const RodDetailPage({
    Key? key,
    required this.rodData,
    required this.documentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rodProvider = Provider.of<RodProvider>(context, listen: false);
    final rodType = rodData['type']?.toString() ?? 'ไม่ระบุประเภท';
    final typeColor = rodProvider.getRodTypeColor(rodType);
    final typeIcon = rodProvider.getRodTypeIcon(rodType);
    final price = rodData['price']?.toString();
    final description = rodData['description']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(rodData['nameTH']?.toString() ?? 'รายละเอียดคันเบ็ด'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rod Image
            _buildRodImage(context, rodProvider),
            const SizedBox(height: 24),

            // Basic Information Section
            _buildSectionHeader('ข้อมูลพื้นฐาน'),
            _buildDetailItem('ชื่อไทย', rodData['nameTH']?.toString() ?? 'ไม่ระบุ'),
            _buildDetailItem('ชื่ออังกฤษ', rodData['nameEN']?.toString() ?? 'ไม่ระบุ'),
            
            // Type with colored chip
            _buildTypeChip(rodType, typeColor, typeIcon),

            // Price if available
            if (price != null && price.isNotEmpty)
              _buildDetailItem('ราคา', '$price บาท'),

            // Description Section
            if (description != null && description.isNotEmpty)
              _buildDescriptionSection(description),
          ],
        ),
      ),
    );
  }

  Widget _buildRodImage(BuildContext context, RodProvider rodProvider) {
    return Center(
      child: FutureBuilder<ImageProvider?>(
        future: rodProvider.getRodImage(documentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: CircularProgressIndicator()),
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
                children: const [
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
            child: const Center(child: Text('ไม่มีรูปภาพ')),
          );
        },
      ),
    );
  }

  Widget _buildTypeChip(String rodType, Color typeColor, IconData typeIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'ประเภทคันเบ็ด',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Chip(
              avatar: Icon(typeIcon, color: typeColor),
              label: Text(
                rodType,
                style: TextStyle(color: typeColor),
              ),
              backgroundColor: typeColor.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('คำอธิบาย'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'ชื่อไทย',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
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
}