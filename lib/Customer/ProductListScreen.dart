import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'Productmodel.dart';

import 'product_detail_screen.dart'; // Import the ProductDetailScreen

class ProductListScreen extends StatefulWidget {
  final String shopName;

  const ProductListScreen({super.key, required this.shopName});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  bool isLoading = true;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      var response = await _dio.get(
          'http://localhost:5000/api/Customer/getProductsByShop/${widget.shopName}');

      setState(() {
        products = (response.data as List)
            .map((json) => Product.fromJson(json))
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
        title: Text(widget.shopName,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          product.description,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green),
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
                );
              },
            ),
    );
  }
}

