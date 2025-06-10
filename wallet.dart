import 'package:doctorx/Pages/Order.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoctorX Wallet',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const WalletPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFFFDE8D4),
              Color(0xFFFAD5D5),
              Color(0xFFE4E0F5),
              Color(0xFFDEE6F6),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            backgroundColor: Colors.deepPurple,
            color: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 32, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Text(
                          'Wallet',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.deepPurple[50],
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                "₹ 5,400.00",
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Available Balance",
                                style: GoogleFonts.poppins(color: Colors.deepPurple[300]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _walletAction(context, Icons.add, "Add Money"),
                        _walletAction(context, Icons.history, "Transactions"),
                        _walletAction(context, Icons.local_shipping_outlined, "Orders"),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Development Mode Notice
                    Center(
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.deepPurple[50],
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 80.0,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                'This page is under development!',
                                style: GoogleFonts.poppins(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                'Please use Cash on Delivery for payment.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 18.0,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 30.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Widget _walletAction(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "Orders") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderPage()),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
