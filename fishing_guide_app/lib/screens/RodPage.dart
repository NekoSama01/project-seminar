import 'package:fishing_guide_app/screens/detail_screens/RodDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:fishing_guide_app/screens/HomePage.dart';
import 'package:fishing_guide_app/screens/BaitPage.dart';
import 'package:fishing_guide_app/screens/FishPage.dart';
import 'package:fishing_guide_app/screens/MapPage.dart';
import 'package:fishing_guide_app/screens/BookPage.dart';

class RodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ข้อมูลคันเบ็ด')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          RodCard(
            imagePath: 'images/rod1.png',
            title: 'คันเบ็ดไม้ไผ่',
            description: 'คันไม้ไผ่นั้นเหมาะแก่การตกปลาขนาดเล็กถึงใหญ่',
          ),
          RodCard(
            imagePath: 'images/rod2.png',
            title: 'คันสปินนิ่ง',
            description: 'เหมาะที่จะใช้ตกปลาในขนาดพื้นที่ขนาดกลางไม่ใหญ่มาก',
          ),
          RodCard(
            imagePath: 'images/rod3.png',
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

  const RodCard({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RodDetailPage(
                title: title,
                description: description,
                imagePath: imagePath,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}