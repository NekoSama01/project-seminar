import 'package:fishing_guide_app/screens/detail_screens/FishDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/fish_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FishPage extends StatefulWidget {
  @override
  _FishPageState createState() => _FishPageState();
}

class _FishPageState extends State<FishPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData(BuildContext context) async {
    try {
      await Provider.of<FishProvider>(context, listen: false).fetchFishes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('ไม่สามารถโหลดข้อมูลใหม่ได้: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  List<dynamic> _getFilteredFish(FishProvider fishProvider) {
    if (fishProvider.fishList == null || _searchQuery.isEmpty) {
      return fishProvider.fishList ?? [];
    }

    return fishProvider.fishList!.where((fishDoc) {
      final fish = fishDoc.data() as Map<String, dynamic>;
      final nameTH = fish['nameTH']?.toString().toLowerCase() ?? '';
      final nameEN = fish['nameEN']?.toString().toLowerCase() ?? '';
      final habitat = fish['habitat']?.toString().toLowerCase() ?? '';
      final searchLower = _searchQuery.toLowerCase();

      return nameTH.contains(searchLower) ||
          nameEN.contains(searchLower) ||
          habitat.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fishProvider = Provider.of<FishProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Column(
              children: [
                // Header (ไม่มี Animation แล้ว)
                Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.waves,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'ปลาแต่ละชนิด',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          decoration: InputDecoration(
                            hintText: 'ค้นหาปลา...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF667eea),
                            ),
                            suffixIcon:
                                _searchQuery.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey[500],
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Fish List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _refreshData(context),
                    color: Color(0xFF667eea),
                    backgroundColor: Colors.white,
                    child: _buildFishList(context, fishProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ส่วนด้านล่าง (_buildFishList, shimmer, card, info row ฯลฯ) เหมือนเดิมทั้งหมด
  Widget _buildFishList(BuildContext context, FishProvider fishProvider) {
    if (fishProvider.isLoading) return _buildShimmerLoading();
    if (fishProvider.error != null) return _buildErrorState(context);

    final filteredFish = _getFilteredFish(fishProvider);
    if (filteredFish.isEmpty) return _buildEmptyState(context);

    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: filteredFish.length,
        itemBuilder: (context, index) {
          final fish = filteredFish[index].data() as Map<String, dynamic>;
          final documentId = filteredFish[index].id;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildEnhancedFishCard(
                  context,
                  fish,
                  documentId,
                  fishProvider,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 120,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Container(height: 16, width: 150, color: Colors.white),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              height: 24,
                              width: 60,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Container(
                              height: 24,
                              width: 60,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.red[400], size: 60),
          ),
          SizedBox(height: 20),
          Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ไม่สามารถโหลดข้อมูลปลาได้',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshData(context),
            icon: Icon(Icons.refresh),
            label: Text('ลองใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.inbox_outlined,
              color: Colors.grey[400],
              size: 60,
            ),
          ),
          SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty ? 'ไม่พบผลการค้นหา' : 'ไม่พบข้อมูลปลา',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'ลองค้นหาด้วยคำอื่น'
                : 'กดรีเฟรชเพื่อโหลดข้อมูลใหม่',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          SizedBox(height: 20),
          if (_searchQuery.isEmpty)
            TextButton.icon(
              onPressed: () => _refreshData(context),
              icon: Icon(Icons.refresh),
              label: Text('รีเฟรชข้อมูล'),
              style: TextButton.styleFrom(foregroundColor: Color(0xFF667eea)),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFishCard(
    BuildContext context,
    Map<String, dynamic> fish,
    String documentId,
    FishProvider fishProvider,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (_, __, ___) =>
                        FishDetailPage(fishData: fish, documentId: documentId),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                transitionDuration: Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Enhanced Avatar with Hero Animation
                      Hero(
                        tag: documentId,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF667eea).withOpacity(0.1),
                                Color(0xFF764ba2).withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Color(0xFF667eea).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: FutureBuilder<ImageProvider?>(
                            future: fishProvider.getFishImage(documentId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.red[50],
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red[400],
                                    size: 28,
                                  ),
                                );
                              }

                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData &&
                                  snapshot.data != null) {
                                return CircleAvatar(
                                  radius: 35,
                                  backgroundImage: snapshot.data,
                                  backgroundColor: Colors.grey[100],
                                );
                              }

                              return CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.grey[100],
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF667eea),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fish['nameTH'] ?? 'ไม่มีชื่อ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF667eea),
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              fish['nameEN'] ?? 'No Name',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildEnhancedChip(
                                  icon: Icons.straighten,
                                  value:
                                      '${fish['average length'] ?? 'N/A'} cm',
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue[100]!,
                                      Colors.blue[200]!,
                                    ],
                                  ),
                                ),
                                _buildEnhancedChip(
                                  icon: Icons.monitor_weight,
                                  value:
                                      '${fish['average weight'] ?? 'N/A'} kg',
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[100]!,
                                      Colors.green[200]!,
                                    ],
                                  ),
                                ),
                                if (fish['difficulty'] != null)
                                  _buildDifficultyChip(fish['difficulty']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildEnhancedInfoRow(
                          icon: Icons.location_on,
                          text: 'ถิ่นอาศัย: ${fish['habitat'] ?? 'ไม่ระบุ'}',
                          iconColor: Colors.red[400]!,
                        ),
                        SizedBox(height: 8),
                        _buildEnhancedInfoRow(
                          icon: Icons.calendar_today,
                          text:
                              'ฤดู: ${fish['seasons']?.join(', ') ?? 'ตลอดปี'}',
                          iconColor: Colors.orange[400]!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedChip({
    required IconData icon,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color startColor, endColor;
    IconData difficultyIcon;

    switch (difficulty.toLowerCase()) {
      case 'ง่าย':
        startColor = Colors.green[100]!;
        endColor = Colors.green[200]!;
        difficultyIcon = Icons.sentiment_satisfied;
        break;
      case 'ปานกลาง':
        startColor = Colors.orange[100]!;
        endColor = Colors.orange[200]!;
        difficultyIcon = Icons.sentiment_neutral;
        break;
      case 'ยาก':
        startColor = Colors.red[100]!;
        endColor = Colors.red[200]!;
        difficultyIcon = Icons.sentiment_dissatisfied;
        break;
      default:
        startColor = Colors.grey[100]!;
        endColor = Colors.grey[200]!;
        difficultyIcon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [startColor, endColor]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(difficultyIcon, size: 14, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            difficulty,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoRow({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
