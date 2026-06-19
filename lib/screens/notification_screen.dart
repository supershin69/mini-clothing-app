import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:clothing_shop/state/notification_provider.dart';
import 'package:clothing_shop/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead(
                context,
                userId,
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Text(
                l10n.noNotification,
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadNotifications(context, userId),
            child: ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final noti = provider.notifications[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: noti.isRead
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      if (!noti.isRead) {
                        provider.markAsRead(context, noti.id);
                      }
                    },
                    leading: CircleAvatar(
                      backgroundColor: noti.isRead
                          ? Colors.grey[300]
                          : Theme.of(context).primaryColor,
                      child: Icon(
                        noti.orderId != null
                            ? Icons.local_shipping
                            : Icons.notifications,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      noti.title,
                      style: TextStyle(
                        fontWeight: noti.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          noti.message,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: !noti.isRead
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
