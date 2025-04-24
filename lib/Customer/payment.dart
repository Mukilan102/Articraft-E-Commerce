import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  

  const PaymentPage(
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Text("Payment Page (Under Construction)"),
      ),
    );
  }
}
