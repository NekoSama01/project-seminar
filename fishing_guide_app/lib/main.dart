import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fishing_guide_app/provider/bait_provider.dart';
import 'package:fishing_guide_app/provider/fish_provider.dart';
import 'package:fishing_guide_app/provider/rod_provider.dart';
import 'package:fishing_guide_app/provider/map_provider.dart'; // เพิ่ม import นี้
import 'package:fishing_guide_app/screens/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:fishing_guide_app/screens/BookPage.dart';
import 'package:fishing_guide_app/screens/FishPage.dart';
import 'package:fishing_guide_app/screens/BaitPage.dart';
import 'package:fishing_guide_app/screens/HomePage.dart';
import 'package:fishing_guide_app/screens/MapPage.dart';
import 'package:fishing_guide_app/screens/RodPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // เพิ่ม import นี้

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env"); // โหลด environment variables

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FishProvider()),
        ChangeNotifierProvider(create: (_) => BaitProvider()),
        ChangeNotifierProvider(create: (_) => RodProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()), // เพิ่ม MapProvider เข้ามา
      ],
      child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishing Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {  // เปลี่ยนเป็น StatelessWidget
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginPage();  // LoginPage ควรมี Scaffold ของตัวเอง
          }
          return HomeScreen();  // HomeScreen มี Scaffold ของตัวเอง
        }
        return Scaffold(  // หน้าขณะโหลดก็ต้องมี Scaffold
          body: Center( 
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      RodPage(),
      BaitPage(),
      FishPage(),
      MapPage(),
      BookPage(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  Future<void> _initializeData() async {
    try {
      if (!mounted) return;
      
      final fishProvider = Provider.of<FishProvider>(context, listen: false);
      final rodProvider = Provider.of<RodProvider>(context, listen: false);
      final baitProvider = Provider.of<BaitProvider>(context, listen: false);

      // Load data sequentially to avoid overwhelming the app
      await fishProvider.fetchFishes();
      if (!mounted) return;
      await fishProvider.precacheAllImages(context);
      
      await baitProvider.fetchBaits();
      if (!mounted) return;
      await baitProvider.precacheAllImages(context);
      
      await rodProvider.fetchRods();
      if (!mounted) return;
      await rodProvider.precacheAllImages(context);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onTap(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    // นำทางไปยังหน้า Login และลบ stack หน้าปัจจุบันทั้งหมด
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการออกจากระบบ: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Fishing Guide', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 46, 144, 255),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
    );
  }
}