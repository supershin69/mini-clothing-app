import 'package:clothing_shop/models/auth_models.dart';
import 'package:clothing_shop/models/notification_model.dart';
import 'package:clothing_shop/models/order_model.dart';
import 'package:clothing_shop/models/product_model.dart';
import 'package:clothing_shop/state/language_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class ApiService {
  late final Dio _dio = Dio();
  late final _storage = const FlutterSecureStorage();
  final BuildContext context;

  final String baseUrl = 'https://anthology-trombone-knelt.ngrok-free.dev';

  ApiService(this.context) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 50);
    _dio.options.receiveTimeout = const Duration(seconds: 50);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final langProvider = Provider.of<LanguageProvider>(
            context,
            listen: false,
          );
          final currentLanguage = langProvider.currentLocale.languageCode;

          options.headers['Accept-Language'] = currentLanguage;

          String? token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // 👈 [အသက်] URL ထဲမှာ {userId} ပုံသေစာသား ပါဝင်နေရင် Storage ထဲက ID နဲ့ လဲလှယ်ပေးမည့်စနစ်
          if (options.path.contains('{userId}')) {
            String? userId = await _storage.read(key: 'user_id');
            if (userId != null) {
              options.path = options.path.replaceAll('{userId}', userId);
            }
          }

          return handler.next(options);
        },

        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _storage.delete(key: 'auth_token');
            await _storage.delete(
              key: 'user_id',
            ); // Token ပျက်ရင် User ID ပါ ဖျက်မယ်
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<String> _getStoredUserId() async {
    final String? userId = await _storage.read(key: 'user_id');
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID missing. Please login again.');
    }
    return userId;
  }

  // ၁။ Register User API
  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone_no': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Success: OTP sent to email automatically.");
        return;
      } else {
        throw Exception('Failed to register user');
      }
    } on DioException catch (e) {
      print("Dio Error Response: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ၂။ Verify OTP API
  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'code': otp},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("verifyOtp Error: $e");
      return false;
    }
  }

  // ၃။ Login User API
  Future<AuthResponseModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final authResponse = AuthResponseModel.fromJson(data);

        // Token သိမ်းဆည်းခြင်း
        await _storage.write(
          key: 'auth_token',
          value: authResponse.accessToken,
        );

        // Store the user ID for notification API routes.
        final String authUserId = authResponse.user.id;
        final String apiUserId =
            data['user']?['id']?.toString() ??
            data['user']?['_id']?.toString() ??
            authUserId;

        if (apiUserId.isNotEmpty) {
          await _storage.write(key: 'user_id', value: apiUserId);
        }

        return authResponse;
      } else {
        throw Exception('Failed to login user');
      }
    } on DioException catch (e) {
      print("Dio Error Response: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ၄။ Fetch Products API
  Future<List<ProductModel>> fetchProducts() async {
    try {
      print("Calling API: ${_dio.options.baseUrl}/products");
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } on DioException catch (e) {
      print("Dio Error Response: ${e.response?.data}");
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ၅။ Logout User API
  Future<void> logoutUser() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(
      key: 'user_id',
    ); // 👈 Logout လုပ်ရင် user_id ပါ ရှင်းပစ်မယ်
  }

  // ၆။ Fetch User Profile API
  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        final user = UserModel.fromJson(data);

        // 👈 [ပြင်ဆင်ချက်] Profile ဆွဲလို့ အောင်မြင်တိုင်း နောက်ကွယ်က Interceptor သုံးနိုင်အောင် id ကို အမြဲ Update လုပ်သိမ်းပေးထားပါမယ်
        await _storage.write(
          key: 'user_id',
          value: user.id.toString(),
        ); // မင်းရဲ့ model id field က name အတိုင်း ပြောင်းပေးပါ (ဥပမာ- user.id သို့မဟုတ် user.sId)

        return user;
      } else {
        throw Exception('Failed to load user profile');
      }
    } on DioException catch (e) {
      print("Dio Error Response: ${e.response?.data}");
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ၇။ Create Order (Checkout) API
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _dio.post('/orders', data: {'items': items});

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Order Placed Successfully on Backend.");
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to place order');
      }
    } on DioException catch (e) {
      print("Dio Error Response: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ၈။ Fetch User Orders API
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final response = await _dio.get('/orders/me');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } on DioException catch (e) {
      print("Dio Error Response: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ၉။ Fetch User Notifications API
  // 👈 [ပြင်ဆင်ချက်] String userId Parameter ကို ဖြုတ်လိုက်ပြီး အစားထိုးစနစ် ပြောင်းလဲထားပါတယ်
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final userId = await _getStoredUserId();
      final response = await _dio.get('/notifications/user/$userId');
      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> data;

        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          if (responseData['data'] is List) {
            data = responseData['data'];
          } else if (responseData['notifications'] is List) {
            data = responseData['notifications'];
          } else if (responseData['results'] is List) {
            data = responseData['results'];
          } else {
            throw Exception(
              'Unexpected notification payload format: ${responseData.keys.toList()}',
            );
          }
        } else {
          throw Exception(
            'Unexpected notification payload type: ${responseData.runtimeType}',
          );
        }

        return data.map((item) => NotificationModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    }
  }

  // ၁၀။ Mark Single Notification as Read API
  Future<void> markNotificationAsRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    }
  }

  // ၁၁။ Mark All Notifications as Read API
  // 👈 [ပြင်ဆင်ချက်] String userId Parameter ကို ဖြုတ်လိုက်ပါပြီ
  Future<void> markAllNotificationsAsRead() async {
    try {
      final userId = await _getStoredUserId();
      await _dio.patch('/notifications/user/$userId/read-all');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    }
  }
}
