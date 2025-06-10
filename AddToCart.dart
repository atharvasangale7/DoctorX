import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../innerPages/userDetailedPage.dart';

class AddToCartPage extends StatelessWidget {
  const AddToCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFFFDE8D4),
              Color(0xFFFAD5D5),
              Color(0xFFE4E0F5),
              Color(0xFFDEE6F6),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('carts')
                .doc(userId)
                .collection('items')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Your cart is empty"));
              }

              final cartItems = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'name': data['name'] ?? '',
                  'imageUrl': data['imageUrl'] ?? '',
                  'quantity': data['quantity'] ?? 1,
                  'price': (data['price'] ?? 0).toDouble(),
                };
              }).toList();

              double totalPrice = 0;
              for (var item in cartItems) {
                totalPrice += (item['price'] as double) * (item['quantity'] as int);
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];

                        return Card(
                          color: Colors.white.withOpacity(0.95),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['imageUrl'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 60),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text("Qty: ${item['quantity']}"),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                        "₹${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('carts')
                                            .doc(userId)
                                            .collection('items')
                                            .doc(item['id'])
                                            .delete();
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailsPage(
                                cartItems: cartItems,
                                product: {
                                  'summary': 'Cart Checkout',
                                  'totalItems': cartItems.length,
                                  'totalPrice': totalPrice,
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Proceed to Order",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
