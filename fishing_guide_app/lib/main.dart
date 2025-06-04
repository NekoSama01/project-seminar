import 'package:fishing_guide_app/screens/BookPage.dart';
import 'package:fishing_guide_app/screens/FishPage.dart';
import 'package:fishing_guide_app/screens/BaitPage.dart';
import 'package:fishing_guide_app/screens/HomePage.dart'; // เพิ่ม import
import 'package:fishing_guide_app/screens/MapPage.dart';
import 'package:fishing_guide_app/screens/RodPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishing Guide App',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // เริ่มที่หน้าแรก (HomePage)

  // ปรับลำดับหน้าให้หน้าแรกเป็น HomePage
  final List<Widget> _pages = [
    HomePage(),    // หน้าแรก (index 0)
    RodPage(),     // เบ็ดตกปลา (index 1)
    BaitPage(), // หน้า FishingPage (index 2)
    FishPage(),    // หน้าปลา (index 3)
    MapPage(),     // แผนที่ (index 4)
    BookPage(),    // หนังสือ (index 5)
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // ปรับลำดับไอคอนให้ตรงกับลำดับหน้า
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
    BottomNavigationBarItem(icon: Icon(Icons.anchor), label: 'เบ็ดตกปลา'),
    BottomNavigationBarItem(icon: Icon(Icons.bug_report), label: 'เหยื่อ'),
    BottomNavigationBarItem(icon: Icon(Icons.set_meal), label: 'ปลา'),
    BottomNavigationBarItem(icon: Icon(Icons.map), label: 'แผนที่'),
    BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'หนังสือ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: _navItems,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}