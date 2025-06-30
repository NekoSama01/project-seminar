import 'package:flutter/material.dart';

class FishPage extends StatefulWidget {
  @override
  _FishPageState createState() => _FishPageState();
}

class _FishPageState extends State<FishPage> {
  final List<Map<String, dynamic>> fishData = [
    {
      'name': 'ปลาช่อน',
      'size': 'ใหญ่',
      'description': 'ปลาน้ำจืดขนาดใหญ่ น้ำหนักเฉลี่ย 2-5 กก. นิยมตกด้วยเหยื่อมีชีวิต',
      'image': 'images/fishs/ปลาช่อน.png',
      'habitat': 'แหล่งน้ำนิ่งและน้ำไหลช้า'
    },
    {
      'name': 'ปลานิล',
      'size': 'กลาง',
      'description': 'ปลาน้ำจืดขนาดกลาง น้ำหนักเฉลี่ย 0.5-1.5 กก. กินอาหารได้หลากหลาย',
      'image': 'images/fishs/ปลานิล.jpg',
      'habitat': 'แหล่งน้ำทั่วไป'
    },
    {
      'name': 'ปลาสวาย',
      'size': 'ใหญ่',
      'description': 'ปลาน้ำจืดขนาดใหญ่ น้ำหนักเฉลี่ย 3-10 กก. ชอบอยู่เป็นฝูง',
      'image': 'images/fishs/ปลาสวาย.png',
      'habitat': 'แม่น้ำและอ่างเก็บน้ำ'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          height: MediaQuery.of(context).size.height * 0.8, // Increased height
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
              // Header inside the box
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
                    Icon(Icons.set_meal, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'ปลาแต่ละชนิด',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Fish list content
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: fishData.length,
                  itemBuilder: (context, index) {
                    final fish = fishData[index];
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
                                  backgroundImage: AssetImage(fish['image']),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fish['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800]),
                                    ),
                                    SizedBox(height: 4),
                                    Chip(
                                      label: Text(fish['size']),
                                      backgroundColor: fish['size'] == 'ใหญ่' 
                                          ? Colors.blue[100] 
                                          : fish['size'] == 'กลาง'
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(fish['description']),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  'ถิ่นอาศัย: ${fish['habitat']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600]),
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