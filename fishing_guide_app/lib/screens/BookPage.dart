import 'package:fishing_guide_app/provider/steps_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepsProvider = Provider.of<StepsProvider>(context, listen: false);
      stepsProvider.fetchSteps();
      stepsProvider.debugInfo();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData(BuildContext context) async {
    try {
      await Provider.of<StepsProvider>(context, listen: false).refreshSteps();
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
      debugPrint('Error refreshing steps data: $e');
    }
  }

  List<dynamic> _getFilteredSteps(StepsProvider stepsProvider) {
    if (stepsProvider.steps.isEmpty || _searchQuery.isEmpty) {
      return stepsProvider.steps;
    }

    return stepsProvider.steps.where((step) {
      final documentTitle =
          stepsProvider.getDocumentTitle(step.id).toLowerCase();
      final searchLower = _searchQuery.toLowerCase();

      bool matchesTitle = documentTitle.contains(searchLower);
      bool matchesContent = step.data.entries.any((entry) {
        final fieldName =
            stepsProvider.getFieldDisplayName(entry.key).toLowerCase();
        final fieldValue = entry.value.toString().toLowerCase();
        return fieldName.contains(searchLower) ||
            fieldValue.contains(searchLower);
      });

      return matchesTitle || matchesContent;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF9b59b6)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.075,
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
                // 🔹 Header แบบไม่มี Animation
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
                              Icons.menu_book,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Consumer<StepsProvider>(
                              builder: (context, stepsProvider, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'คู่มือการใช้เหยื่อตกปลา',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      stepsProvider.hasData
                                          ? 'ทั้งหมด ${stepsProvider.steps.length} รายการ'
                                          : 'กำลังโหลดข้อมูล...',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // 🔹 Search Bar
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
                          onChanged:
                              (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'ค้นหาคู่มือ...',
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

                // 🔹 ส่วนแสดงรายการ
                Expanded(
                  child: Consumer<StepsProvider>(
                    builder: (context, stepsProvider, child) {
                      return RefreshIndicator(
                        onRefresh: () => _refreshData(context),
                        color: Color(0xFF667eea),
                        backgroundColor: Colors.white,
                        child: _buildStepsList(context, stepsProvider),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList(BuildContext context, StepsProvider stepsProvider) {
    if (stepsProvider.isLoading) {
      return _buildShimmerLoading();
    }

    if (stepsProvider.error.isNotEmpty) {
      return _buildErrorState(context, stepsProvider.error);
    }

    final filteredSteps = _getFilteredSteps(stepsProvider);

    if (filteredSteps.isEmpty) {
      return _buildEmptyState(context);
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: filteredSteps.length,
        itemBuilder: (context, index) {
          final step = filteredSteps[index];

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildEnhancedStepCard(context, step, stepsProvider),
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
              height: 200,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(height: 16, width: 150, color: Colors.white),
                  SizedBox(height: 8),
                  Container(
                    height: 60,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Container(height: 16, width: 200, color: Colors.white),
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
            'ไม่สามารถโหลดข้อมูลคู่มือได้',
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
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.menu_book_outlined,
              color: Colors.grey[400],
              size: 60,
            ),
          ),
          SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty ? 'ไม่พบผลการค้นหา' : 'ไม่พบข้อมูลคู่มือ',
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

  Widget _buildEnhancedStepCard(
    BuildContext context,
    dynamic step,
    StepsProvider stepsProvider,
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
            // แสดง Detail Dialog หรือนำทางไปหน้าใหม่
            _showStepDetailDialog(context, step, stepsProvider);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.blue.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header สำหรับแต่ละ document
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: stepsProvider.getHeaderColor(step.id),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.menu_book, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stepsProvider.getDocumentTitle(step.id),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // แสดงจำนวน fields และ preview
                  _buildFieldsPreview(step, stepsProvider),

                  SizedBox(height: 12),

                  // Action button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _showStepDetailDialog(
                            context,
                            step,
                            stepsProvider,
                          ),
                      icon: Icon(Icons.visibility, size: 18),
                      label: Text('ดูรายละเอียด'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: stepsProvider.getHeaderColor(step.id),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
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

  Widget _buildFieldsPreview(dynamic step, StepsProvider stepsProvider) {
    final fields = step.data.entries.take(2).toList(); // แสดงแค่ 2 fields แรก

    return Column(
      children:
          fields.map<Widget>((entry) {
            final fieldName = entry.key;
            final fieldValue = entry.value.toString();
            final preview =
                fieldValue.length > 100
                    ? '${fieldValue.substring(0, 100)}...'
                    : fieldValue;

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getFieldIcon(fieldName),
                    color: stepsProvider.getHeaderColor(step.id),
                    size: 18,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stepsProvider.getFieldDisplayName(fieldName),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          preview,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  void _showStepDetailDialog(
    BuildContext context,
    dynamic step,
    StepsProvider stepsProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: stepsProvider.getHeaderColor(step.id),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stepsProvider.getDocumentTitle(step.id),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          step.data.entries.map<Widget>((entry) {
                            final fieldName = entry.key;
                            final fieldValue = entry.value.toString();

                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getFieldIcon(fieldName),
                                        color: stepsProvider.getHeaderColor(
                                          step.id,
                                        ),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          stepsProvider.getFieldDisplayName(
                                            fieldName,
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      fieldValue,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // กำหนดไอคอนสำหรับแต่ละ field
  IconData _getFieldIcon(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'attaching the bait':
      case 'attaching the bait2':
        return Icons.attachment;
      case 'casting(spinning)':
      case 'casting':
        return Icons.sports_golf;
      case 'molding bait':
      case 'molding bait2':
        return Icons.category;
      case 'hooking bait':
        return Icons.link;
      case 'baitcasting rod':
        return Icons.phishing;
      default:
        return Icons.info;
    }
  }
}
