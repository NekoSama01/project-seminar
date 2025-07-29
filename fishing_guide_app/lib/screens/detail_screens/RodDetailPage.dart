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
    return Scaffold(
      appBar: AppBar(
        title: Text(rodData['nameTH']?.toString() ?? 'รายละเอียดคันเบ็ด'),
        backgroundColor: Colors.blue[800],
      ),
      body: _RodDetailContent(
        rodData: rodData,
        documentId: documentId,
      ),
    );
  }
}

class _RodDetailContent extends StatelessWidget {
  final Map<String, dynamic> rodData;
  final String documentId;

  const _RodDetailContent({
    required this.rodData,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RodProvider>(
      builder: (context, rodProvider, _) {
        final price = rodData['price']?.toString();
        final description = rodData['description']?.toString();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RodImageSection(
                documentId: documentId,
                rodProvider: rodProvider,
              ),
              const SizedBox(height: 24),
              _BasicInfoSection(rodData: rodData),
              if (price != null && price.isNotEmpty)
                _PriceSection(price: price),
              if (description != null && description.isNotEmpty)
                _DescriptionSection(description: description),
            ],
          ),
        );
      },
    );
  }
}

class _RodImageSection extends StatefulWidget {
  final String documentId;
  final RodProvider rodProvider;

  const _RodImageSection({
    required this.documentId,
    required this.rodProvider,
  });

  @override
  State<_RodImageSection> createState() => _RodImageSectionState();
}

class _RodImageSectionState extends State<_RodImageSection> {
  late Future<ImageProvider?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = widget.rodProvider.getRodImage(widget.documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<ImageProvider?>(
        future: _imageFuture,
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
                  fit: BoxFit.contain,
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
  final Map<String, dynamic> rodData;

  const _BasicInfoSection({required this.rodData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'ข้อมูลเบื้องต้น'),
        const SizedBox(height: 8),
        _DetailItem(
          label: 'ชื่อ (TH)',
          value: rodData['nameTH']?.toString() ?? '-',
        ),
        _DetailItem(
          label: 'ชื่อ (EN)',
          value: rodData['nameEN']?.toString() ?? '-',
        ),
        _DetailItem(
          label: 'ประเภท',
          valueWidget: _RodTypeChip(type: rodData['type']?.toString() ?? '-'),
        ),
      ],
    );
  }
}

class _RodTypeChip extends StatelessWidget {
  final String type;

  const _RodTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(type),
      backgroundColor: Colors.blue[100],
    );
  }
}

class _PriceSection extends StatelessWidget {
  final String price;

  const _PriceSection({required this.price});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _SectionHeader(title: 'ราคา'),
        const SizedBox(height: 8),
        Text(
          '$price บาท',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final String description;

  const _DescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _SectionHeader(title: 'รายละเอียด'),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailItem({
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '-',
                  style: const TextStyle(fontSize: 16),
                ),
          ),
        ],
      ),
    );
  }
}