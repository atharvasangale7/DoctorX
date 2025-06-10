import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      extendBodyBehindAppBar: true,
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
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
        child: ListView(
          children: [
            _notificationCard(
              title: 'Order Shipped',
              subtitle: 'Your order #12345 has been shipped!',
              icon: Icons.local_shipping_outlined,
              color: Colors.deepPurple,
            ),
            _notificationCard(
              title: 'Wallet Updated',
              subtitle: '₹500 has been added to your wallet.',
              icon: Icons.account_balance_wallet,
              color: Colors.purple,
            ),
            _notificationCard(
              title: 'New Offer Available!',
              subtitle: 'Get 15% off on lab instruments. Limited time only.',
              icon: Icons.local_offer_rounded,
              color: Colors.orange,
            ),
            _notificationCard(
              title: 'Account Security',
              subtitle: 'New login detected on your account.',
              icon: Icons.security,
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.deepPurple[300],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          // Optional: Handle tap on notification
        },
      ),
    );
  }
}
