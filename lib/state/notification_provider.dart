import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // 👈 🛠 userId parameter ကို ဖြုတ်လိုက်ပါပြီ
  Future<void> loadNotifications(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = ApiService(context);
      _notifications = await apiService
          .fetchNotifications(); // API Service က Interceptor အတိုင်း အလုပ်လုပ်ပါမယ်
    } catch (e) {
      print("Error loading notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(BuildContext context, String id) async {
    try {
      final apiService = ApiService(context);
      await apiService.markNotificationAsRead(id);

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          orderId: _notifications[index].orderId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      print("Error marking single read: $e");
    }
  }

  // 👈 🛠 userId parameter ကို ဖြုတ်လိုက်ပါပြီ
  Future<void> markAllAsRead(BuildContext context) async {
    try {
      final apiService = ApiService(context);
      await apiService.markAllNotificationsAsRead();

      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          orderId: n.orderId,
          title: n.title,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print("Error marking all read: $e");
    }
  }

  void clearNotifications() {
    _notifications = [];
    notifyListeners();
  }
}
