import 'dart:io'; // File အမျိုးအစား သုံးနိုင်ဖို့ ဒါကို ထိပ်ဆုံးမှာ ထည့်လိုက်ပါတယ်
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
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle unauthorized error (e.g., token expired)
            await _storage.delete(key: 'auth_token');
          }
          return handler.next(e);
        }
      )
    );
  }

  //  ၁။ Server ဆီကို OTP ပို့ခိုင်းဖို့ လှမ်းပြောတဲ့ API (အသစ်တိုးထားတာ)
  Future<void> sendOtp({required String email}) async {
    try {
      await _dio.post('/auth/register', data: {'email': email});
    } on DioException catch (e) {
      print("❌ sendOtp Dio Error: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'OTP ပို့ခြင်း မအောင်မြင်ပါ');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ၂။ ရိုက်လိုက်တဲ့ OTP က မှန်၊ မမှန် စစ်ပေးတဲ့ API (အသစ်တိုးထားတာ)
  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ verifyOtp Error: $e");
      return false;
    }
  }

  // 🚀 ၃။ RegisterUser (ပုံဖိုင်နဲ့ Phone နံပါတ်ပါ တွဲပို့နိုင်အောင် FormData စနစ် ပြောင်းလဲထားပါတယ်)
  Future<AuthResponseModel> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    File? imageFile, 
  }) async {
    try {
      // 📝 JSON အစား ပုံဖိုင်တင်လို့ရမယ့် FormData ပြောင်းလဲခြင်း
      Map<String, dynamic> mapData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      };

      // ပုံရွေးထားတာ ရှိရင် ဖိုင်ကိုပါ တွဲထည့်မယ်
      if (imageFile != null) {
        mapData['profilePicture'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(mapData);

      // 💡 ပုံပါရင် Content-Type က automatic multipart ဖြစ်သွားမှာမို့ options ကို သီးသန့်မလိုပါဘူး
      final response = await _dio.post('/auth/register', data: formData);

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
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // 🛍️ ၄။ Fetch Products API
  Future<List<ProductModel>> fetchProducts() async {
    try {
      print("🚀 Calling API: ${_dio.options.baseUrl}/products");
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

  // 🔐 ၅။ Login User API
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
      throw Exception(e.response?.data['message'] ?? 'Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // 🚪 ၆။ Logout User API
  Future<void> logoutUser() async {
    await _storage.delete(key: 'auth_token');
  }

  // 👤 ၇။ Fetch User Profile API
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