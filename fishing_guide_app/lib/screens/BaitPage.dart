import 'package:flutter/material.dart';

class BaitPage extends StatefulWidget {
  @override
  _BaitPageState createState() => _BaitPageState();
}

class _BaitPageState extends State<BaitPage> {
  final List<Map<String, dynamic>> baitData = [
    {
      'name': 'เหยื่อปลอม',
      'type': 'พลาสติก',
      'description': 'เหยื่อสังเคราะห์รูปร่างคล้ายปลาเล็กหรือกบ',
      'image': 'images/baits/เหยื่อปลอม.png',
      'target': 'ปลากด, ปลาช่อน'
    },
    {
      'name': 'เหยื่อมีชีวิต',
      'type': 'ธรรมชาติ',
      'description': 'เช่น หนอน, กุ้ง, ปลาเล็ก นำมาใช้เป็นเหยื่อสด',
      'image': 'images/baits/เหยื่อมีชีวิต.png',
      'target': 'ปลานิล, ปลาตะเพียน'
    },
    {
      'name': 'เหยื่อผสม',
      'type': 'แป้ง',
      'description': 'เหยื่อที่ทำจากแป้งผสมกับส่วนผสมอื่นๆ',
      'image': 'images/baits/เหยื่อผสม.png',
      'target': 'ปลาสวาย, ปลาเทโพ'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
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
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: baitData.length,
                  itemBuilder: (context, index) {
                    final bait = baitData[index];
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
                                  backgroundImage: AssetImage(bait['image']),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bait['name'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800]),
                                    ),
                                    SizedBox(height: 4),
                                    Chip(
                                      label: Text(bait['type']),
                                      backgroundColor: bait['type'] == 'พลาสติก' 
                                          ? Colors.blue[100] 
                                          : bait['type'] == 'ธรรมชาติ'
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(bait['description']),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.set_meal, size: 16, color: Colors.red),
                                SizedBox(width: 4),
                                Text(
                                  'เหมาะสำหรับ: ${bait['target']}',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}