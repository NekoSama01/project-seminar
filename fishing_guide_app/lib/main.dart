import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fishing_guide_app/provider/bait_provider.dart';
import 'package:fishing_guide_app/provider/fish_provider.dart';
import 'package:fishing_guide_app/provider/fishlog_provider.dart';
import 'package:fishing_guide_app/provider/rod_provider.dart';
import 'package:fishing_guide_app/provider/map_provider.dart';
import 'package:fishing_guide_app/provider/steps_provider.dart';
import 'package:fishing_guide_app/screens/LoginPage.dart';
import 'package:fishing_guide_app/screens/upload_screens/EditFishLog.dart';
import 'package:flutter/material.dart';
import 'package:fishing_guide_app/screens/BookPage.dart';
import 'package:fishing_guide_app/screens/FishPage.dart';
import 'package:fishing_guide_app/screens/BaitPage.dart';
import 'package:fishing_guide_app/screens/HomePage.dart';
import 'package:fishing_guide_app/screens/MapPage.dart';
import 'package:fishing_guide_app/screens/RodPage.dart';
import 'package:fishing_guide_app/screens/FishLogPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(); // โหลด environment variables

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FishProvider()),
        ChangeNotifierProvider(create: (_) => BaitProvider()),
        ChangeNotifierProvider(create: (_) => RodProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => StepsProvider()),
        ChangeNotifierProvider(
          create: (_) => FishLogProvider(),
        ), // เพิ่ม FishLogProvider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishing Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Kanit', // เพิ่ม fontFamily ที่ต้องการ
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AuthWrapper(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => HomeScreen(),
              settings: settings,
            );

          case '/edit-fish-log':
            // รับ arguments ที่ส่งมา (document ID)
            final String? documentId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => EditFishLogScreen(documentId: documentId),
              settings: settings,
            );

          default:
            // กรณีไม่เจอ route
            return MaterialPageRoute(
              builder:
                  (context) => Scaffold(
                    appBar: AppBar(title: Text('Page Not Found')),
                    body: Center(
                      child: Text('Page not found: ${settings.name}'),
                    ),
                  ),
            );
        }
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  // เปลี่ยนเป็น StatelessWidget
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginPage(); // LoginPage ควรมี Scaffold ของตัวเอง
          }
          return HomeScreen(); // HomeScreen มี Scaffold ของตัวเอง
        }
        return Scaffold(
          // หน้าขณะโหลดก็ต้องมี Scaffold
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  bool _isLoading = true;

  // เพิ่มตัวแปรสำหรับเมนูยืดออกจากด้านข้าง
  bool _isMenuExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

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

    // เริ่มต้น AnimationController
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0, // เริ่มต้นที่ด้านซ้ายสุด (ซ่อน)
      end: 0.0, // สิ้นสุดที่ตำแหน่งปกติ
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      if (!mounted) return;

      final fishProvider = Provider.of<FishProvider>(context, listen: false);
      final rodProvider = Provider.of<RodProvider>(context, listen: false);
      final baitProvider = Provider.of<BaitProvider>(context, listen: false);
      final stepsProvider = Provider.of<StepsProvider>(context, listen: false);
      final fishLogProvider = Provider.of<FishLogProvider>(
        context,
        listen: false,
      ); // เพิ่ม FishLogProvider

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

      // โหลดข้อมูล Steps สำหรับ BookPage
      await stepsProvider.refreshSteps();
      if (!mounted) return;

      // เริ่ม stream subscription สำหรับ FishLog
      fishLogProvider.initializeFishLogStream();
      if (!mounted) return;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
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
        // ปิดเมนูเมื่อเปลี่ยนหน้า
        if (_isMenuExpanded) {
          _toggleMenu();
        }
      });
    }
  }

  // ฟังก์ชันสำหรับเปิด/ปิดเมนู
  void _toggleMenu() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
      if (_isMenuExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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

  // ฟังก์ชันสำหรับนำทางไปหน้า FishLogPage
  void _navigateToFishLogPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FishLogPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างรายการเมนู
  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
    Color? textColor,
    Color? iconColor,
  }) {
    return Material(
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          if (title != 'ออกจากระบบ' &&
              title != 'ตั้งค่า' &&
              title != 'เกี่ยวกับ') {
            _toggleMenu(); // ปิดเมนูหลังจากเลือกหน้าหลัก
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    iconColor ??
                    (isSelected ? Colors.blue[700] : Colors.grey[700]),
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        textColor ??
                        (isSelected ? Colors.blue[700] : Colors.grey[800]),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.blue[700],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 20),
                Text(
                  'กำลังโหลดข้อมูล...',
                  style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Fishing Guide', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 46, 144, 255),
        actions: [
          // แสดงสถานะการโหลดข้อมูล Steps
          Consumer<StepsProvider>(
            builder: (context, stepsProvider, child) {
              if (stepsProvider.isLoading) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          // แสดงสถานะการโหลดข้อมูล FishLog
          Consumer<FishLogProvider>(
            builder: (context, fishLogProvider, child) {
              if (fishLogProvider.isLoading) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          // ปุ่มเมนูยืดออกจากด้านข้าง
          IconButton(
            icon: AnimatedRotation(
              turns: _isMenuExpanded ? 0.5 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Icon(Icons.menu, color: Colors.white),
            ),
            onPressed: _toggleMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
          // เนื้อหาหลัก
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[50]!, Colors.blue[100]!],
              ),
            ),
            child: _pages[_currentIndex],
          ),

          // Overlay เพื่อปิดเมนูเมื่อกดพื้นหลัง
          if (_isMenuExpanded)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // เมนูที่ยืดออกจากด้านข้าง
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _slideAnimation.value * 280,
                  0,
                ), // 280 คือความกว้างของเมนู
                child: Container(
                  width: 280,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(2, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // ส่วนหัวของเมนู
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 46, 144, 255),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.account_circle,
                                size: 60,
                                color: Colors.white,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Fishing Guide',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'เมนูนำทาง',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // รายการเมนู
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              // เพิ่มเมนูสมุดบันทึกพร้อม Consumer แสดงจำนวนบันทึก
                              Consumer<FishLogProvider>(
                                builder: (context, fishLogProvider, child) {
                                  return _buildMenuOption(
                                    icon: Icons.menu_book,
                                    title:
                                        'สมุดบันทึก ${fishLogProvider.fishLogCount > 0 ? '(${fishLogProvider.fishLogCount})' : ''}',
                                    onTap: () {
                                      _toggleMenu();
                                      _navigateToFishLogPage();
                                    },
                                    isSelected: false,
                                  );
                                },
                              ),
                              Divider(),
                              _buildMenuOption(
                                icon: Icons.settings,
                                title: 'ตั้งค่า',
                                onTap: () {
                                  _toggleMenu();
                                  // เพิ่มฟังก์ชันตั้งค่าที่นี่
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('ตั้งค่า - พัฒนาต่อไป'),
                                    ),
                                  );
                                },
                                isSelected: false,
                              ),
                              _buildMenuOption(
                                icon: Icons.info,
                                title: 'เกี่ยวกับ',
                                onTap: () {
                                  _toggleMenu();
                                  // เพิ่มฟังก์ชันเกี่ยวกับที่นี่
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'เกี่ยวกับแอพ - พัฒนาต่อไป',
                                      ),
                                    ),
                                  );
                                },
                                isSelected: false,
                              ),
                            ],
                          ),
                        ),

                        // ส่วนท้ายของเมนู
                        Divider(),
                        _buildMenuOption(
                          icon: Icons.logout,
                          title: 'ออกจากระบบ',
                          onTap: () {
                            _toggleMenu();
                            _signOut();
                          },
                          isSelected: false,
                          textColor: Colors.red,
                          iconColor: Colors.red,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
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
              icon: Stack(
                children: [
                  Icon(Icons.menu_book_outlined),
                  // แสดง badge เมื่อมีข้อมูลใน Steps
                  Consumer<StepsProvider>(
                    builder: (context, stepsProvider, child) {
                      if (stepsProvider.hasData) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${stepsProvider.totalSteps}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  Icon(Icons.menu_book),
                  // แสดง badge เมื่อมีข้อมูลใน Steps (สำหรับ active)
                  Consumer<StepsProvider>(
                    builder: (context, stepsProvider, child) {
                      if (stepsProvider.hasData) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${stepsProvider.totalSteps}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
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
