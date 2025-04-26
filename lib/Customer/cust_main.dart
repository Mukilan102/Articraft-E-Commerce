import 'package:articraft_ui/Customer/cart_ui.dart';
import "package:flutter/material.dart";
import 'package:articraft_ui/Customer/pg1_cust_home.dart';
import 'package:articraft_ui/Customer/page4.dart';
import 'package:articraft_ui/Customer/page2.dart';
import 'package:articraft_ui/Customer/SearchResultsScreen.dart';
import 'package:articraft_ui/Customer/fur_predict.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int pageIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final GlobalKey<NavigatorState> _pageNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      case 4:
        return ImageUploadPage();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      pageIndex = index;
    });

    _pageNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    _pageNavigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => _getPage(index),
        settings: RouteSettings(name: '/$index'),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return AnimatedScale(
      scale: pageIndex == index ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (pageIndex == index)
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
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchQuery = _searchController.text;
                          _isSearching = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultsScreen(
                              searchQuery: _searchQuery,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  autofocus: true,
                  onSubmitted: (value) {
                    setState(() {
                      _searchQuery = value;
                      _isSearching = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultsScreen(
                          searchQuery: _searchQuery,
                        ),
                      ),
                    );
                  },
                ),
              )
            : const Text(
                'Articraft',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Pacifico',
                  letterSpacing: 2.0,
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () => setState(() => _isSearching = true),
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchController.clear();
              }),
            ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          final canPop = _pageNavigatorKey.currentState?.canPop() ?? false;
          if (canPop) {
            _pageNavigatorKey.currentState?.pop();
            return false;
          }
          return true;
        },
        child: Navigator(
          key: _pageNavigatorKey,
          onGenerateInitialRoutes: (navigator, initialRoute) => [
            MaterialPageRoute(
              builder: (context) => _getPage(pageIndex),
              settings: RouteSettings(name: '/$pageIndex'),
            )
          ],
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => _getPage(pageIndex),
            settings: settings,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: (index) {
            if (index == pageIndex) {
              while (_pageNavigatorKey.currentState?.canPop() ?? false) {
                _pageNavigatorKey.currentState?.pop();
              }
            } else {
              _navigateToPage(index);
            }
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
              icon: _buildAnimatedIcon(Icons.shopping_bag_outlined, 1),
              activeIcon: _buildActiveIcon(Icons.shopping_bag, 1),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.shopping_cart_outlined, 2),
              activeIcon: _buildActiveIcon(Icons.shopping_cart, 2),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.person_outline, 3),
              activeIcon: _buildActiveIcon(Icons.person, 3),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.camera_alt_outlined, 4),
              activeIcon: _buildActiveIcon(Icons.camera_alt, 4),
              label: "Camera",
            ),
          ],
        ),
      ),
    );
  }
}
