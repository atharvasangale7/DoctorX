import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'This page is under construction!',
          style: TextStyle(
            fontSize: 18,
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
