import 'package:flutter/material.dart';

class RodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ข้อมูลคันเบ็ด')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          RodCard(
            imagePath: 'assets/rod1.png',
            title: 'คันเบ็ดไม้ไผ่',
            description: 'คันไม้ไผ่นั้นเหมาะแก่การตกปลาขนาดเล็กถึงใหญ่',
          ),
          RodCard(
            imagePath: 'assets/rod2.png',
            title: 'คันสปินนิ่ง',
            description: 'เหมาะที่จะใช้ตกปลาในขนาดพื้นที่ขนาดกลางไม่ใหญ่มาก',
          ),
          RodCard(
            imagePath: 'assets/rod3.png',
            title: 'คันเบทคาสติ้ง',
            description: 'การใช้สายขึ้นอยู่กับการระบุที่ขังคันเบ็ด ใช้ตกปลาได้ทุกประเภท',
          ),
        ],
      ),
    );
  }
}

class RodCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  RodCard({required this.imagePath, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Image.asset(imagePath, width: 100),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text(description),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}