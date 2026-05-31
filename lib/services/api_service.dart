import 'package:clothing_shop/models/auth_models.dart';
import 'package:clothing_shop/models/product_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  final String baseUrl = 'https://anthology-trombone-knelt.ngrok-free.dev';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
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
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle unauthorized error (e.g., token expired)
            // You can add logic to refresh the token or redirect to login
          }
          return handler.next(e);
        }
      )
    );
  }

  Future<List<ProductModel>> fetchProducts() async {
    try {
      print("🚀 Calling API: ${_dio.options.baseUrl}/products");
      print("🚀 Request Headers: ${_dio.options.headers}");
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } on DioException catch (e) {
      print("❌ Dio Error Response: ${e.response?.data}");
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<AuthResponseModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final authResponse = AuthResponseModel.fromJson(data);
        await _storage.write(key: 'auth_token', value: authResponse.accessToken);
        return authResponse;
      } else {
        throw Exception('Failed to register user');
      }
    } on DioException catch (e) {
      print("❌ Dio Error Response: ${e.response?.data}");
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<AuthResponseModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final authResponse = AuthResponseModel.fromJson(data);
        await _storage.write(key: 'auth_token', value: authResponse.accessToken);
        return authResponse;
      } else {
        throw Exception('Failed to login user');
      }
    } on DioException catch (e) {
      print("❌ Dio Error Response: ${e.response?.data}");
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> logoutUser() async {
    await _storage.delete(key: 'auth_token');
  }

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
      print("❌ Dio Error Response: ${e.response?.data}");
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
}