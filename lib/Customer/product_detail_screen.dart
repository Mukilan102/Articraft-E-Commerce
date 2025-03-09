import 'package:articraft_ui/Customer/customer_splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'Productmodel.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isLoading = true;
  Product? product;
  final _secureStorage = FlutterSecureStorage();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      var response = await _dio.get(
          'http://localhost:5000/api/Customer/getProductById/${widget.productId}');

      setState(() {
        product = Product.fromJson(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  /// Function to add product to the cart (for guest users)
  Future<void> addToCart() async {
    try {
      String? cartData = await _secureStorage.read(key: "cart");
      List<String> cartItems =
          cartData != null ? List<String>.from(json.decode(cartData)) : [];

      // Add new product ID if not already in the cart
      if (!cartItems.contains(widget.productId)) {
        cartItems.add(widget.productId);
      }

      await _secureStorage.write(key: "cart", value: json.encode(cartItems));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added to cart successfully!")),
      );
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : product == null
              ? Center(child: Text("Failed to load product"))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: product!.imageBase64 != null
                          ? Image.memory(product!.imageBase64!,
                              fit: BoxFit.cover)
                          : Image.asset('assets/placeholder.png',
                              fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product!.name,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "\$${product!.price.toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Text(
                            product!.description,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 30),

                          /// "Add to Cart" Button
                          ElevatedButton(
                            onPressed: addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Add to Cart",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),

                          SizedBox(height: 10), // Space between buttons

                          /// "Buy Now" Button
                          ElevatedButton(
                            onPressed: () async {
                              await _secureStorage.write(
                                  key: 'selectedprodid',
                                  value: widget.productId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CustomerSplashScreen(
                                        productId: widget.productId)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Buy Now",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
