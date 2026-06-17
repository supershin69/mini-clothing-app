import 'package:clothing_shop/screens/cart_screen.dart';
import 'package:clothing_shop/screens/clothing_screen.dart';
import 'package:clothing_shop/screens/home_screen.dart';
import 'package:clothing_shop/screens/login_screen.dart';
import 'package:clothing_shop/screens/profile_screen.dart';
import 'package:clothing_shop/screens/signup_screen.dart';
import 'package:clothing_shop/state/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  bool _isLoggedIn = false;
  bool _showRegister = false;
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
    final navigationProvider = context.watch<NavigationProvider>();
    Widget profileTab;

    if (_isLoggedIn) {
      profileTab = ProfileScreen(
        onLogoutSuccess: () {
          setState(() {
            _isLoggedIn = false;
            _showRegister = false;
          });
        },
      );
    } else if (_showRegister) {
      profileTab = RegisterScreen(
        onRegisterSuccess: () {
          setState(() {
            _isLoggedIn = true;
          });
        },
        onBackToLogin: () {
          setState(() {
            _showRegister = false;
          });
        },
      );
    } else {
      profileTab = LoginScreen(
        onLoginSuccess: () {
          setState(() {
            _isLoggedIn = true;
          });
        },
        onGoToRegister: () {
          setState(() {
            _showRegister = true;
          });
        },
      );
    }

    final List<Widget> screens = [
      const HomeScreen(),
      const ClothingScreen(),
      const CartScreen(),
      profileTab,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clothing Shop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: screens[navigationProvider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationProvider.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          navigationProvider.changeTab(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Clothing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
