import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:clothing_shop/screens/cart_screen.dart';
import 'package:clothing_shop/screens/clothing_screen.dart';
import 'package:clothing_shop/screens/home_screen.dart';
import 'package:clothing_shop/screens/login_screen.dart';
import 'package:clothing_shop/screens/profile_screen.dart';
import 'package:clothing_shop/screens/signup_screen.dart';
import 'package:clothing_shop/screens/notification_screen.dart';
import 'package:clothing_shop/state/language_provider.dart';
import 'package:clothing_shop/state/navigation_provider.dart';
import 'package:clothing_shop/state/notification_provider.dart';
import 'package:clothing_shop/services/api_service.dart';
import 'package:clothing_shop/utils/string_extension.dart';
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
  String? _currentUserId;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token != null) {
      setState(() {
        _isLoggedIn = true;
      });
      _loadUserDataAndNotifications();
    }
  }

  Future<void> _loadUserDataAndNotifications() async {
    try {
      final profile = await ApiService(context).fetchUserProfile();
      setState(() {
        _currentUserId = profile.id;
      });
      if (mounted && _currentUserId != null) {
        context.read<NotificationProvider>().loadNotifications(context);
      }
    } catch (e) {
      print("Failed to sync profile for notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);

    Widget profileTab;

    if (_isLoggedIn) {
      profileTab = ProfileScreen(
        onLogoutSuccess: () {
          context.read<NotificationProvider>().clearNotifications();
          setState(() {
            _isLoggedIn = false;
            _showRegister = false;
            _currentUserId = null;
          });
        },
      );
    } else if (_showRegister) {
      profileTab = RegisterScreen(
        onRegisterSuccess: () {
          setState(() {
            _isLoggedIn = true;
          });
          _loadUserDataAndNotifications();
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
          _loadUserDataAndNotifications();
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
      _currentUserId != null
          ? NotificationScreen()
          : Center(child: Text(l10n.loginToSeeNotifications)),
      profileTab,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clothing Shop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🇬🇧",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: langProvider.isMyanmar,
                  onChanged: (value) => langProvider.toggleLanguage(),
                ),
                const Text(
                  "🇲🇲",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationProvider.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => navigationProvider.changeTab(index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.navBarHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag),
            label: l10n.clothing,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: l10n.cart,
          ),

          BottomNavigationBarItem(
            icon: Badge(
              label: Text(
                notificationProvider.unreadCount > 9
                    ? "${9.toString().toLocalizedNum(context)}+"
                    : notificationProvider.unreadCount
                          .toString()
                          .toLocalizedNum(context),
              ),
              isLabelVisible: notificationProvider.unreadCount > 0,
              child: const Icon(Icons.notifications),
            ),
            label: l10n.notifications,
          ),

          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
