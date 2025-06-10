import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorx/AdminPanelSections/AdminOrders.dart';
import 'package:doctorx/AdminPanelSections/SendNotificationPage.dart';
import 'package:doctorx/Pages/Login.dart';
import 'package:doctorx/Pages/PlaceholderPage.dart';
import 'package:doctorx/innerPages/AdminSetting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AdminPanelSections/AddProductPage.dart';
import '../AdminPanelSections/AdminUser.dart'; // Import the auth_service.dart file

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  // Function to refresh the data
  Future<void> _refreshData(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 5,
      ),
      body: StreamBuilder<User?>(
        stream: authStateChanges(), // Listen to auth state changes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData) {
            // If the user is not logged in, show login or sign-up screen
            return Center(child: Text("Please sign in to access the Admin Dashboard"));
          }

          // User is logged in, show the dashboard
          return RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 2.5,
                  colors: [
                    Color(0xFFFAD0A9),
                    Color(0xFFF9BABA),
                    Color(0xFFFCE8B0),
                    Color(0xFFF5F5FA),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // Welcome Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      title: Text(
                        "Welcome, Admin",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Manage your platform efficiently.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Real-time Statistics Section for Users, Products, and Orders
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('adminusers').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      final userCount = snapshot.data?.docs.length ?? 0;
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('products').snapshots(),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          final productCount = productSnapshot.data?.docs.length ?? 0;
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                            builder: (context, orderSnapshot) {
                              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              final orderCount = orderSnapshot.data?.docs.length ?? 0;
                              return Column(
                                children: [
                                  // Horizontal scroll view for stat cards
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildStatCard("Users", userCount.toString(), Icons.people, Colors.green[100]!, context),
                                        SizedBox(width: 16),
                                        _buildStatCard("Products", productCount.toString(), Icons.inventory, Colors.blue[100]!, context),
                                        SizedBox(width: 16),
                                        _buildStatCard("Orders", orderCount.toString(), Icons.shopping_cart, Colors.orange[100]!, context),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  // Quick Actions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Quick Actions",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[700],
                      ),
                    ),
                  ),

                  // Quick Actions Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: List.generate(actions.length, (index) => _buildActionButton(index, context)),
                  ),

                  const SizedBox(height: 20),

                  // Sign Out Button
                  ElevatedButton(
                    onPressed: () {
                      signOutUser(); // Sign out the user
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text("Sign Out"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(String title, String value, IconData icon, Color color, BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.indigo, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Actions
  static List<Map<String, dynamic>> actions = [
    {"title": "Add Product", "icon": Icons.add_circle_outline, "color": Colors.indigo, "route": AddProductPage()},
    {"title": "Manage Orders", "icon": Icons.list_alt, "color": Colors.deepOrange, "route": AdminOrderPage()},
    {"title": "View Users", "icon": Icons.people_outline, "color": Colors.teal, "route": PlaceholderPage},
    {"title": "Settings", "icon": Icons.settings, "color": Colors.purple, "route": AdminSettingsPage()},
    {"title": "Send Notification", "icon": Icons.notifications, "color": Colors.red, "route": SendNotificationScreen()},
  ];

  // Build Action Button
  Widget _buildActionButton(int index, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: actions[index]['color'],
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => actions[index]['route']),
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(actions[index]['icon'], color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(
                actions[index]['title'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
