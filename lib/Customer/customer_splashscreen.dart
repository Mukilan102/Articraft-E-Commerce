import 'package:flutter/material.dart';
import 'package:articraft_ui/Customer/UserDioClient.dart';
import 'package:articraft_ui/Customer/AddressEntry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'User_login.dart';

class CustomerSplashScreen extends StatefulWidget {
  final String productId;
  const CustomerSplashScreen({super.key, required this.productId});

  @override
  _CustomerSplashScreenState createState() => _CustomerSplashScreenState();
}

class _CustomerSplashScreenState extends State<CustomerSplashScreen> {
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    final isValid = await UserDioClient().isTokenValid();
    final productId = await _secureStorage.read(key: 'selectedprodid');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isValid
              ? AddressPage(
                  productId: productId ?? '',
                )
              : LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
