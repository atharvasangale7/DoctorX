import 'package:doctorx/Pages/AddToCart.dart';
import 'package:doctorx/Pages/Order.dart';
import 'package:doctorx/Pages/wallet.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'Profile.dart';
import 'home.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late home homepage;
  late OrderPage order;
  late WalletApp wallet;
  late ProfilePage profile;
  late AddToCartPage addtocart;

  @override
  void initState() {
    homepage = home();
    order = OrderPage();
    wallet = WalletApp();
    addtocart = AddToCartPage();
    profile = ProfilePage();

    pages = [homepage, order, wallet, addtocart, profile];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: const Color(0xFFE4E0F5), // Matches gradient background
        color: const Color(0xFF6A5AE0), // Deep purple tone for nav bar
        buttonBackgroundColor: const Color(0xFF836FFF), // Lighter purple highlight
        animationDuration: const Duration(milliseconds: 500),
        index: currentTabIndex,
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          Icon(Icons.home_outlined, color: Colors.white),
          Icon(Icons.shopping_bag_outlined, color: Colors.white),
          Icon(Icons.wallet_outlined, color: Colors.white),
          Icon(Icons.shopping_cart, color: Colors.white),
          Icon(Icons.person_outlined, color: Colors.white),


        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
