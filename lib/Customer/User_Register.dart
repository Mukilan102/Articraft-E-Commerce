

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'User_Login.dart';
import 'UserDioClient.dart';


class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  

  // Existing controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _isLoading = false;

  // Password validation helper
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Email validation helper
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Mobile Number validation helper
  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mobile number';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }
  
  

  

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if passwords match before making the API call
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        
        // Send registration request with all fields
        final response = await UserDioClient().register(
            _usernameController.text,
            _passwordController.text,
            _confirmPasswordController.text,
            _emailController.text,
            _mobileController.text
            
            );

        if (response.statusCode == 201) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Registration successful! Please login to continue.'),
                duration: Duration(seconds: 2),
              ),
            );

            // Wait for snackbar to be visible before navigation
            await Future.delayed(Duration(seconds: 2));

            // Navigate to login page and remove the registration page from stack
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          }
        }
      } catch (e) {
        // Detailed error handling
        String errorMessage = 'Registration failed';
        if (e is DioException) {
          if (e.response?.statusCode == 409) {
            errorMessage = 'Username or Email already exists';
          } else if (e.response?.data['message'] != null) {
            errorMessage = e.response?.data['message'];
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter username' : null,
                ),
                SizedBox(height: 16),
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 16),
                // Mobile Number field
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateMobile,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    helperText: 'Min 8 chars, 1 uppercase, 1 number',
                  ),
                  obscureText: true,
                  validator: _validatePassword,
                ),
                SizedBox(height: 16),
                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please confirm password' : null,
                ),
                
                SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text('Register'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
