import 'package:clothing_shop/models/auth_models.dart';
import 'package:clothing_shop/models/order_model.dart';
import 'package:clothing_shop/models/product_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  final String baseUrl = 'https://anthology-trombone-knelt.ngrok-free.dev';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 50);
    _dio.options.receiveTimeout = const Duration(seconds: 50);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      //!'ngrok-skip-browser-warning': 'true',
      //!'bypass-tunnel-reminder': 'true',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle unauthorized error (e.g., token expired)
            await _storage.delete(key: 'auth_token');
          }
          return handler.next(e);
        },
      ),
    );
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
        print(" uccess: OTP sent to email automatically.");
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
        await _storage.write(
          key: 'auth_token',
          value: authResponse.accessToken,
        );
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
  }

  // ၆။ Fetch User Profile API
  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        return UserModel.fromJson(data);
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

  // ၇။ Create Order (Checkout) API - Updated for the new JSON schema
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
      // The backend should know which user to fetch orders for based on the Bearer Token
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
}
