import 'package:articraft_ui/Customer/cart_ui.dart';
import "package:flutter/material.dart";
import 'package:articraft_ui/Customer/pg1_cust_home.dart';
import 'package:articraft_ui/Customer/page4.dart';
import 'package:articraft_ui/Customer/page2.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int pageIndex = 0;

  // Use a separate Navigator key for page content
  final GlobalKey<NavigatorState> _pageNavigatorKey =
      GlobalKey<NavigatorState>();

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return ShopListScreen();
      case 1:
        return Page2();
      case 2:
        return CartPage();
      case 3:
        return CustSplashScreen();
      default:
        // Handle invalid pageIndex gracefully
        return const Center(child: Text("Page not found"));
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      pageIndex = index;
    });

    // Pop all routes and push the new one
    _pageNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    _pageNavigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => _getPage(index),
        settings: RouteSettings(name: '/$index'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          // Handle back button - try to pop current page navigator first
          final canPop = _pageNavigatorKey.currentState?.canPop() ?? false;
          if (canPop) {
            _pageNavigatorKey.currentState?.pop();
            return false; // Don't exit the app
          }
          return true; // Allow exiting the app
        },
        child: Navigator(
          key: _pageNavigatorKey,
          // Create a new page each time to ensure refresh
          onGenerateInitialRoutes: (navigator, initialRoute) {
            return [
              MaterialPageRoute(
                builder: (context) => _getPage(pageIndex),
                settings: RouteSettings(name: '/$pageIndex'),
              )
            ];
          },
          onGenerateRoute: (settings) {
            // For handling deeper navigation within each tab
            return MaterialPageRoute(
              builder: (context) => _getPage(pageIndex),
              settings: settings,
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (index) {
          if (index == pageIndex) {
            // If tapping the current tab, pop to first route if possible
            while (_pageNavigatorKey.currentState?.canPop() ?? false) {
              _pageNavigatorKey.currentState?.pop();
            }
          } else {
            _navigateToPage(index);
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor:
            Colors.white, // Changed bottom navigation bar color to white
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "Shop"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
