import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/bait_provider.dart';

class BaitPage extends StatefulWidget {
  @override
  _BaitPageState createState() => _BaitPageState();
}

class _BaitPageState extends State<BaitPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BaitProvider>(context, listen: false).fetchBaits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final baitProvider = Provider.of<BaitProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05),
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
                    Icon(Icons.bug_report, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'เหยื่อตกปลาแต่ละชนิด',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _buildBaitList(context, baitProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBaitList(BuildContext context, BaitProvider baitProvider) {
    if (baitProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (baitProvider.error != null) {
      return Center(child: Text(baitProvider.error!));
    }

    if (baitProvider.baitList == null || baitProvider.baitList!.isEmpty) {
      return Center(child: Text('ไม่พบข้อมูลเหยื่อตกปลา'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: baitProvider.baitList!.length,
      itemBuilder: (context, index) {
        final bait = baitProvider.baitList![index].data() as Map<String, dynamic>;
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
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        bait['imageUrl'] ?? 'https://via.placeholder.com/60'),
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
                              color: Colors.blue[800]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            bait['nameEN'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700]),
                          ),
                          SizedBox(height: 4),
                          Chip(
                            label: Text(
                              bait['type'] ?? 'ไม่ระบุประเภท',
                              style: TextStyle(
                                color: baitProvider.getTypeTextColor(bait['type']),
                              ),
                            ),
                            backgroundColor: baitProvider.getTypeColor(bait['type']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(bait['description'] ?? 'ไม่มีคำอธิบาย'),
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
                        fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}