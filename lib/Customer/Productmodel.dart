import 'dart:convert';
import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final Uint8List? imageBase64;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageBase64,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageBase64: json['imageBase64'] != null
          ? base64Decode(json['imageBase64'])
          : null,
    );
  }
}
