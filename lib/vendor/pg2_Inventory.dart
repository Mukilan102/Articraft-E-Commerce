import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'DioClient.dart'; // Import the DioClient

class UploadProductPage extends StatefulWidget {
  const UploadProductPage({super.key});

  @override
  _UploadProductPageState createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  final _formKey = GlobalKey<FormState>();
  XFile? _image;
  bool _isUploading = false;
  String? _selectedCategory; // Add this for category selection

  // Add the categories list (excluding 'All')
  final List<String> categories = [
    'Chairs',
    'Sofas',
    'Tables',
    'Beds',
    'Wardrobes'
  ];

  // TextEditingControllers for all fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountPercentageController =
      TextEditingController(); // For percentage
  final TextEditingController _discountAmountController =
      TextEditingController(); // For amount

  // Get the singleton instance of DioClient
  final DioClient _dioClient = DioClient();

  @override
  void initState() {
    super.initState();
    // Initialize Dio Interceptors here
    _dioClient.setupInterceptors(context);

    // Add listeners to enforce the constraint
    _discountPercentageController.addListener(() {
      if (_discountPercentageController.text.isNotEmpty) {
        _discountAmountController.clear();
      }
    });

    _discountAmountController.addListener(() {
      if (_discountAmountController.text.isNotEmpty) {
        _discountPercentageController.clear();
      }
    });
  }

  @override
  void dispose() {
    // Clean up all controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPercentageController.dispose();
    _discountAmountController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _discountPercentageController.clear();
    _discountAmountController.clear();
    setState(() {
      _image = null;
      _selectedCategory = null; // Clear selected category
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: ${e.toString()}');
    }
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate() ||
        _image == null ||
        _selectedCategory == null) {
      _showErrorSnackBar(
          'Please fill all fields, select a category, and select an image');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final bytes = await File(_image!.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      String fullUrl = 'http://localhost:5000/api/Vendor_Product_/prod';

      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'image': base64Image,
        'dispercentage': _discountPercentageController.text.isNotEmpty
            ? double.tryParse(_discountPercentageController.text)
            : null,
        'disamount': _discountAmountController.text.isNotEmpty
            ? double.tryParse(_discountAmountController.text)
            : null,
        'category': _selectedCategory // Use the selected category
      };

      // Send request using DioClient instance
      final response = await _dioClient.dio.post(
        fullUrl,
        data: data,
      );

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200) {
        _clearForm();
        _formKey.currentState!.reset();
        _showSuccessSnackBar('Product uploaded successfully!');
      } else {
        _showErrorSnackBar('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackBar('Error uploading product: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Enter price';
    try {
      double price = double.parse(value);
      if (price <= 0) return 'Price must be greater than 0';
    } catch (e) {
      return 'Enter valid price';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Enter product name' : null,
                enabled: !_isUploading,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.trim().isEmpty ? 'Enter description' : null,
                enabled: !_isUploading,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: _validatePrice,
                enabled: !_isUploading,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountPercentageController,
                      decoration: InputDecoration(
                        labelText: 'Percentage',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      enabled: !_isUploading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountAmountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      enabled: !_isUploading,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Add Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _isUploading
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickImage,
                icon: Icon(Icons.image),
                label: Text('Pick Image'),
              ),
              if (_image != null) ...[
                SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_image!.path), fit: BoxFit.cover),
                  ),
                ),
              ],
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: _isUploading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _uploadProduct,
                        icon: Icon(Icons.upload),
                        label: Text('Upload Product'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
