import 'package:erp_station/app/view/costumer/CustomerTrackingPage.dart';
import 'package:erp_station/app/view/home/home.dart';
import 'package:erp_station/app/view/orders/orders.dart';
import 'package:erp_station/app/view/stock/stockpage.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavigationMainPage extends StatefulWidget {
  const NavigationMainPage({super.key});

  @override
  State<NavigationMainPage> createState() => _NavigationMainPageState();
}

class _NavigationMainPageState extends State<NavigationMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ERPHomePage(),
    OrdersPage(),
    CustomerTrackingPage(),
    StoklarPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: GNav(
              gap: 8,
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 300),
              tabBackgroundColor: Colors.blue.shade600,
              color: Colors.grey[600],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() => _selectedIndex = index);
              },
              tabs: const [
                GButton(icon: Icons.home, text: 'Anasayfa'),
                GButton(icon: Icons.list_alt, text: 'Siparişler'),
                GButton(icon: Icons.people_alt, text: 'Müşteriler'),
                GButton(icon: Icons.inventory, text: 'Stok'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
