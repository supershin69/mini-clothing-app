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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF))
            .copyWith(
              primary: const Color(0xFF1A1A1A),
              secondary: const Color(0xFF7C4DFF),
              background: const Color(0xFFF8F9FA),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF2D2D2D),
              error: Colors.redAccent,
            ),

        // Centralized component theming
        disabledColor: Colors.grey,
        hintColor: Colors.grey,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFF7C4DFF),
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
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      home: const MainWrapper(),
    );
  }
}
