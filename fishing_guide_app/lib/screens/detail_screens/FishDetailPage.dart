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
      backgroundColor: Colors.grey[50],
      body: Consumer<FishProvider>(
        builder: (context, fishProvider, _) {
          final seasons = _convertToStringList(fishData['seasons']);
          final averageLength = fishData['average length']?.toString() ?? 'N/A';
          final averageWeight = fishData['average weight']?.toString() ?? 'N/A';
          final habitat = fishData['habitat']?.toString() ?? 'ไม่ระบุ';
          final difficulty = fishData['difficulty']?.toString();
          
          return CustomScrollView(
            slivers: [
              // Custom App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.blue[800],
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      fishData['nameTH']?.toString() ?? 'รายละเอียดปลา',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  background: _FishImageSection(
                    documentId: documentId,
                    fishProvider: fishProvider,
                    isAppBarImage: true,
                  ),
                ),
              ),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Fish Name Card
                    _FishNameCard(fishData: fishData),
                    const SizedBox(height: 16),
                    
                    // Quick Stats
                    _QuickStatsCard(
                      averageLength: averageLength,
                      averageWeight: averageWeight,
                      difficulty: difficulty,
                    ),
                    const SizedBox(height: 16),
                    
                    // Habitat Card
                    _HabitatCard(habitat: habitat),
                    const SizedBox(height: 16),
                    
                    // Seasons Card
                    if (seasons.isNotEmpty) 
                      _SeasonsCard(seasons: seasons),
                    if (seasons.isNotEmpty) 
                      const SizedBox(height: 16),
                    
                    // Description Card
                    if (fishData['description']?.toString().isNotEmpty ?? false)
                      _DescriptionCard(
                        description: fishData['description']!.toString(),
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

  List<String> _convertToStringList(dynamic list) {
    if (list == null) return [];
    if (list is List<String>) return list;
    return List<String>.from(list.map((item) => item.toString()));
  }
}

class _FishImageSection extends StatelessWidget {
  final String documentId;
  final FishProvider fishProvider;
  final bool isAppBarImage;

  const _FishImageSection({
    required this.documentId,
    required this.fishProvider,
    this.isAppBarImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider?>(
      future: fishProvider.getFishImage(documentId),
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
              Icon(Icons.image_not_supported, 
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
            Colors.blue[400]!,
            Colors.blue[800]!,
          ],
        ),
      ),
      child: Center(child: child),
    );
  }
}

class _FishNameCard extends StatelessWidget {
  final Map<String, dynamic> fishData;

  const _FishNameCard({required this.fishData});

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
              Colors.blue[50]!,
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
                Icon(Icons.info_outline, color: Colors.blue[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'ข้อมูลพื้นฐาน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailItem(
              icon: Icons.translate,
              label: 'ชื่อไทย',
              value: fishData['nameTH']?.toString() ?? 'ไม่ระบุ',
              color: Colors.green[700]!,
            ),
            _DetailItem(
              icon: Icons.language,
              label: 'ชื่ออังกฤษ',
              value: fishData['nameEN']?.toString() ?? 'ไม่ระบุ',
              color: Colors.blue[700]!,
            ),
            _DetailItem(
              icon: Icons.science,
              label: 'ชื่อวิทยาศาสตร์',
              value: fishData['nameSC']?.toString() ?? 'ไม่ระบุ',
              color: Colors.purple[700]!,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  final String averageLength;
  final String averageWeight;
  final String? difficulty;

  const _QuickStatsCard({
    required this.averageLength,
    required this.averageWeight,
    this.difficulty,
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
                Icon(Icons.analytics_outlined, color: Colors.orange[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'สถิติด่วน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    icon: Icons.straighten,
                    title: 'ความยาว',
                    value: '$averageLength cm',
                    color: Colors.blue[600]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    icon: Icons.monitor_weight,
                    title: 'น้ำหนัก',
                    value: '$averageWeight kg',
                    color: Colors.green[600]!,
                  ),
                ),
              ],
            ),
            if (difficulty != null) ...[
              const SizedBox(height: 12),
              _DifficultyChip(difficulty: difficulty!),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    IconData icon;
    
    switch (difficulty.toLowerCase()) {
      case 'ง่าย':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.sentiment_very_satisfied;
        break;
      case 'ปานกลาง':
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.sentiment_neutral;
        break;
      case 'ยาก':
        chipColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.sentiment_very_dissatisfied;
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            'ระดับความยาก: $difficulty',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitatCard extends StatelessWidget {
  final String habitat;

  const _HabitatCard({required this.habitat});

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
              Colors.teal[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nature_people, color: Colors.teal[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'ถิ่นอาศัย',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal[200]!),
              ),
              child: Text(
                habitat,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonsCard extends StatelessWidget {
  final List<String> seasons;

  const _SeasonsCard({required this.seasons});

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
              Colors.amber[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.amber[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'ฤดูกาลที่เหมาะสม',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: seasons.map((season) => _SeasonChip(season: season)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonChip extends StatelessWidget {
  final String season;

  const _SeasonChip({required this.season});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[100]!, Colors.amber[200]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber[300]!.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        season,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.amber[800],
        ),
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
                  'คำอธิบาย',
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