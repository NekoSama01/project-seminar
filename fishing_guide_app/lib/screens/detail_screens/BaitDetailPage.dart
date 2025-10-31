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
      backgroundColor: Colors.grey[50],
      body: Consumer<BaitProvider>(
        builder: (context, baitProvider, _) {
          final targetFish = baitProvider.convertTarget(baitData['target']);
          final baitType = baitData['type']?.toString() ?? 'ไม่ระบุประเภท';
          final typeColor = baitProvider.getTypeColor(baitType);
          final textColor = baitProvider.getTypeTextColor(baitType);
          final price = baitData['price']?.toString();
          
          return CustomScrollView(
            slivers: [
              // Custom App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.green[800],
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      baitData['nameTH']?.toString() ?? 'รายละเอียดเหยื่อ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  background: _BaitImageSection(
                    documentId: documentId,
                    baitProvider: baitProvider,
                    isAppBarImage: true,
                  ),
                ),
              ),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Bait Name Card
                    _BaitNameCard(baitData: baitData),
                    const SizedBox(height: 16),
                    
                    // Type and Price Card
                    _TypePriceCard(
                      baitType: baitType,
                      typeColor: typeColor,
                      textColor: textColor,
                      price: price,
                    ),
                    const SizedBox(height: 16),
                    
                    // Target Fish Card
                    _TargetFishCard(targetFish: targetFish),
                    const SizedBox(height: 16),
                    
                    // Description Card
                    if (baitData['description']?.toString().isNotEmpty ?? false)
                      _DescriptionCard(
                        description: baitData['description']!.toString(),
                      ),
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

class _BaitImageSection extends StatelessWidget {
  final String documentId;
  final BaitProvider baitProvider;
  final bool isAppBarImage;

  const _BaitImageSection({
    required this.documentId,
    required this.baitProvider,
    this.isAppBarImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider?>(
      future: baitProvider.getBaitImage(documentId),
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
                fit: BoxFit.cover,
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
              Icon(Icons.set_meal_outlined, 
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
            Colors.green[400]!,
            Colors.green[800]!,
          ],
        ),
      ),
      child: Center(child: child),
    );
  }
}

class _BaitNameCard extends StatelessWidget {
  final Map<String, dynamic> baitData;

  const _BaitNameCard({required this.baitData});

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
              Colors.green[50]!,
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
                Icon(Icons.info_outline, color: Colors.green[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'ข้อมูลพื้นฐาน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailItem(
              icon: Icons.translate,
              label: 'ชื่อไทย',
              value: baitData['nameTH']?.toString() ?? 'ไม่ระบุ',
              color: Colors.green[700]!,
            ),
            _DetailItem(
              icon: Icons.language,
              label: 'ชื่ออังกฤษ',
              value: baitData['nameEN']?.toString() ?? 'ไม่ระบุ',
              color: Colors.blue[700]!,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePriceCard extends StatelessWidget {
  final String baitType;
  final Color typeColor;
  final Color textColor;
  final String? price;

  const _TypePriceCard({
    required this.baitType,
    required this.typeColor,
    required this.textColor,
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
              Colors.purple[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category_outlined, color: Colors.purple[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'ประเภทและราคา',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    baitType: baitType,
                    typeColor: typeColor,
                    textColor: textColor,
                  ),
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
    IconData typeIcon = _getTypeIcon(baitType);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(typeIcon, color: textColor, size: 28),
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
            baitType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'เหยื่อเทียม':
        return Icons.toys;
      case 'เหยื่อธรรมชาติ':
        return Icons.nature;
      case 'เหยื่อสด':
        return Icons.set_meal;
      default:
        return Icons.category;
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

class _TargetFishCard extends StatelessWidget {
  final List<String> targetFish;

  const _TargetFishCard({required this.targetFish});

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
              Colors.cyan[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: Colors.cyan[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'ปลาเป้าหมาย',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (targetFish.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: targetFish.map((fish) => _FishChip(fish: fish)).toList(),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'ไม่ระบุปลาเป้าหมาย',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FishChip extends StatelessWidget {
  final String fish;

  const _FishChip({required this.fish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan[100]!, Colors.cyan[200]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan[300]!.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets, color: Colors.cyan[800], size: 16),
          const SizedBox(width: 8),
          Text(
            fish,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.cyan[800],
            ),
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
              Colors.orange[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.orange[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'คำอธิบาย',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
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