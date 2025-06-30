import 'package:flutter/material.dart';
import 'package:fishing_guide_app/screens/BookPage.dart';
import 'package:fishing_guide_app/screens/FishPage.dart';
import 'package:fishing_guide_app/screens/BaitPage.dart';
import 'package:fishing_guide_app/screens/HomePage.dart';
import 'package:fishing_guide_app/screens/MapPage.dart';
import 'package:fishing_guide_app/screens/RodPage.dart';
import 'package:firebase_core/firebase_core.dart'; // 👈 เพิ่ม
import 'firebase_options.dart'; // 👈 ใช้ถ้าคุณใช้ `flutterfire configure`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishing Guide App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
      ),
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
    HomePage(),
    RodPage(),
    BaitPage(),
    FishPage(),
    MapPage(),
    BookPage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTap,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'หน้าหลัก',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.anchor_outlined),
                activeIcon: Icon(Icons.anchor),
                label: 'คันเบ็ด',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report_outlined),
                activeIcon: Icon(Icons.bug_report),
                label: 'เหยื่อ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.set_meal_outlined),
                activeIcon: Icon(Icons.set_meal),
                label: 'ปลา',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'แผนที่',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'คู่มือ',
              ),
            ],
            selectedItemColor: Colors.blue[800],
            unselectedItemColor: Colors.grey[600],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}