import 'package:doctorx/HomeSectionPages/ChemicalDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doctorx/HomeSectionPages/CategoryItems.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

void main() {
  runApp(const home());
}

class home extends StatelessWidget {
  const home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoctorX',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _debounce;

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _searchProducts(String query) {
    if (query.isEmpty) return Stream.value([]);
    final lowerQuery = query.toLowerCase();

    return FirebaseFirestore.instance
        .collection('products')
        .where('name_lowercase', isGreaterThanOrEqualTo: lowerQuery)
        .where('name_lowercase', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchQuery.toLowerCase();
      if (query.isEmpty) return;

      final results = await FirebaseFirestore.instance
          .collection('products')
          .where('name_lowercase', isGreaterThanOrEqualTo: query)
          .where('name_lowercase', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(1)
          .get();

      if (results.docs.isNotEmpty) {
        final productId = results.docs.first.id;
        saveRecentlyViewedProduct(productId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
            onRefresh: _handleRefresh,
            backgroundColor: Colors.deepPurple,
            color: Colors.white,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "DoctorX",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.deepPurple),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: const InputDecoration(
                              hintText: "Search lab items...",
                              prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                if (_searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Search Results",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),

                if (_searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      stream: _searchProducts(_searchQuery),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final products = snapshot.data ?? [];
                        if (products.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(18),
                            child: Text("No products found."),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final doc = products[index].data();
                            final productId = products[index].id;
                            final price = (doc['price'] as num?)?.toDouble() ?? 0.0;
                            final name = doc['name'] ?? '';
                            final description = doc['description'] ?? 'No description available';
                            final imageUrl = doc['imageUrl'] ?? '';
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              child: _exploreItem(context, name, price, imageUrl, productId, description),
                            );
                          },
                        );
                      },
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Categories",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              categoryCard(context, "Chemicals", Icons.science, "Chemicals"),
                              categoryCard(context, "Glassware", Icons.wine_bar, "Glassware"),
                              categoryCard(context, "Plasticware", Icons.local_drink, "Plasticware"),
                              categoryCard(context, "Instruments & Misc", Icons.medical_services, "Instruments & Misc"),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Recently Searched",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            child: user == null
                                ? const Center(child: Text("Please log in to view recently searched items."))
                                : StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('normalusers')
                                  .doc(user.uid)
                                  .collection('recentlySearched')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Center(child: Text("No recently searched items."));
                                }
                                final recents = snapshot.data!.docs;
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recents.length,
                                  itemBuilder: (context, index) {
                                    final recentData = recents[index].data() as Map<String, dynamic>;
                                    final productId = recentData['productId'];
                                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
                                      builder: (context, snap) {
                                        if (!snap.hasData || !snap.data!.exists) return const SizedBox.shrink();
                                        final doc = snap.data!.data()!;
                                        final price = (doc['price'] as num?)?.toDouble() ?? 0.0;
                                        final name = doc['name'] ?? '';
                                        final description = doc['description'] ?? 'No description available';
                                        final imageUrl = doc['imageUrl'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: _exploreItem(context, name, price, imageUrl, productId, description),
                                        );
                                      },
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget categoryCard(BuildContext context, String title, IconData icon, String categoryName) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => CategoryItemsPage(categoryName: categoryName)),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.deepPurple.withOpacity(0.15),
              child: Icon(icon, color: Colors.deepPurple, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }



  void saveRecentlySearchedProduct(String productId) {
    // Replace with your own logic — here’s a Firestore example:
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recentlySearched')
          .doc(productId)
          .set({
        'productId': productId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
  void saveRecentlyViewedProduct(String productId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('normalusers') // Make sure this matches your Firestore structure
          .doc(userId)
          .collection('recentlySearched')
          .doc(productId)
          .set({
        'productId': productId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }



  Widget _exploreItem(
      BuildContext context,
      String name,
      double price,
      String imageUrl,
      String productId,
      String description, {
        isSearchResult = true,
      }) {
    final formattedPrice = '₹${price.toStringAsFixed(2)}';

    return GestureDetector(
      onTap: () async {
        saveRecentlySearchedProduct(productId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => ChemicalDetailPage(
              chemicalName: name,
              description: description,
              price: price,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: double.infinity,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.image),
              )
                  : const Icon(Icons.inventory_2_outlined,
                  size: 60, color: Colors.deepPurple),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formattedPrice,
              style: GoogleFonts.poppins(
                color: Colors.deepPurple.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}