import 'dart:convert';
import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'DioClient.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<dynamic> items = [];
  bool isLoading = true;
  final DioClient _dioClient = DioClient();

  @override
  void initState() {
    super.initState();
    _dioClient.setupInterceptors(context);
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      var response = await _dioClient.dio
          .get('http://localhost:5000/api/Vendor_Product_/getprod');
      setState(() {
        items = response.data;
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Product List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final item = items[index];
                final name = item['name'];
                final description = item['description'];
                final price = item['price'];
                final imageBase64 = item['imageBase64'];
                final dispercentage = item['dispercentage'];
                final disamount = item['disamount'];

                // Decode Base64 Image
                Uint8List? imageBytes;
                if (imageBase64 != null) {
                  imageBytes = Base64Decoder().convert(imageBase64);
                }

                // Calculate Discounted Amount and Percentage
                double? discountedAmount;
                double? discountedPercentage;

                if (dispercentage != null) {
                  // Calculate discounted amount using percentage
                  discountedAmount = price - (price * dispercentage / 100);
                  discountedPercentage = dispercentage;
                } else if (disamount != null) {
                  // Calculate discounted percentage using amount
                  discountedAmount = price - disamount;
                  discountedPercentage = (disamount / price) * 100;
                }

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: imageBytes != null
                              ? Image.memory(
                                  imageBytes,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image,
                                      size: 50, color: Colors.white),
                                ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    '\$${price.toString()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (discountedAmount != null &&
                                      discountedPercentage != null) ...[
                                    const SizedBox(width: 10),
                                    Text(
                                      '\$${discountedAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '(${discountedPercentage.toStringAsFixed(1)}% off)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
