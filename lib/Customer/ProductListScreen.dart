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
        automaticallyImplyLeading: false,
        title: Text(widget.shopName,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey, // Changed to gray
                fontSize: 18)), // Reduced font size
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Color.fromARGB(255, 250, 250, 250),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
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
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child:
                                    Icon(Icons.image, color: Colors.grey[400]),
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
                          Row(
                            children: [
                              if (product.getDiscountedAmount() != null) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 186, 128, 128),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '\$${product.getDiscountedAmount()!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 14),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey[600],
                                      fontSize: 12),
                                ),
                              ] else
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 186, 128, 128),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 15),
                                  ),
                                ),
                              SizedBox(width: 5),
                              if (product.getDiscountedPercentage() != null)
                                Text(
                                  '(${product.getDiscountedPercentage()!.toStringAsFixed(1)}% off)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[300],
                                      fontSize: 12),
                                ),
                            ],
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
      ),
    );
  }
}
