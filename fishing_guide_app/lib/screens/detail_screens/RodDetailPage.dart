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
      backgroundColor: Colors.grey[50],
      body: Consumer<RodProvider>(
        builder: (context, rodProvider, _) {
          final price = rodData['price']?.toString();
          final description = rodData['description']?.toString();
          final rodType = rodData['type']?.toString() ?? 'ไม่ระบุประเภท';
          
          return CustomScrollView(
            slivers: [
              // Custom App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.deepOrange[800],
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      rodData['nameTH']?.toString() ?? 'รายละเอียดคันเบ็ด',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  background: _RodImageSection(
                    documentId: documentId,
                    rodProvider: rodProvider,
                    isAppBarImage: true,
                  ),
                ),
              ),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Rod Name Card
                    _RodNameCard(rodData: rodData),
                    const SizedBox(height: 16),
                    
                    // Type and Price Card
                    _TypePriceCard(
                      rodType: rodType,
                      price: price,
                    ),
                    const SizedBox(height: 16),
                    
                    // Description Card
                    if (description != null && description.isNotEmpty)
                      _DescriptionCard(description: description),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RodImageSection extends StatefulWidget {
  final String documentId;
  final RodProvider rodProvider;
  final bool isAppBarImage;

  const _RodImageSection({
    required this.documentId,
    required this.rodProvider,
    this.isAppBarImage = false,
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
    return FutureBuilder<ImageProvider?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildImagePlaceholder(
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildImagePlaceholder(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error, color: Colors.white70, size: 40),
                SizedBox(height: 8),
                Text(
                  'โหลดรูปภาพไม่สำเร็จ',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: snapshot.data!,
                fit: BoxFit.contain,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          );
        }
        return _buildImagePlaceholder(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.phishing_outlined, 
                   color: Colors.white70, size: 60),
              SizedBox(height: 8),
              Text(
                'ไม่มีรูปภาพ',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange[400]!,
            Colors.deepOrange[800]!,
          ],
        ),
      ),
      child: Center(child: child),
    );
  }
}

class _RodNameCard extends StatelessWidget {
  final Map<String, dynamic> rodData;

  const _RodNameCard({required this.rodData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepOrange[50]!,
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.deepOrange[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'ข้อมูลพื้นฐาน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailItem(
              icon: Icons.translate,
              label: 'ชื่อไทย',
              value: rodData['nameTH']?.toString() ?? 'ไม่ระบุ',
              color: Colors.red[700]!,
            ),
            _DetailItem(
              icon: Icons.language,
              label: 'ชื่ออังกฤษ',
              value: rodData['nameEN']?.toString() ?? 'ไม่ระบุ',
              color: Colors.blue[700]!,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePriceCard extends StatelessWidget {
  final String rodType;
  final String? price;

  const _TypePriceCard({
    required this.rodType,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.brown[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build_outlined, color: Colors.brown[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'ประเภทและราคา',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TypeBox(rodType: rodType),
                ),
                if (price != null && price!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PriceBox(price: price!),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBox extends StatelessWidget {
  final String rodType;

  const _TypeBox({required this.rodType});

  @override
  Widget build(BuildContext context) {
    final typeInfo = _getTypeInfo(rodType);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeInfo['color'].withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(typeInfo['icon'], color: typeInfo['color'], size: 28),
          const SizedBox(height: 8),
          Text(
            'ประเภท',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rodType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: typeInfo['color'],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getTypeInfo(String type) {
    switch (type.toLowerCase()) {
      case 'คันเบ็ดตกปลาทะเล':
        return {
          'icon': Icons.waves,
          'color': Colors.blue[700]!,
        };
      case 'คันเบ็ดตกปลาน้ำจืด':
        return {
          'icon': Icons.water_drop,
          'color': Colors.green[700]!,
        };
      case 'คันเบ็ดลูก':
        return {
          'icon': Icons.phishing,
          'color': Colors.orange[700]!,
        };
      case 'คันเบ็ดสปินนิ่ง':
        return {
          'icon': Icons.circle_outlined,
          'color': Colors.purple[700]!,
        };
      default:
        return {
          'icon': Icons.phishing_outlined,
          'color': Colors.brown[700]!,
        };
    }
  }
}

class _PriceBox extends StatelessWidget {
  final String price;

  const _PriceBox({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.payments, color: Colors.amber[800], size: 28),
          const SizedBox(height: 8),
          Text(
            'ราคา',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$price บาท',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.indigo[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'รายละเอียด',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}