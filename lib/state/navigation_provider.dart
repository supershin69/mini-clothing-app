import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToHome() => changeTab(0);
  void goToClothing() => changeTab(1);
  void goToCart() => changeTab(2);
  void goToNotifications() => changeTab(3);
  void goToProfile() => changeTab(4);
}
