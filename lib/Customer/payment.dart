import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'UserDioClient.dart';

class PaymentPage extends StatefulWidget {
  final String productId;
  final String address;

  const PaymentPage({
    super.key,
    required this.productId,
    required this.address,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  bool _isLoading = false;
  String _selectedPaymentMethod = 'card';
  final UserDioClient _dioClient = UserDioClient();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final authToken = await _secureStorage.read(key: 'token');
        if (authToken == null) {
          throw Exception('No authentication token found');
        }

        final response = await _dioClient.dio.post(
          'http://localhost:5000/api/Customer/processPayment',
          data: {
            'productId': widget.productId,
            'address': widget.address,
            'paymentType': _selectedPaymentMethod,
            'cardNumber': _cardNumberController.text,
            'expiryDate': _expiryController.text,
            'cvc': _cvcController.text,
          },
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment successful!')),
            );
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        title: Text(
          "Payment",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Choose your preferred payment method",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32),
              _buildPaymentMethodCard(
                'Credit/Debit Card',
                'Pay with your card',
                Icons.credit_card,
                'card',
              ),
              SizedBox(height: 32),
              if (_selectedPaymentMethod == 'card') ...[
                Text(
                  "Card Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildCardInput(
                  label: "Card Number",
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Please enter card number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCardInput(
                        label: "Expiry Date (MM/YY)",
                        controller: _expiryController,
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Please enter expiry date";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildCardInput(
                        label: "CVC",
                        controller: _cvcController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Please enter CVC";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 32),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 200, 200),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Pay Now",
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
    );
  }

  Widget _buildPaymentMethodCard(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? const Color.fromARGB(255, 255, 200, 200)
                : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: _selectedPaymentMethod == value
                ? Colors.red[300]
                : Colors.grey[600],
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          trailing: _selectedPaymentMethod == value
              ? Icon(
                  Icons.check_circle,
                  color: Colors.red[300],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCardInput({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String? Function(String?)? validator,
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
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: "Enter $label",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
