import 'package:flutter/material.dart';
import 'DioClient.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  final DioClient _dioClient = DioClient();

  @override
  void initState() {
    super.initState();
    _dioClient.setupInterceptors(context);
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      var response = await _dioClient.dio
          .get('http://localhost:5000/api/Vendor_Product_/getvprofile');
      setState(() {
        profileData = response.data;
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profileData == null
              ? Center(child: Text('No profile data available.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              profileData!['userName'] ?? 'N/A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              profileData!['email'] ?? 'N/A',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            buildProfileItem(
                                Icons.phone, 'Mobile', profileData!['mobileNo']),
                            buildProfileItem(Icons.store, 'Shop Name',
                                profileData!['shopname']),
                            buildProfileItem(Icons.description, 'Description',
                                profileData!['description']),
                            buildProfileItem(Icons.location_on, 'Location',
                                profileData!['location']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget buildProfileItem(IconData icon, String title, String? value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.deepPurple,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        subtitle: Text(value ?? 'N/A'),
      ),
    );
  }
}
