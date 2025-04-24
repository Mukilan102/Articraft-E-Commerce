// DioClient.dart
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'navigation_helper.dart'; // Import the new helper

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  final Dio _dio =
      Dio(BaseOptions(baseUrl: 'http://localhost:5000/api/auth'));
  final _storage = FlutterSecureStorage();

  void setupInterceptors(BuildContext context) {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print("Unauthorized! Redirecting to login...");

            await _storage.delete(key: 'token');

            WidgetsBinding.instance.addPostFrameCallback((_) {
              redirectToLogin(context); // Use the global function
            });
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<bool> isTokenValid() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    try {
      // Check if the token is expired
      if (JwtDecoder.isExpired(token)) return false;

      // Decode the token to extract claims
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Get the user type from token
      String? userType = decodedToken['role']; // 'role' is the claim type in your backend

      // If user type is 'customer', return false
      if (userType == "customer") return false;

      return true; // Token is valid and user is not a customer
    } catch (e) {
      return false; // If decoding fails, treat as invalid token
    }
  }

  Future<Response> login(String email, String password) async {
    return await _dio
        .post('/vendor/login', data: {'email': email, 'password': password});
  }

  Future<Response> register(String username,String password,String confirmPassword,String email,String mobile,
    String shopname, String description, String location, String base64Image) async {
      return await _dio.post('/vendor/register', data: {
      'userName': username,
      'mobileNo': mobile,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'shopName':shopname,
      'description':description,
      'location':location,
      'image':base64Image
    });
  }
}
