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
      SnackBar(
          content: Text(message),
          backgroundColor: const Color.fromARGB(255, 200, 200, 200)),
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
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Upload New Product',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Add your product to the marketplace',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildInputField(
                    label: 'Product Name',
                    controller: _nameController,
                    icon: Icons.shopping_bag_outlined,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Enter product name' : null,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    label: 'Description',
                    controller: _descriptionController,
                    icon: Icons.description_outlined,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Enter description' : null,
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    label: 'Price',
                    controller: _priceController,
                    icon: Icons.attach_money_outlined,
                    validator: _validatePrice,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    prefixText: '\$',
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'Discount Percentage',
                          controller: _discountPercentageController,
                          icon: Icons.percent_outlined,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              try {
                                double percentage = double.parse(value);
                                if (percentage < 0 || percentage > 100) {
                                  return 'Percentage must be between 0 and 100';
                                }
                              } catch (e) {
                                return 'Enter valid percentage';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          label: 'Discount Amount',
                          controller: _discountAmountController,
                          icon: Icons.money_off_outlined,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              try {
                                double amount = double.parse(value);
                                if (amount < 0) {
                                  return 'Amount must be positive';
                                }
                              } catch (e) {
                                return 'Enter valid amount';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color.fromARGB(255, 255, 200, 200),
                      menuMaxHeight: 300,
                      isExpanded: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                      iconEnabledColor: Colors.grey[600],
                      decoration: InputDecoration(
                        hintText: 'Select category',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.category_outlined,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 200, 200),
                            width: 1,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return categories.map<Widget>((String item) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                      onChanged: _isUploading
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickImage,
                      icon: Icon(Icons.image, color: Colors.red[300]),
                      label: Text(
                        'Upload Product Image',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  if (_image != null) ...[
                    SizedBox(height: 20),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            Image.file(File(_image!.path), fit: BoxFit.cover),
                      ),
                    ),
                  ],
                  SizedBox(height: 40),
                  _isUploading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _uploadProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 200, 200),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Upload Product',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[300],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?)? validator,
    bool obscureText = false,
    String? helperText,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: 'Enter your $label',
              prefixIcon: Icon(icon, color: Colors.grey[400]),
              prefixText: prefixText,
              suffixIcon: suffixIcon,
              helperText: helperText,
              helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: validator,
            enabled: !_isUploading,
          ),
        ),
      ],
    );
  }
}
