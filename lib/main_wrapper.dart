import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:clothing_shop/screens/cart_screen.dart';
import 'package:clothing_shop/screens/clothing_screen.dart';
import 'package:clothing_shop/screens/home_screen.dart';
import 'package:clothing_shop/screens/login_screen.dart';
import 'package:clothing_shop/screens/profile_screen.dart';
import 'package:clothing_shop/screens/signup_screen.dart';
import 'package:clothing_shop/screens/notification_screen.dart'; // 👈 Import အသစ်
import 'package:clothing_shop/state/language_provider.dart';
import 'package:clothing_shop/state/navigation_provider.dart';
import 'package:clothing_shop/state/notification_provider.dart'; // 👈 Import အသစ်
import 'package:clothing_shop/services/api_service.dart'; // 👈 Profile ဆွဲရန် Import
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
  String? _currentUserId; // 👈 User ID သိမ်းထားရန်
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
      _loadUserDataAndNotifications(); // Token ရှိရင် Data တန်းခေါ်မယ်
    }
  }

  Future<void> _loadUserDataAndNotifications() async {
    try {
      final profile = await ApiService(context).fetchUserProfile();
      setState(() {
        _currentUserId = profile.id;
      });
      if (mounted && _currentUserId != null) {
        // Notification Data တွေကို လှမ်းဆွဲခိုင်းလိုက်ခြင်း
        context.read<NotificationProvider>().loadNotifications(
          context,
          _currentUserId!,
        );
      }
    } catch (e) {
      print("Failed to sync profile for notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    final notificationProvider = context
        .watch<NotificationProvider>(); // 👈 BadgeCount အတွက် စောင့်ကြည့်ရန်
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);

    Widget profileTab;

    if (_isLoggedIn) {
      profileTab = ProfileScreen(
        onLogoutSuccess: () {
          context
              .read<NotificationProvider>()
              .clearNotifications(); // Clear Noti on logout
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

    // 🛠 စာမျက်နှာ စုစုပေါင်း (၅) ခု ဖြစ်သွားပါပြီ (Notifications ကို အလယ်မှာ ညှပ်ထားပါတယ်)
    final List<Widget> screens = [
      const HomeScreen(),
      const ClothingScreen(),
      const CartScreen(),
      _currentUserId != null
          ? NotificationScreen(userId: _currentUserId!)
          : const Center(child: Text("Please login to see notifications")),
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

          // 👈 🛠 ဤနေရာတွင် Badge စနစ် ထည့်သွင်းထားသော Notification Icon ဖြစ်ပါတယ်ဗျာ
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(
                notificationProvider.unreadCount.toString().toLocalizedNum(
                  context,
                ),
              ),
              isLabelVisible:
                  notificationProvider.unreadCount >
                  0, // ၀ ထက်ကြီးမှ ကိန်းဂဏန်း Badge ပြမယ်
              child: const Icon(Icons.notifications),
            ),
            label: l10n
                .notifications, // သို့မဟုတ် မင်းရဲ့ l10n.notifications သုံးပါ
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
