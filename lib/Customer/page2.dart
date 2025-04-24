import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final Uint8List? imageBase64;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageBase64,
    required this.category,
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
    );
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

  final List<String> categories = [
    'All',
    'Chairs',
    'Sofas',
    'Tables',
    'Beds',
    'Wardrobes'
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      var response = await _dio
          .get('http://localhost:5000/api/Customer/products_for_page2');

      if (response.data is List) {
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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: ${e.toString()}')),
      );
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            // Category filter chips
            Container(
              height: 50,
              color: Colors.white,
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
                        setState(() {
                          selectedCategory = categories[index];
                        });
                      },
                      selectedColor: Colors.blue[100],
                      labelStyle: TextStyle(
                        color: selectedCategory == categories[index]
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            // Product list
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: getFilteredProducts().length,
                      itemBuilder: (context, index) {
                        final product = getFilteredProducts()[index];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
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
          child: _buildProductImage(product),
        ),
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              product.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
                SizedBox(width: 10),
                Text(
                  product.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigation to product detail would go here
        },
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imageBase64 == null) {
      return _buildPlaceholderImage();
    }

    return Image.memory(
      product.imageBase64!,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error displaying image: $error');
        return _buildPlaceholderImage();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: Icon(Icons.image, color: Colors.grey[400]),
    );
  }
}
