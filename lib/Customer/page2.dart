import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'product_detail_screen.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final Uint8List? imageBase64;
  final String category;
  final double? dispercentage;
  final double? disamount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageBase64,
    required this.category,
    this.dispercentage,
    this.disamount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    Uint8List? imageData;

    if (json['imageBase64'] != null && json['imageBase64'] is String) {
      try {
        String imageString = json['imageBase64']!;

        // Remove data URI prefix if present
        if (imageString.startsWith('data:image')) {
          imageString = imageString.split(',').last;
        }

        // Trim any whitespace or newlines
        imageString = imageString.trim();

        // Decode the base64 string
        imageData = base64.decode(imageString);

        debugPrint(
            'Successfully decoded image with length: ${imageData.length} bytes');
      } catch (e) {
        debugPrint('Failed to decode image: $e');
        if (json['imageBase64'] is String) {
          debugPrint(
              'Image string start: ${(json['imageBase64'] as String).substring(0, 100)}...');
        }
      }
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      imageBase64: imageData,
      category: json['category']?.toString() ?? 'Uncategorized',
      dispercentage: json['dispercentage'] != null
          ? (json['dispercentage'] as num).toDouble()
          : null,
      disamount: json['disamount'] != null
          ? (json['disamount'] as num).toDouble()
          : null,
    );
  }

  double? getDiscountedAmount() {
    if (dispercentage != null) {
      return price - (price * dispercentage! / 100);
    } else if (disamount != null) {
      return price - disamount!;
    }
    return null;
  }

  double? getDiscountedPercentage() {
    if (dispercentage != null) {
      return dispercentage;
    } else if (disamount != null) {
      return (disamount! / price) * 100;
    }
    return null;
  }
}

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final Dio _dio = Dio();
  List<Product> products = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  bool _mounted = true;

  final List<String> categories = [
    'All',
    'Chairs',
    'Sofas',
    'Tables',
    'Beds',
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchProducts() async {
    if (!_mounted) return;

    try {
      var response = await _dio
          .get('http://localhost:5000/api/Customer/products_for_page2');

      if (response.data is List && _mounted) {
        setState(() {
          products = (response.data as List)
              .map((json) => Product.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Invalid response format: Expected a list');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      if (_mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: ${e.toString()}')),
        );
      }
    }
  }

  List<Product> getFilteredProducts() {
    if (selectedCategory == 'All') {
      return products;
    }
    return products
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Furniture Store',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey, // Changed to gray
                fontSize: 16)), // Reduced font size
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Color.fromARGB(255, 250, 250, 250),
        child: Column(
          children: [
            Container(
              height: 50,
              color: Color.fromARGB(250, 250, 250, 250),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(categories[index]),
                      selected: selectedCategory == categories[index],
                      onSelected: (selected) {
                        if (_mounted) {
                          setState(() {
                            selectedCategory = categories[index];
                          });
                        }
                      },
                      selectedColor: Colors.red[300],
                      backgroundColor: Colors.red[80],
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selectedCategory == categories[index]
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: getFilteredProducts().length,
                      itemBuilder: (context, index) {
                        final product = getFilteredProducts()[index];
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
                                      child: Icon(Icons.image,
                                          color: Colors.grey[400]),
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
                                    if (product.getDiscountedAmount() !=
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
                                          '\$${product.getDiscountedAmount()!.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              fontSize: 14),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey[600],
                                            fontSize: 12),
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
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              fontSize: 15),
                                        ),
                                      ),
                                    SizedBox(width: 5),
                                    if (product.getDiscountedPercentage() !=
                                        null)
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
          ],
        ),
      ),
    );
  }
}
