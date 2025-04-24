import 'package:flutter/material.dart';
import 'User_Login.dart'; 

void redirectToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false,
  );
}
