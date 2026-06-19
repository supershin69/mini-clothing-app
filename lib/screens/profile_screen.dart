import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../screens/order_screen.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogoutSuccess;

  const ProfileScreen({super.key, required this.onLogoutSuccess});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ApiService _apiService;
  final _storage = const FlutterSecureStorage();
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(context);
    _profileFuture = _fetchProfileAndCheckAuth();
  }

  Future<UserModel> _fetchProfileAndCheckAuth() async {
    try {
      return await _apiService.fetchUserProfile();
    } catch (e) {
      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onLogoutSuccess();
          }
        });
      }
      rethrow;
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = _fetchProfileAndCheckAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: Theme.of(context).primaryColor,
        child: FutureBuilder<UserModel>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final user = snapshot.data!;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile Header Banner Container
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
                          user.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          user.email,
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

                  // Action Buttons Menu Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: ListTile(
                            onTap: () {
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
                            title: Text(
                              l10n.myOrders,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

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
                              l10n.logout,
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
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                const Text(
                  'ဒေတာဆွဲရာတွင် အမှားရှိနေပါသည်:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Pull down to retry",
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
