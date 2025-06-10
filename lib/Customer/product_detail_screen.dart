import 'package:articraft_ui/Customer/customer_splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'Productmodel.dart';
import 'UserDioClient.dart';
import 'package:articraft_ui/Customer/AR.dart';

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
  bool isImageExpanded = false;

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
      // Check if user is logged in and token is valid
      String? token = await _secureStorage.read(key: 'token');
      bool isLoggedIn = token != null && await UserDioClient().isTokenValid();

      if (isLoggedIn) {
        print('Token found and valid: $token'); // Debug log
        // For logged-in users - add to database cart
        try {
          final response = await _dio.post(
            'http://localhost:5000/api/Cart/addToCart',
            data: {"productId": widget.productId},
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json'
              },
            ),
          );

          print('Response status: ${response.statusCode}'); // Debug log
          print('Response data: ${response.data}'); // Debug log

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Added to cart successfully!")),
            );
          } else {
            throw Exception(
                'Failed to add to cart. Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('API Error details: $e'); // Debug log
          throw Exception('API Error: $e');
        }
      } else {
        // For guest users - store locally
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
      }
    } catch (e) {
      print("Error adding to cart: $e"); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add to cart: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Product Details",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : product == null
              ? Center(child: Text("Failed to load product"))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isImageExpanded = true;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 32,
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 71, 71, 71)
                                              .withOpacity(0.3),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: product!.imageBase64 != null
                                      ? Image.memory(
                                          product!.imageBase64!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/placeholder.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product!.name,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (product!.getDiscountedAmount() !=
                                        null) ...[
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 186, 128, 128),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '\$${product!.getDiscountedAmount()!.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              fontSize: 18),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '\$${product!.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey[600],
                                            fontSize: 16),
                                      ),
                                    ] else
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 186, 128, 128),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '\$${product!.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              fontSize: 18),
                                        ),
                                      ),
                                    SizedBox(width: 5),
                                    if (product!.getDiscountedPercentage() !=
                                        null)
                                      Text(
                                        '(${product!.getDiscountedPercentage()!.toStringAsFixed(1)}% off)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[300],
                                            fontSize: 16),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(Icons.location_on,
                                            "Location", product!.location),
                                        SizedBox(height: 10),
                                        _buildInfoRow(Icons.phone, "Contact",
                                            product!.mobileno),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 150,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            product!.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ARViewScreen(
                                            productId: widget.productId),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.view_in_ar,
                                      color: Colors.white),
                                  label: Text(
                                    "View in AR",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await _secureStorage.write(
                                              key: 'selectedprodid',
                                              value: widget.productId);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomerSplashScreen(
                                                        productId:
                                                            widget.productId)),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 255, 200, 200),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.shopping_bag,
                                                color: Colors.red[300]),
                                            SizedBox(width: 8),
                                            Text("Buy Now",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red[300],
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: addToCart,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[400],
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.shopping_cart,
                                                color: Colors.white),
                                            SizedBox(width: 8),
                                            Text("Add to Cart",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isImageExpanded)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isImageExpanded = false;
                            });
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0.9),
                            child: Center(
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: product!.imageBase64 != null
                                    ? Image.memory(
                                        product!.imageBase64!,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.asset(
                                        'assets/placeholder.png',
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

Widget _buildInfoRow(IconData icon, String title, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Colors.grey[600]),
      SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
