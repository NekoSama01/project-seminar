import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/rod_provider.dart';

class RodPage extends StatefulWidget {
  @override
  _RodPageState createState() => _RodPageState();
}

class _RodPageState extends State<RodPage> {
  Future<void> _refreshData(BuildContext context) async {
    try {
      await Provider.of<RodProvider>(context, listen: false).fetchRods();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดข้อมูลใหม่ได้: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RodProvider>(context, listen: false).fetchRods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rodProvider = Provider.of<RodProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
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
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.anchor, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'คันเบ็ดแต่ละประเภท',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Content with RefreshIndicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refreshData(context),
                  child: _buildRodList(context, rodProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRodList(BuildContext context, RodProvider rodProvider) {
    if (rodProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (rodProvider.error != null) {
      return Center(child: Text(rodProvider.error!));
    }

    if (rodProvider.rodList == null || rodProvider.rodList!.isEmpty) {
      return Center(child: Text('ไม่พบข้อมูลคันเบ็ด'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: rodProvider.rodList!.length,
      itemBuilder: (context, index) {
        final rod = rodProvider.rodList![index].data() as Map<String, dynamic>;
        final documentId = rodProvider.rodList![index].id;
        final rodType = rod['type'] ?? 'ไม่ระบุประเภท';
        final rodColor = rodProvider.getRodTypeColor(rodType);
        final rodIcon = rodProvider.getRodTypeIcon(rodType);

        return Card(
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
                    // Image loading with FutureBuilder
                    FutureBuilder<ImageProvider?>(
                      future: rodProvider.getRodImage(documentId),
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

                        // Loading state
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
                            rod['nameTH'] ?? 'ไม่มีชื่อ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            rod['nameEN'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700]),
                          ),
                          Row(
                            children: [
                              _buildMeasurementChip(
                                icon: rodIcon,
                                value: rodType,
                                color: rodColor.withOpacity(0.2),
                                textColor: rodColor,
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  rod['description'] ?? 'ไม่มีคำอธิบาย',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'ราคา: ${rod['price'] ?? 'ไม่ระบุ'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeasurementChip({
    required IconData icon,
    required String value,
    required Color color,
    Color textColor = Colors.black,
  }) {
    return Chip(
      backgroundColor: color,
      avatar: Icon(icon, size: 16, color: textColor),
      label: Text(
        value,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}