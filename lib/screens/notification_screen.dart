import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:clothing_shop/state/notification_provider.dart';
import 'package:clothing_shop/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  // 👈 🛠 userId constructor ကို လုံးဝ ဖြုတ်ပစ်လိုက်ပါပြီ
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // စာမျက်နှာပွင့်တာနဲ့ Parameter မလိုဘဲ အလိုအလျောက် Noti ဆွဲပါမယ်
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            return RefreshIndicator(
              onRefresh: () =>
                  provider.loadNotifications(context), // 👈 clean ခေါ်ယူမှု
              color: Theme.of(context).primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(
                      l10n.noNotification,
                      style: TextStyle(color: Theme.of(context).disabledColor),
                    ),
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ElevatedButton Panel for Mark all as read
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.markAllAsRead(context); // 👈 clean ခေါ်ယူမှု
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text(
                      'Mark all as read',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Notification List View Area
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      provider.loadNotifications(context), // 👈 clean ခေါ်ယူမှု
                  color: Theme.of(context).primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 16),
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
                              : Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.05),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
