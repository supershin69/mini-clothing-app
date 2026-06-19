import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // အဖတ်ရသေးတဲ့ Notification အရေအတွက်ကို လှမ်းတွက်ပေးမယ့် Getter
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(BuildContext context, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = ApiService(context);
      _notifications = await apiService.fetchNotifications(userId);
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
        // UI မှာ ချက်ချင်း အပြောင်းအလဲမြင်ရအောင် Local State ကိုပါ Update လုပ်ပေးပါတယ်
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

  Future<void> markAllAsRead(BuildContext context, String userId) async {
    try {
      final apiService = ApiService(context);
      await apiService.markAllNotificationsAsRead(userId);

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

  // Logout လုပ်တဲ့အခါ Notification data တွေကို ရှင်းပစ်ဖို့
  void clearNotifications() {
    _notifications = [];
    notifyListeners();
  }
}
