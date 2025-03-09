import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shimmer/shimmer.dart'; // Import shimmer for eye-catching effect

import 'ProductListScreen.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  _ShopListScreenState createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  List<Shop> shops = [];
  bool isLoading = true;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  Future<void> fetchShops() async {
    try {
      var response = await _dio.get('http://localhost:5000/api/Customer/getallprod');

      setState(() {
        shops = (response.data as List)
            .map((json) => Shop.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? _buildShimmerEffect() // Show shimmer while loading
            : shops.isEmpty
                ? const Center(child: Text("No shops available"))
                : GridView.builder(
                    itemCount: shops.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two shops per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8, // Adjust card aspect ratio
                    ),
                    itemBuilder: (context, index) {
                      return _buildShopCard(shops[index]);
                    },
                  ),
      ),
    );
  }

  // Shimmer Effect for Loading State
  Widget _buildShimmerEffect() {
    return GridView.builder(
      itemCount: 6, // Show 6 shimmer items
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }

  // Shop Card with Animations
  Widget _buildShopCard(Shop shop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => ProductListScreen(shopName: shop.name),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Hero(
        tag: shop.name,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Positioned.fill(
                  child: shop.image != null
                      ? Image.memory(
                          shop.image!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/placeholder.png',
                          fit: BoxFit.cover,
                        ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.3),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    shop.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Shop Model
class Shop {
  final String name;
  final Uint8List? image;

  Shop({
    required this.name,
    this.image,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      name: json['shopName'] ?? "Unknown Shop",
      image: _decodeBase64Image(json['image']),
    );
  }

  static Uint8List? _decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("Error decoding base64 image: $e");
      return null;
    }
  }
}
