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
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _dioClient.setupInterceptors(context);
    _fetchCartProducts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchCartProducts() async {
    if (!_mounted) return;

    final productIdsJson = await _storage.read(key: 'cart');

    List<String> productIds = [];
    if (productIdsJson != null && productIdsJson.isNotEmpty) {
      productIds = List<String>.from(jsonDecode(productIdsJson));
    }

    bool isTokenValid = await _dioClient.isTokenValid();

    if (!isTokenValid && productIds.isEmpty) {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
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

      if (response.statusCode == 200 && _mounted) {
        setState(() {
          _products = (response.data as List)
              .map((item) => Product.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to fetch products. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
      print('Error fetching products: $e');
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching cart products. Please try again.')),
        );
      }
    }
  }

  Future<void> _removeItem(String productId) async {
    if (!_mounted) return;

    try {
      bool isTokenValid = await _dioClient.isTokenValid();

      if (isTokenValid) {
        // For logged-in users - call API
        await _dioClient.dio.delete(
          'http://localhost:5000/api/Cart/removeItem/$productId',
        );
      } else {
        // For guest users - update local storage
        final productIdsJson = await _storage.read(key: 'cart');
        if (productIdsJson != null) {
          List<String> productIds =
              List<String>.from(jsonDecode(productIdsJson));
          productIds.remove(productId);
          await _storage.write(key: 'cart', value: jsonEncode(productIds));
        }
      }

      // Update UI
      if (_mounted) {
        setState(() {
          _products.removeWhere((product) => product.id == productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item removed from cart')),
        );
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item from cart')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[200],
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _products.isEmpty
                ? Center(child: Text('Add something to the cart'))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Dismissible(
                        key: Key(product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) => _removeItem(product.id),
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 10),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: product.imageBase64 != null
                                  ? Image.memory(
                                      product.imageBase64!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/placeholder.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  product.description,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
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
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
