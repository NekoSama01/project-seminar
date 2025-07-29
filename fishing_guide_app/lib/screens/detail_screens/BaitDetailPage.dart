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
    return Scaffold(
      appBar: AppBar(
        title: Text(baitData['nameTH']?.toString() ?? 'รายละเอียดเหยื่อ'),
        backgroundColor: Colors.blue[800],
      ),
      body: Consumer<BaitProvider>(
        builder: (context, baitProvider, _) {
          final targetFish = baitProvider.convertTarget(baitData['target']);
          final baitType = baitData['type']?.toString() ?? 'ไม่ระบุประเภท';
          final typeColor = baitProvider.getTypeColor(baitType);
          final textColor = baitProvider.getTypeTextColor(baitType);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BaitImageSection(
                  documentId: documentId,
                  baitProvider: baitProvider,
                ),
                const SizedBox(height: 24),
                _BasicInfoSection(
                  baitData: baitData,
                  baitType: baitType,
                  typeColor: typeColor,
                  textColor: textColor,
                ),
                _TargetFishSection(targetFish: targetFish),
                if (baitData['description']?.toString().isNotEmpty ?? false)
                  _DescriptionSection(
                    description: baitData['description']!.toString(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// แยก Widget ย่อยเป็นคลาสต่างๆ
class _BaitImageSection extends StatelessWidget {
  final String documentId;
  final BaitProvider baitProvider;

  const _BaitImageSection({
    required this.documentId,
    required this.baitProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<ImageProvider?>(
        future: baitProvider.getBaitImage(documentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildImagePlaceholder(
              child: const CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return _buildImagePlaceholder(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.error, color: Colors.red, size: 40),
                  Text('โหลดรูปภาพไม่สำเร็จ'),
                ],
              ),
            );
          }
          if (snapshot.hasData) {
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
          return _buildImagePlaceholder(
            child: const Text('ไม่มีรูปภาพ'),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder({required Widget child}) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}

class _BasicInfoSection extends StatelessWidget {
  final Map<String, dynamic> baitData;
  final String baitType;
  final Color typeColor;
  final Color textColor;

  const _BasicInfoSection({
    required this.baitData,
    required this.baitType,
    required this.typeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ข้อมูลพื้นฐาน'),
        _DetailItem(label: 'ชื่อไทย', value: baitData['nameTH']?.toString() ?? 'ไม่ระบุ'),
        _DetailItem(label: 'ชื่ออังกฤษ', value: baitData['nameEN']?.toString() ?? 'ไม่ระบุ'),
        _TypeChip(baitType: baitType, typeColor: typeColor, textColor: textColor),
        if (baitData['price']?.toString().isNotEmpty ?? false)
          _DetailItem(label: 'ราคา', value: '${baitData['price']} บาท'),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String baitType;
  final Color typeColor;
  final Color textColor;

  const _TypeChip({
    required this.baitType,
    required this.typeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _TargetFishSection extends StatelessWidget {
  final List<String> targetFish;

  const _TargetFishSection({
    required this.targetFish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ปลาเป้าหมาย'),
        if (targetFish.isNotEmpty)
          _ChipList(items: targetFish)
        else
          const _DetailItem(label: 'ปลาเป้าหมาย', value: 'ไม่ระบุ'),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final String description;

  const _DescriptionSection({
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('คำอธิบาย'),
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
}

// Widget ย่อยที่ใช้ร่วมกัน
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
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
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ChipList extends StatelessWidget {
  final List<String> items;

  const _ChipList({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
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