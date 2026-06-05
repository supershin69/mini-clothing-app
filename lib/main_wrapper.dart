import 'package:clothing_shop/screens/cart_screen.dart';
import 'package:clothing_shop/screens/clothing_screen.dart';
import 'package:clothing_shop/screens/home_screen.dart';
import 'package:clothing_shop/screens/login_screen.dart';
import 'package:clothing_shop/screens/profile_screen.dart';
import 'package:clothing_shop/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  bool _showRegister = false; // ✅ Login နှင့် Register အကူးအပြောင်းကို ထိန်းချုပ်မည့် State
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    String? token = await _storage.read(key: 'auth_token');
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget profileTab;

    // 💡 Auth Flow Widget သုံးဆင့် ခွဲခြားခြင်း
    if (_isLoggedIn) {
      profileTab = ProfileScreen(
        onLogoutSuccess: () {
          setState(() {
            _isLoggedIn = false;
            _showRegister = false; // Logout ဖြစ်ရင် Login ကနေ ပြန်စမယ်
          });
        },
      );
    } else if (_showRegister) {
      profileTab = RegisterScreen(
        onRegisterSuccess: () {
          setState(() {
            _isLoggedIn = true; // Register အောင်မြင်ရင် Profile တန်းပြမယ်
          });
        },
        onBackToLogin: () {
          setState(() {
            _showRegister = false; // Login screen ဘက် ပြန်လှည့်မယ်
          });
        },
      );
    } else {
      profileTab = LoginScreen(
        onLoginSuccess: () {
          setState(() {
            _isLoggedIn = true; // Login အောင်မြင်ရင် Profile ပြမယ်
          });
        },
        onGoToRegister: () {
          setState(() {
            _showRegister = true; // Register screen ဘက် သွားမယ်
          });
        },
      );
    }

    final List<Widget> screens = [
      const HomeScreen(),
      const ClothingScreen(),
      const CartScreen(),
      profileTab, // ✅ Dynamic Layout Wrapper သုံးထားလို့ Bottom Nav က ပျောက်မသွားပါဘူး
    ];

    return Scaffold(
        appBar: AppBar(
            title: const Text('Clothing Shop', style: TextStyle(fontWeight: FontWeight.bold))),
        body: screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Clothing'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ));
  }
}