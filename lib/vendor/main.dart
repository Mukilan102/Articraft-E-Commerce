import 'vandc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();

  // Check if productId exists before deleting
  String? productId = await storage.read(key: 'selectedprodid');
  if (productId != null) {
    await storage.delete(key: 'selectedprodid');
  }
  runApp(const Articraft());
}

class Articraft extends StatefulWidget {
  const Articraft({super.key});

  @override
  State<Articraft> createState() => _ArticraftState();
}

class _ArticraftState extends State<Articraft> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: VandC());
  }
}
