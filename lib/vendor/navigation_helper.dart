
import 'package:flutter/material.dart';
import 'Login_page.dart'; 

void redirectToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false,
  );
}
