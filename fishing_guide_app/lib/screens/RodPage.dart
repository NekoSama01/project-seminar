import 'package:flutter/material.dart';

class RodPage extends StatefulWidget {
  @override
  _RodPageState createState() => _RodPageState();
}

class _RodPageState extends State<RodPage> {
  final List<Map<String, dynamic>> rodData = [
    {
      'name': 'คันเบ็ดไม้ไผ่',
      'type': 'แบบดั้งเดิม',
      'description': 'เหมาะสำหรับตกปลาขนาดเล็กถึงกลาง น้ำหนักเบา',
      'image': 'images/rods/rod1.png',
      'price': '฿350-฿800'
    },
    {
      'name': 'คันสปินนิ่ง',
      'type': 'แบบสมัยใหม่',
      'description': 'เหมาะสำหรับการตกปลาแบบไกลฝั่ง ใช้งานง่าย',
      'image': 'images/rods/rod2.png',
      'price': '฿1,200-฿3,500'
    },
    {
      'name': 'คันเบทคาสติ้ง',
      'type': 'แบบมืออาชีพ',
      'description': 'เหมาะสำหรับปลาขนาดใหญ่ แข็งแรงทนทาน',
      'image': 'images/rods/rod3.png',
      'price': '฿2,500-฿6,000'
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
              
              // Content
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: rodData.length,
                  itemBuilder: (context, index) {
                    final rod = rodData[index];
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
                                  backgroundImage: AssetImage(rod['image']),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rod['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800]),
                                    ),
                                    SizedBox(height: 4),
                                    Chip(
                                      label: Text(rod['type']),
                                      backgroundColor: rod['type'] == 'แบบดั้งเดิม' 
                                          ? Colors.blue[100] 
                                          : rod['type'] == 'แบบสมัยใหม่'
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(rod['description']),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 16, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'ราคา: ${rod['price']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold),
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