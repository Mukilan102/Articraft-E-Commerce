import 'package:articraft_ui/vendor/newpage.dart';
import 'package:flutter/material.dart';
import 'package:articraft_ui/decoration/boxdecoration.dart';
import 'package:articraft_ui/Customer/cust_main.dart';

class VandC extends StatelessWidget {
  const VandC({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/demo.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black
                .withOpacity(0.3), // Dark overlay for better contrast
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height: h * 0.2), // Top padding to fill space dynamically
                Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: h * 0.05), // Space between title and buttons
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SplashScreen()));
                  },
                  child: Container(
                    height:
                        h * 0.2, // Height adjusted relative to screen height
                    width: w * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: cardlike,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(
                            Icons.storefront,
                            size: h * 0.08, // Icon size relative to height
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                        Text(
                          "Vendor",
                          style: TextStyle(
                            fontSize: h * 0.03, // Font size relative to height
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: h * 0.05), // Spacing between buttons
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CustomerHome()));
                  },
                  child: Container(
                    height: h *
                        0.2, // Adjusted height relative to the screen height
                    width: w * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: cardlike,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(
                            Icons.person,
                            size: h * 0.08, // Icon size relative to height
                            color: const Color.fromARGB(255, 125, 83, 96),
                          ),
                        ),
                        Text(
                          "Customer",
                          style: TextStyle(
                            fontSize: h * 0.03, // Font size relative to height
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom padding to fill space
              ],
            ),
          ),
        ),
      ),
    );
  }
}
