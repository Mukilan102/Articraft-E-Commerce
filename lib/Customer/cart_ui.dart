import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'Productmodel.dart';
import 'UserDioClient.dart';
import 'product_detail_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final UserDioClient _dioClient = UserDioClient();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dioClient.setupInterceptors(context);
    _fetchCartProducts();
  }

  Future<void> _fetchCartProducts() async {
    final productIdsJson = await _storage.read(key: 'cart');

    List<String> productIds = [];
    if (productIdsJson != null && productIdsJson.isNotEmpty) {
      productIds = List<String>.from(jsonDecode(productIdsJson));
    }

    bool isTokenValid = await _dioClient.isTokenValid();

    // If the token is not valid AND there are no product IDs, stop here
    if (!isTokenValid && productIds.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      Response response;

      if (isTokenValid) {
        response = await _dioClient.dio.get(
          'http://localhost:5000/api/Cart/getprodbycustomertoken',
        );
      } else {
        response = await _dioClient.dio.post(
          'http://localhost:5000/api/Cart/getprodbycustomer',
          data: productIds,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
      }

      if (response.statusCode == 200) {
        setState(() {
          _products = (response.data as List)
              .map((item) => Product.fromJson(item))
              .toList();
          _isLoading = false;
        });

        // Delete cart data from secure storage after successful fetch
      } else {
        throw Exception(
            'Failed to fetch products. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error fetching cart products. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(child: Text('Add something to the cart'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      child: ListTile(
                        leading: product.imageBase64 != null
                            ? Image.memory(product.imageBase64!,
                                width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.image, size: 50),
                        title: Text(product.name),
                        subtitle: Text(product.description),
                        trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: product.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
