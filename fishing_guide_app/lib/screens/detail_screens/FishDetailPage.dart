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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fishData['nameTH']?.toString() ?? 'รายละเอียดปลา',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Consumer<FishProvider>(
        builder: (context, fishProvider, _) {
          final seasons = _convertToStringList(fishData['seasons']);
          final averageLength = fishData['average length']?.toString() ?? 'N/A';
          final averageWeight = fishData['average weight']?.toString() ?? 'N/A';
          final habitat = fishData['habitat']?.toString() ?? 'ไม่ระบุ';
          final difficulty = fishData['difficulty']?.toString();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FishImageSection(
                  documentId: documentId,
                  fishProvider: fishProvider,
                ),
                const SizedBox(height: 24),
                _BasicInfoSection(fishData: fishData),
                _MeasurementsSection(
                  averageLength: averageLength,
                  averageWeight: averageWeight,
                ),
                _HabitatSection(habitat: habitat),
                if (seasons.isNotEmpty) 
                  _SeasonsSection(seasons: seasons),
                if (difficulty != null)
                  _DifficultySection(difficulty: difficulty),
                if (fishData['description']?.toString().isNotEmpty ?? false)
                  _DescriptionSection(
                    description: fishData['description']!.toString(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _convertToStringList(dynamic list) {
    if (list == null) return [];
    if (list is List<String>) return list;
    return List<String>.from(list.map((item) => item.toString()));
  }
}

// ส่วน Widget ย่อยต่างๆ
class _FishImageSection extends StatelessWidget {
  final String documentId;
  final FishProvider fishProvider;

  const _FishImageSection({
    required this.documentId,
    required this.fishProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<ImageProvider?>(
        future: fishProvider.getFishImage(documentId),
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
  final Map<String, dynamic> fishData;

  const _BasicInfoSection({
    required this.fishData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ข้อมูลพื้นฐาน'),
        _DetailItem(label: 'ชื่อไทย', value: fishData['nameTH']?.toString() ?? 'ไม่ระบุ'),
        _DetailItem(label: 'ชื่ออังกฤษ', value: fishData['nameEN']?.toString() ?? 'ไม่ระบุ'),
        _DetailItem(label: 'ชื่อวิทยาศาสตร์', value: fishData['nameSC']?.toString() ?? 'ไม่ระบุ'),
      ],
    );
  }
}

class _MeasurementsSection extends StatelessWidget {
  final String averageLength;
  final String averageWeight;

  const _MeasurementsSection({
    required this.averageLength,
    required this.averageWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ขนาดโดยเฉลี่ย'),
        _MeasurementRow(
          icon: Icons.straighten,
          value: '$averageLength cm',
          color: Colors.blue[800]!,
        ),
        _MeasurementRow(
          icon: Icons.monitor_weight,
          value: '$averageWeight kg',
          color: Colors.green[800]!,
        ),
      ],
    );
  }
}

class _HabitatSection extends StatelessWidget {
  final String habitat;

  const _HabitatSection({
    required this.habitat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ถิ่นอาศัย'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            habitat,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _SeasonsSection extends StatelessWidget {
  final List<String> seasons;

  const _SeasonsSection({
    required this.seasons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ฤดูกาล'),
        _ChipList(items: seasons),
      ],
    );
  }
}

class _DifficultySection extends StatelessWidget {
  final String difficulty;

  const _DifficultySection({
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    switch (difficulty.toLowerCase()) {
      case 'ง่าย':
        chipColor = Colors.green[100]!;
        break;
      case 'ปานกลาง':
        chipColor = Colors.orange[100]!;
        break;
      case 'ยาก':
        chipColor = Colors.red[100]!;
        break;
      default:
        chipColor = Colors.grey[100]!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ระดับความยาก'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Chip(
            label: Text(
              difficulty,
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: chipColor,
          ),
        ),
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

// Widget ที่ใช้ร่วมกัน
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

class _MeasurementRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MeasurementRow({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
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