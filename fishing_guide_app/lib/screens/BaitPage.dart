import 'package:fishing_guide_app/screens/detail_screens/BaitDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/bait_provider.dart';

class BaitPage extends StatefulWidget {
  @override
  _BaitPageState createState() => _BaitPageState();
}

class _BaitPageState extends State<BaitPage> {
  Future<void> _refreshData(BuildContext context) async {
    try {
      await Provider.of<BaitProvider>(context, listen: false).fetchBaits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถโหลดข้อมูลใหม่ได้: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
      debugPrint('Error refreshing bait data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BaitProvider>(context, listen: false).fetchBaits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final baitProvider = Provider.of<BaitProvider>(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 144, 255),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bug_report, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'เหยื่อตกปลาแต่ละชนิด',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content with RefreshIndicator
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshData(context),
              child: _buildBaitList(context, baitProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaitList(BuildContext context, BaitProvider baitProvider) {
    if (baitProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
        ),
      );
    }

    if (baitProvider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'เกิดข้อผิดพลาด: ${baitProvider.error}',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refreshData(context),
              child: Text('ลองใหม่'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
              ),
            ),
          ],
        ),
      );
    }

    if (baitProvider.baitList == null || baitProvider.baitList!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            Text('ไม่พบข้อมูลเหยื่อตกปลา'),
            TextButton(
              onPressed: () => _refreshData(context),
              child: Text('รีเฟรชข้อมูล'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: baitProvider.baitList!.length,
      itemBuilder: (context, index) {
        final bait = baitProvider.baitList![index].data() as Map<String, dynamic>;
        final documentId = baitProvider.baitList![index].id;
        final baitType = bait['type'] ?? 'ไม่ระบุประเภท';
        final typeColor = baitProvider.getTypeColor(baitType);
        final textColor = baitProvider.getTypeTextColor(baitType);

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => BaitDetailPage(
                  baitData: bait,
                  documentId: documentId,
                ),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FutureBuilder<ImageProvider?>(
                        future: baitProvider.getBaitImage(documentId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Tooltip(
                              message: 'ไม่สามารถโหลดรูปภาพ: ${snapshot.error}',
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.red[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    Text(
                                      'ERROR',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.hasData &&
                              snapshot.data != null) {
                            return CircleAvatar(
                              radius: 30,
                              backgroundImage: snapshot.data,
                            );
                          }

                          return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[200],
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bait['nameTH'] ?? bait['name'] ?? 'ไม่มีชื่อ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              bait['nameEN'] ?? 'No Name',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Chip(
                              label: Text(
                                baitType,
                                style: TextStyle(color: textColor),
                              ),
                              backgroundColor: typeColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    bait['description'] ?? 'ไม่มีคำอธิบาย',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.set_meal, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'เหมาะสำหรับ: ${bait['target'] ?? 'ไม่ระบุปลาเป้าหมาย'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  if (bait['price'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'ราคา: ${bait['price']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}