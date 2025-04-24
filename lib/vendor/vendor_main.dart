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
  @override
  void initState() {
    super.initState();
  }

  int pageindex = 0;
  List content = [
    ItemListScreen(),
    UploadProductPage(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        body: content[pageindex],
        bottomNavigationBar: Container(
            height: 60,
            decoration: BoxDecoration(
                color: const Color.fromARGB(26, 15, 14, 14),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      pageindex = 0;
                    });
                  },
                  icon: pageindex == 0
                      ? Icon(
                          Icons.house_sharp,
                          color: Colors.black,
                          size: 30,
                        )
                      : Icon(
                          Icons.house_outlined,
                          color: Colors.black,
                          size: 30,
                        ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      pageindex = 1;
                    });
                  },
                  icon: pageindex == 1
                      ? Icon(
                          Icons.add_box,
                          color: Colors.black,
                          size: 30,
                        )
                      : Icon(
                          Icons.add_box_outlined,
                          color: Colors.black,
                          size: 30,
                        ),
                ),
                
                IconButton(
                  onPressed: () {
                    setState(() {
                      pageindex = 2;
                    });
                  },
                  icon: pageindex == 2
                      ? Icon(
                          Icons.person_2_sharp,
                          color: Colors.black,
                          size: 30,
                        )
                      : Icon(
                          Icons.person_2_outlined,
                          color: Colors.black,
                          size: 30,
                        ),
                ),
              ],
            )));
  }
}