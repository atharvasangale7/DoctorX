import 'package:flutter/material.dart';

class Scannerscreen extends StatelessWidget {
  const Scannerscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Scanner'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFFFDE8D4),
              Color(0xFFFAD5D5),
              Color(0xFFE4E0F5),
              Color(0xFFDEE6F6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/payment_scanner_image.jpeg', // Put your scanner image here
                height: 200, // Adjust the size as per your need
                width: 200,  // Adjust the size as per your need
              ),
              const SizedBox(height: 20),
              const Text(
                "Scan Payment QR",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


