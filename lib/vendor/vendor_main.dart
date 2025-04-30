import 'package:articraft_ui/vendor/pg2_Inventory.dart';
import 'package:flutter/material.dart';
import 'package:articraft_ui/vendor/pg1_home.dart';

import 'pg3_profile.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int pageindex = 0;
  final List<Widget> content = <Widget>[
    ItemListScreen(),
    UploadProductPage(),
    ProfileScreen(),
  ];

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return AnimatedScale(
      scale: pageindex == index ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (pageindex == index)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          Icon(icon, size: 28),
        ],
      ),
    );
  }

  Widget _buildActiveIcon(IconData icon, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 227, 227, 227),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: const Color.fromARGB(255, 237, 136, 136),
            height: 2,
          ),
        ),
        title: const Text(
          'Articraft',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Pacifico',
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: content[pageindex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: pageindex,
          onTap: (index) {
            setState(() {
              pageindex = index;
            });
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: const Color.fromARGB(255, 227, 227, 227),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(1, 1),
                blurRadius: 2,
              )
            ],
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.house_outlined, 0),
              activeIcon: _buildActiveIcon(Icons.house, 0),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.add_box_outlined, 1),
              activeIcon: _buildActiveIcon(Icons.add_box, 1),
              label: "Upload",
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.person_2_outlined, 2),
              activeIcon: _buildActiveIcon(Icons.person_2, 2),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
