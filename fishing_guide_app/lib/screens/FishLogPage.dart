import 'package:fishing_guide_app/provider/fishlog_provider.dart';
import 'package:fishing_guide_app/screens/upload_screens/Create_FishLog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FishLogPage extends StatefulWidget {
  @override
  _FishLogPageState createState() => _FishLogPageState();
}

class _FishLogPageState extends State<FishLogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fishLogProvider = Provider.of<FishLogProvider>(
        context,
        listen: false,
      );
      fishLogProvider.initializeFishLogStream();
    });
  }

  Future<void> _refreshData() async {
    try {
      final fishLogProvider = Provider.of<FishLogProvider>(
        context,
        listen: false,
      );
      await fishLogProvider.fetchFishLogs();
    } catch (e) {
      if (mounted) {
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
  }

  Future<void> _navigateToEdit(String documentId) async {
    try {
      final result = await Navigator.pushNamed(
        context,
        '/edit-fish-log',
        arguments: documentId,
      );

      if (result == true && mounted) {
        await Future.delayed(Duration(milliseconds: 300));
        await _refreshData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1e3c72), Color(0xFF2a5298), Color(0xFF87CEEB)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fishing Guide', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 46, 144, 255),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.05,
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
                    // Header (ไม่มี animation แล้ว)
                    _buildHeader(),

                    // Fish logs list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshData,
                        color: Color(0xFF1e3c72),
                        backgroundColor: Colors.white,
                        child: Consumer<FishLogProvider>(
                          builder: (context, fishLogProvider, child) {
                            if (fishLogProvider.isLoading) {
                              return _buildLoadingState();
                            }

                            if (fishLogProvider.error != null) {
                              return _buildErrorState(fishLogProvider.error!);
                            }

                            if (fishLogProvider.fishLogList == null ||
                                fishLogProvider.fishLogList!.isEmpty) {
                              return _buildEmptyState();
                            }

                            return AnimationLimiter(
                              child: ListView.builder(
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                                itemCount: fishLogProvider.fishLogList!.length,
                                itemBuilder: (context, index) {
                                  final doc =
                                      fishLogProvider.fishLogList![index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: Duration(milliseconds: 600),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: FishLogCard(
                                          documentId: doc.id,
                                          imageURL: data['imageURL'] ?? '',
                                          createdAt:
                                              data['createdAt'] as Timestamp?,
                                          detail: data['detail'] ?? '',
                                          username:
                                              data['username'] ??
                                              'Unknown User',
                                          onEditPressed:
                                              () => _navigateToEdit(doc.id),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1e3c72).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.book, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'บันทึกการตกปลาของฉัน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Consumer<FishLogProvider>(
                  builder: (context, fishLogProvider, child) {
                    return Text(
                      'ทั้งหมด ${fishLogProvider.fishLogCount} บันทึก',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.orange[600]!],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
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
                      pageBuilder: (_, __, ___) => UploadFishLogPage(),
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
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: Duration(milliseconds: 400),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'เพิ่มบันทึก',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1e3c72), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'กำลังโหลดบันทึก...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
            error,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: Icon(Icons.refresh),
            label: Text('ลองใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1e3c72),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.anchor, color: Colors.blue[300], size: 60),
          ),
          SizedBox(height: 20),
          Text(
            'ยังไม่มีบันทึกการตกปลา',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'เริ่มสร้างบันทึกแรกของคุณกันเลย!',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => UploadFishLogPage(),
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
            icon: Icon(Icons.add),
            label: Text('เพิ่มบันทึกแรก'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1e3c72),
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
}

class FishLogCard extends StatelessWidget {
  final String documentId;
  final String imageURL;
  final Timestamp? createdAt;
  final String detail;
  final String username;
  final VoidCallback? onEditPressed; // เพิ่ม callback

  const FishLogCard({
    Key? key,
    required this.documentId,
    required this.imageURL,
    required this.createdAt,
    required this.detail,
    required this.username,
    this.onEditPressed, // เพิ่ม parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FishLogProvider>(
      builder: (context, fishLogProvider, child) {
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
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                if (imageURL.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Image.network(
                      imageURL,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'ไม่สามารถโหลดรูปภาพได้',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1e3c72),
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Content section
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with username and time
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1e3c72),
                                  ),
                                ),
                                Text(
                                  fishLogProvider.formatDateTime(createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                // หา position ของปุ่ม
                                final RenderBox button =
                                    context.findRenderObject() as RenderBox;
                                final RenderBox overlay =
                                    Navigator.of(
                                          context,
                                        ).overlay!.context.findRenderObject()
                                        as RenderBox;
                                final RelativeRect position =
                                    RelativeRect.fromRect(
                                      Rect.fromPoints(
                                        button.localToGlobal(
                                          Offset.zero,
                                          ancestor: overlay,
                                        ),
                                        button.localToGlobal(
                                          button.size.bottomRight(Offset.zero),
                                          ancestor: overlay,
                                        ),
                                      ),
                                      Offset.zero & overlay.size,
                                    );

                                // แสดง menu
                                final String? selected = await showMenu<String>(
                                  context: context,
                                  position: position,
                                  constraints: BoxConstraints(
                                    minWidth: 120,
                                    maxWidth: 200,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 8,
                                  items: [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      height: 40,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Color(0xFF1e3c72),
                                          ),
                                          SizedBox(width: 8),
                                          Text('แก้ไข'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      height: 40,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'ลบ',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );

                                // จัดการ selection
                                if (selected != null && context.mounted) {
                                  if (selected == 'edit') {
                                    if (onEditPressed != null) {
                                      await Future.delayed(
                                        Duration(milliseconds: 100),
                                      );
                                      if (context.mounted) {
                                        onEditPressed!();
                                      }
                                    }
                                  } else if (selected == 'delete') {
                                    await Future.delayed(
                                      Duration(milliseconds: 100),
                                    );
                                    if (context.mounted) {
                                      _showDeleteConfirmation(
                                        context,
                                        fishLogProvider,
                                      );
                                    }
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Detail text
                      if (detail.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            detail,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FishLogProvider fishLogProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('ยืนยันการลบ'),
            ],
          ),
          content: Text(
            'คุณแน่ใจหรือไม่ที่จะลบบันทึกนี้? การดำเนินการนี้ไม่สามารถยกเลิกได้',
          ),
          actions: [
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey[600])),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('ลบ'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteFishLog(context, fishLogProvider);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFishLog(
    BuildContext context,
    FishLogProvider fishLogProvider,
  ) async {
    final success = await fishLogProvider.deleteFishLog(documentId);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('ลบบันทึกเรียบร้อยแล้ว'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fishLogProvider.error ?? 'เกิดข้อผิดพลาดในการลบบันทึก',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
