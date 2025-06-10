import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:doctorx/Pages/EditProfilePage.dart';
import 'package:doctorx/Pages/HelpPage.dart';
import 'package:doctorx/Pages/NotificationPage.dart';
import 'package:doctorx/Pages/PlaceholderPage.dart'; // ✅ New import
import '../innerPages/PrivacyPolicyPage.dart';
import '../innerPages/accountsetting.dart';
import 'Order.dart';
import 'Signup.dart';
import 'Wallet.dart'; // ✅ Import your tracking pag

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String doctorName = "Loading...";
  String doctorAddress = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchDoctorInfo();
  }

  Future<void> fetchDoctorInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;
      final docRef = FirebaseFirestore.instance.collection('normalusers').doc(uid);
      final docSnap = await docRef.get();

      // Create document if it doesn't exist
      if (!docSnap.exists) {
        await docRef.set({
          'name': user.displayName ?? 'No Name Provided',
          'address': 'No Address Provided',
        });
      }

      // Fetch latest data
      final userData = await docRef.get();
      final data = userData.data();

      setState(() {
        doctorName = data?['name'] ?? 'N/A';
        doctorAddress = data?['address'] ?? 'N/A';
      });
    } catch (e) {
      print("Error fetching doctor info: $e");
    }
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
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: fetchDoctorInfo,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Profile Header
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          doctorAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.deepPurple[300],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),

                // Quick Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionTile(context, Icons.edit, "Edit Profile", Colors.deepPurple, const EditProfilePage()),
                    _actionTile(context, Icons.account_balance_wallet, "Wallet", Colors.purple, const WalletPage()),
                    _actionTile(context, Icons.local_shipping_outlined, "Orders", Colors.deepPurple, const OrderPage()),
                    _actionTile(context, Icons.help_outline, "Help", Colors.purple, const HelpPage()),
                  ],
                ),
                const SizedBox(height: 30),

                // ✅ Order Tracking Section


                // Profile Options List
                const ProfileTile(
                  icon: Icons.settings,
                  label: "Account Settings",
                  destinationPage: AccountSettingsPage(),
                ),
                const ProfileTile(
                  icon: Icons.notifications,
                  label: "Notifications",
                  destinationPage: NotificationsPage(),
                ),
                const ProfileTile(
                  icon: Icons.privacy_tip,
                  label: "Privacy & Policy",
                  destinationPage: PrivacyPolicyPage(),
                ),
                const ProfileTile(
                  icon: Icons.logout,
                  label: "Logout",
                  isLogout: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _actionTile(
      BuildContext context, IconData icon, String label, Color color, Widget destinationPage) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            );
          },
          child: CircleAvatar(
            backgroundColor: color,
            radius: 22,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.deepPurple),
        ),
      ],
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLogout;
  final Widget? destinationPage;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.label,
    this.isLogout = false,
    this.destinationPage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.deepPurple,
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.deepPurple[900],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          if (isLogout) {
            FirebaseAuth.instance.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged out")),
            );

            // Replace current screen with SignupPage (navigate back to the beginning)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignupApp()),
                  (Route<dynamic> route) => false, // Remove all previous routes
            );
          } else if (destinationPage != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage!),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlaceholderPage(title: label)),
            );
          }
        },
      ),
    );
  }
}
