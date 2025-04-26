import 'dart:convert';
import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final Uint8List? imageBase64;
  final double? dispercentage;
  final double? disamount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageBase64,
    this.dispercentage,
    this.disamount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    Uint8List? imageData;
    if (json['imageBase64'] != null && json['imageBase64'] is String) {
      try {
        String imageString = json['imageBase64']!;
        if (imageString.startsWith('data:image')) {
          imageString = imageString.split(',').last;
        }
        imageString = imageString.trim();
        imageData = base64.decode(imageString);
      } catch (e) {
        print('Failed to decode image: $e');
      }
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      imageBase64: imageData,
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
