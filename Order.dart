import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctorx/innerPages/OrderTrackingPage.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool _refreshing = false;

  Future<void> _refreshOrders() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _refreshing = false);
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 28, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Text(
                          'My Orders',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                      onPressed: _refreshOrders,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: user == null
                      ? const Center(child: Text("Please log in to view your orders."))
                      : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('userId', isEqualTo: user!.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || _refreshing) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No orders found."));
                      }

                      final orders = snapshot.data!.docs.where((doc) {
                        final status = doc['status']?.toString().toLowerCase() ?? '';
                        final timestamp = (doc['timestamp'] as Timestamp).toDate();
                        final isCancelled = status == 'cancelled';
                        final now = DateTime.now();
                        final isRecent = now.difference(timestamp).inMinutes <= 3;
                        return !(isCancelled && isRecent);
                      }).toList();

                      if (orders.isEmpty) {
                        return const Center(child: Text("No active orders."));
                      }

                      return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final orderData = order.data() as Map<String, dynamic>;
                          final List items = orderData['items'] ?? [];

                          return OrderCard(
                            context: context,
                            orderId: order.id,
                            items: items,
                            status: orderData['status'] ?? 'Unknown',
                            date: (orderData['timestamp'] as Timestamp)
                                .toDate()
                                .toString()
                                .substring(0, 10),
                            totalAmount: orderData['totalAmount'] ?? 0.0,
                            timestamp: (orderData['timestamp'] as Timestamp).toDate(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final BuildContext context;
  final String orderId;
  final List items;
  final String status;
  final String date;
  final double totalAmount;
  final DateTime timestamp;

  const OrderCard({
    super.key,
    required this.context,
    required this.orderId,
    required this.items,
    required this.status,
    required this.date,
    required this.totalAmount,
    required this.timestamp,
  });

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'accepted':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool isCancellableByTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours < 7;
  }

  void _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'cancelled',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order cancelled."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _trackOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCancel = isCancellableByTime() &&
        ['pending', 'shipped', 'accepted'].contains(status.toLowerCase());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: $orderId",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Date: $date", style: GoogleFonts.poppins(fontSize: 12)),
            const SizedBox(height: 12),
            Text("Items:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...items.map((item) {
              final name = item['name'] ?? 'Unknown';
              final price = item['price'] ?? 0.0;
              final quantity = item['quantity'] ?? 1;
              final total = (price is num && quantity is num) ? price * quantity : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Price: ₹${price.toStringAsFixed(2)} x $quantity",
                            style: GoogleFonts.poppins(fontSize: 13)),
                        Text("Total: ₹${total.toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(height: 20),
            Text("Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: getStatusColor(status),
                ),
                Flexible(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (showCancel)
                        ElevatedButton(
                          onPressed: _cancelOrder,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text("Cancel"),
                        ),
                      ElevatedButton(
                        onPressed: _trackOrder,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                        child: const Text("Track"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}