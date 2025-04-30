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
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profileData == null
              ? Center(child: Text('No profile data available.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shop Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Manage your shop details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 32),
                        _buildProfileSection(
                          'Personal Information',
                          [
                            _buildProfileItem(
                              Icons.person_outline,
                              'Username',
                              profileData!['userName'] ?? 'N/A',
                            ),
                            _buildProfileItem(
                              Icons.email_outlined,
                              'Email',
                              profileData!['email'] ?? 'N/A',
                            ),
                            _buildProfileItem(
                              Icons.phone_outlined,
                              'Mobile Number',
                              profileData!['mobileNo'] ?? 'N/A',
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        _buildProfileSection(
                          'Shop Details',
                          [
                            _buildProfileItem(
                              Icons.store_outlined,
                              'Shop Name',
                              profileData!['shopname'] ?? 'N/A',
                            ),
                            _buildProfileItem(
                              Icons.description_outlined,
                              'Description',
                              profileData!['description'] ?? 'N/A',
                            ),
                            _buildProfileItem(
                              Icons.location_on_outlined,
                              'Location',
                              profileData!['location'] ?? 'N/A',
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        _buildProfileSection(
                          'Account Settings',
                          [
                            _buildProfileItem(
                              Icons.lock_outline,
                              'Change Password',
                              'Update your password',
                              isAction: true,
                              onTap: () {
                                // TODO: Implement change password
                              },
                            ),
                            _buildProfileItem(
                              Icons.logout,
                              'Sign Out',
                              'Log out from your account',
                              isAction: true,
                              onTap: () {
                                // TODO: Implement sign out
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),
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
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
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
            color: isAction ? Colors.grey[600] : Colors.grey[700],
          ),
        ),
        trailing: isAction
            ? Icon(Icons.chevron_right, color: Colors.grey[400])
            : null,
        onTap: onTap,
      ),
    );
  }
}
