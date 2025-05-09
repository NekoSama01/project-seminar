import 'package:fishing_guide_app/screens/BookPage.dart';
import 'package:fishing_guide_app/screens/FishPage.dart';
import 'package:fishing_guide_app/screens/FishingPage.dart';
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
      title: 'Fishing Rods',
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    RodPage(),
    FishingPage(),
    FishPage(),
    MapPage(),
    BookPage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
    BottomNavigationBarItem(icon: Icon(Icons.anchor), label: 'เบ็ดตกปลา'),
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