import 'package:clothing_shop/main_wrapper.dart';
import 'package:clothing_shop/state/cart_provider.dart';
import 'package:clothing_shop/state/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Clothing Shop',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFF1A1A1A),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A1A),
          secondary: const Color(0xFFE5D3B3),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFFE5D3B3),
          unselectedItemColor: Colors.grey,
          selectedIconTheme: IconThemeData(size: 26),
          type: BottomNavigationBarType.fixed,
          elevation: 5,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      home: const MainWrapper(),
    );
  }
}
