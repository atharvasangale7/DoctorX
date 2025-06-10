import 'package:flutter/material.dart';

class RefreshPage extends StatefulWidget {
  const RefreshPage({super.key});

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  Future<void> _handleRefresh() async {
    // Simulate an API call or data update
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          backgroundColor: Colors.deepPurple,
          color: Colors.white,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            children: const [
              Center(
                child: Text(
                  "Pull down to refresh...",
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
