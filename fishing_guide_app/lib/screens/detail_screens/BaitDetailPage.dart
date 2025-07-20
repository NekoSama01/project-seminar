import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/bait_provider.dart';

class BaitDetailPage extends StatelessWidget {
  final Map<String, dynamic> baitData;
  final String documentId;

  const BaitDetailPage({
    Key? key,
    required this.baitData,
    required this.documentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baitProvider = Provider.of<BaitProvider>(context, listen: false);
    final targetFish = baitProvider.convertTarget(baitData['target']);
    final baitType = baitData['type']?.toString() ?? 'ไม่ระบุประเภท';
    final typeColor = baitProvider.getTypeColor(baitType);
    final textColor = baitProvider.getTypeTextColor(baitType);
    final price = baitData['price']?.toString();
    final description = baitData['description']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(baitData['nameTH']?.toString() ?? 'รายละเอียดเหยื่อ'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bait Image
            _buildBaitImage(context, baitProvider),
            const SizedBox(height: 24),

            // Basic Information Section
            _buildSectionHeader('ข้อมูลพื้นฐาน'),
            _buildDetailItem('ชื่อไทย', baitData['nameTH']?.toString() ?? 'ไม่ระบุ'),
            _buildDetailItem('ชื่ออังกฤษ', baitData['nameEN']?.toString() ?? 'ไม่ระบุ'),
            
            // Type with colored chip
            _buildTypeChip(baitType, typeColor, textColor),

            // Price if available
            if (price != null && price.isNotEmpty)
              _buildDetailItem('ราคา', '$price บาท'),

            // Target Fish Section
            _buildTargetFishSection(targetFish),

            // Description Section
            if (description != null && description.isNotEmpty)
              _buildDescriptionSection(description),
          ],
        ),
      ),
    );
  }

  Widget _buildBaitImage(BuildContext context, BaitProvider baitProvider) {
    return Center(
      child: FutureBuilder<ImageProvider?>(
        future: baitProvider.getBaitImage(documentId),
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

  Widget _buildTypeChip(String baitType, Color typeColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'ประเภทเหยื่อ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Chip(
              label: Text(
                baitType,
                style: TextStyle(color: textColor),
              ),
              backgroundColor: typeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetFishSection(List<String> targetFish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ปลาเป้าหมาย'),
        if (targetFish.isNotEmpty)
          _buildChipList(targetFish)
        else
          _buildDetailItem('ปลาเป้าหมาย', 'ไม่ระบุ'),
      ],
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
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
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

  Widget _buildChipList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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