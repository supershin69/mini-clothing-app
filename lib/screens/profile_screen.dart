import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart'; // ✅ UserModel အတွက် Import ပါ
import '../screens/order_screen.dart'; // ✅ OrderScreen အသစ်ကို Import ပါ
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogoutSuccess;

  const ProfileScreen({super.key, required this.onLogoutSuccess});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    // 🚀 Use the new wrapper method instead of calling apiService directly
    _profileFuture = _fetchProfileAndCheckAuth();
  }

  // 🛡️ Wrapper method to catch token death and redirect
  Future<UserModel> _fetchProfileAndCheckAuth() async {
    try {
      return await _apiService.fetchUserProfile();
    } catch (e) {
      // If an error happens, check if the interceptor wiped the token
      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        // Token is dead! Wait for the current UI frame to finish, then redirect.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onLogoutSuccess(); // 🚪 Kicks the user back to Login
          }
        });
      }

      rethrow; // Pass the error back to the FutureBuilder so it stops loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<UserModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          // ⏳ Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error State
          if (snapshot.hasError) {
            return Center(
              child: Text('ဒေတာဆွဲရာတွင် အမှားရှိနေပါသည်:\n${snapshot.error}'),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 👤 Header Profile Container (Dynamic User Data)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(
                          'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name, // ✅ Real Name
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        user.email, // ✅ Real Email
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ⚙️ Menu Options Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📦 1. Your Orders Field (Tappable Tile)
                      Card(
                        child: ListTile(
                          onTap: () {
                            // 🚀 Order Screen အသစ်ဆီသို့ တွန်းပို့ခြင်း
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderScreen(),
                              ),
                            );
                          },
                          leading: Icon(
                            Icons.shopping_bag_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: const Text(
                            'Your Orders',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 🔐 2. Logout Button Widget
                      Card(
                        child: ListTile(
                          onTap: () async {
                            await _apiService.logoutUser();
                            widget.onLogoutSuccess();
                          },
                          leading: Icon(
                            Icons.logout,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            'Logout',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
