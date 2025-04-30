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
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Product List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: const Color.fromARGB(255, 250, 250, 250),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: items.length,
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
                    discountedAmount = price - (price * dispercentage / 100);
                    discountedPercentage = dispercentage;
                  } else if (disamount != null) {
                    discountedAmount = price - disamount;
                    discountedPercentage = (disamount / price) * 100;
                  }

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageBytes != null
                            ? Image.memory(
                                imageBytes,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              if (discountedAmount != null) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color.fromARGB(255, 186, 128, 128),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '\$${discountedAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ] else
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color.fromARGB(255, 186, 128, 128),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '\$${price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              SizedBox(width: 5),
                              if (discountedPercentage != null)
                                Text(
                                  '(${discountedPercentage.toStringAsFixed(1)}% off)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[300],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
