import 'package:articraft_ui/Customer/AddressEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'UserDioClient.dart';
import 'User_Register.dart';
import 'package:articraft_ui/Customer/pg1_cust_home.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkStoredProductId() async {
    String? storedProductId = await _secureStorage.read(key: 'selectedprodid');

    if (storedProductId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AddressPage(productId: storedProductId),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ShopListScreen(),
        ),
      );
    }
  }

  Future<void> migrateCartToDatabase(String userEmail) async {
    String? cartData = await _secureStorage.read(key: "cart");

    if (cartData != null) {
      List<String> cartItems = List<String>.from(json.decode(cartData));

      final response = await _dio.post(
        'http://localhost:5000/api/Cart/migrateCart',
        data: {"email": userEmail, "cartItems": cartItems},
      );

      if (response.statusCode == 200) {
        await _secureStorage.delete(
            key: "cart"); // Clear local cart after migration
        print("Cart migrated successfully.");
      } else {
        print("Error migrating cart.");
      }
    }
  }

  Future<void> getUserType() async {
    // Retrieve token from secure storage
    String? token = await _secureStorage.read(key: 'token');

    if (token != null) {
      // Decode the token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Extract the userType (Role claim)
      String? userType = decodedToken['role']; // Claims use their types as keys

      // Print userType
      print("UserType: $userType");
    } else {
      print("No token found");
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final response = await UserDioClient().login(
          _emailController.text,
          _passwordController.text,
        );

        if (response.statusCode == 200) {
          await _secureStorage.write(
              key: 'token', value: response.data['token']);
          String? token = await _secureStorage.read(key: 'token');
          print('Stored token: $token');
          getUserType();
          await _secureStorage.write(
              key: "user_id", value: _emailController.text);
          print("email value: ${_emailController.text}");
          await migrateCartToDatabase(_emailController.text);

          // Delete stored cart data if present after migration
          String? storedCartData = await _secureStorage.read(key: "cart");
          if (storedCartData != null) {
            await _secureStorage.delete(key: "cart");
            print("Deleted local cart data after migration.");
          }

          // After login, check if a productId exists and navigate accordingly
          _checkStoredProductId();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter username' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter password' : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text('Login'),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => UserRegisterPage()),
                            );
                          },
                          child: Text('Create new account'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
