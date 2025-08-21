import 'package:fishing_guide_app/screens/detail_screens/RodDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/rod_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class RodPage extends StatefulWidget {
  @override
  _RodPageState createState() => _RodPageState();
}

class _RodPageState extends State<RodPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RodProvider>(context, listen: false).fetchRods();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData(BuildContext context) async {
    try {
      _animationController.reset();
      await Provider.of<RodProvider>(context, listen: false).fetchRods();
      _animationController.forward();
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
      debugPrint('Error refreshing rod data: $e');
    }
  }

  List<dynamic> _getFilteredRod(RodProvider rodProvider) {
    if (rodProvider.rodList == null || _searchQuery.isEmpty) {
      return rodProvider.rodList ?? [];
    }

    return rodProvider.rodList!.where((rodDoc) {
      final rod = rodDoc.data() as Map<String, dynamic>;
      final nameTH = rod['nameTH']?.toString().toLowerCase() ?? '';
      final nameEN = rod['nameEN']?.toString().toLowerCase() ?? '';
      final type = rod['type']?.toString().toLowerCase() ?? '';
      final action = rod['action']?.toString().toLowerCase() ?? '';
      final power = rod['power']?.toString().toLowerCase() ?? '';
      final searchLower = _searchQuery.toLowerCase();

      return nameTH.contains(searchLower) ||
          nameEN.contains(searchLower) ||
          type.contains(searchLower) ||
          action.contains(searchLower) ||
          power.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rodProvider = Provider.of<RodProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6a11cb), Color(0xFF2575fc), Color(0xFF667eea)],
          stops: [0.0, 0.6, 1.0],
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
                // Animated Header
                AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _headerAnimation.value,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6a11cb).withOpacity(0.3),
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
                                    Icons.anchor,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'คันเบ็ดแต่ละประเภท',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        rodProvider.rodList?.length != null
                                            ? 'ทั้งหมด ${rodProvider.rodList!.length} รายการ'
                                            : 'กำลังโหลดข้อมูล...',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
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
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'ค้นหาคันเบ็ด...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Color(0xFF6a11cb),
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
                                              setState(() {
                                                _searchQuery = '';
                                              });
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
                    );
                  },
                ),

                // Rod list content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _refreshData(context),
                    color: Color(0xFF6a11cb),
                    backgroundColor: Colors.white,
                    child: _buildRodList(context, rodProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRodList(BuildContext context, RodProvider rodProvider) {
    if (rodProvider.isLoading) {
      return _buildShimmerLoading();
    }

    if (rodProvider.error != null) {
      return _buildErrorState(context, rodProvider.error!);
    }

    final filteredRod = _getFilteredRod(rodProvider);

    if (filteredRod.isEmpty) {
      return _buildEmptyState(context);
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: filteredRod.length,
        itemBuilder: (context, index) {
          final rod = filteredRod[index].data() as Map<String, dynamic>;
          final documentId = filteredRod[index].id;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildEnhancedRodCard(
                  context,
                  rod,
                  documentId,
                  rodProvider,
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
              height: 150,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 35, backgroundColor: Colors.white),
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
                              width: 80,
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
                        SizedBox(height: 8),
                        Container(height: 16, width: 200, color: Colors.white),
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

  Widget _buildErrorState(BuildContext context, String error) {
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
            'ไม่สามารถโหลดข้อมูลคันเบ็ดได้',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshData(context),
            icon: Icon(Icons.refresh),
            label: Text('ลองใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6a11cb),
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
            _searchQuery.isNotEmpty ? 'ไม่พบผลการค้นหา' : 'ไม่พบข้อมูลคันเบ็ด',
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
              style: TextButton.styleFrom(foregroundColor: Color(0xFF6a11cb)),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRodCard(
    BuildContext context,
    Map<String, dynamic> rod,
    String documentId,
    RodProvider rodProvider,
  ) {
    final rodType = rod['type'] ?? 'ไม่ระบุประเภท';
    final rodColor = rodProvider.getRodTypeColor(rodType);
    final rodIcon = rodProvider.getRodTypeIcon(rodType);
    final hasPrice = rod['price'] != null && rod['price'].toString().isNotEmpty;

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
                        RodDetailPage(rodData: rod, documentId: documentId),
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
                                Color(0xFF6a11cb).withOpacity(0.1),
                                Color(0xFF2575fc).withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Color(0xFF6a11cb).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: FutureBuilder<ImageProvider?>(
                            future: rodProvider.getRodImage(documentId),
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
                                    Color(0xFF6a11cb),
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
                              rod['nameTH'] ?? 'ไม่มีชื่อ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6a11cb),
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              rod['nameEN'] ?? 'No Name',
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
                                  icon: rodIcon,
                                  value: rodType,
                                  gradient: LinearGradient(
                                    colors: [
                                      rodColor.withOpacity(0.2),
                                      rodColor.withOpacity(0.3),
                                    ],
                                  ),
                                  textColor: rodColor,
                                ),
                                if (rod['length'] != null)
                                  _buildEnhancedChip(
                                    icon: Icons.straighten,
                                    value: '${rod['length']} ม.',
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue[100]!,
                                        Colors.blue[200]!,
                                      ],
                                    ),
                                    textColor: Colors.blue[800]!,
                                  ),
                                if (rod['action'] != null)
                                  _buildEnhancedChip(
                                    icon: Icons.speed,
                                    value: rod['action'],
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green[100]!,
                                        Colors.green[200]!,
                                      ],
                                    ),
                                    textColor: Colors.green[800]!,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (hasPrice)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber[100]!, Colors.amber[200]!],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber[200]!.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.payments,
                                size: 18,
                                color: Colors.amber[800],
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${rod['price']} ฿',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  if (rod['description'] != null &&
                      rod['description'].toString().isNotEmpty) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.description,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rod['description'],
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 16),
                  // Rod Specifications
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[50]!, Colors.purple[100]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Column(
                      children: [
                        if (rod['power'] != null)
                          _buildSpecRow(
                            icon: Icons.fitness_center,
                            label: 'แรงต้าน',
                            value: rod['power'],
                            iconColor: Colors.purple[600]!,
                          ),
                        if (rod['power'] != null && rod['length'] != null)
                          Divider(height: 16, color: Colors.purple[200]),
                        if (rod['length'] != null)
                          _buildSpecRow(
                            icon: Icons.straighten,
                            label: 'ความยาว',
                            value: '${rod['length']} เมตร',
                            iconColor: Colors.indigo[600]!,
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
    required Color textColor,
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
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}
