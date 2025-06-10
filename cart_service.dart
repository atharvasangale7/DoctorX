import 'package:flutter/material.dart';

class CartService {
  // Singleton instance
  static final CartService _instance = CartService._internal();

  // Factory constructor to return the singleton instance
  factory CartService() => _instance;

  // Internal cart storage
  final List<Map<String, dynamic>> _cartItems = [];

  // Private constructor
  CartService._internal();

  // Public getter to access cart items
  List<Map<String, dynamic>> get cartItems => _cartItems;

  /// Adds an item to the cart. If the item already exists, update quantity.
  void addItem(Map<String, dynamic> item) {
    final index = _cartItems.indexWhere((e) => e['name'] == item['name']);
    if (index != -1) {
      _cartItems[index]['quantity'] += item['quantity'];
      _cartItems[index]['totalPrice'] =
          _cartItems[index]['price'] * _cartItems[index]['quantity'];
      // Don't update timestamp if item already exists
    } else {
      // Add timestamp for grouping logic
      item['timestamp'] = DateTime.now();
      item['totalPrice'] = item['price'] * item['quantity'];
      _cartItems.add(item);
    }
  }

  /// Returns the total price of items in the cart.
  double getTotalPrice() {
    return _cartItems.fold(
      0.0,
          (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  /// Removes a specific item (by matching full map)
  void removeItem(Map<String, dynamic> item) {
    _cartItems.remove(item);
  }

  /// Removes an item by name.
  void removeItemByName(String name) {
    _cartItems.removeWhere((item) => item['name'] == name);
  }

  /// Clears the entire cart.
  void clearCart() {
    _cartItems.clear();
  }

  /// Groups cart items into 5-minute order groups based on timestamp.
  List<List<Map<String, dynamic>>> getGroupedItemsByTime() {
    if (_cartItems.isEmpty) return [];

    // Sort items by timestamp
    _cartItems.sort((a, b) =>
        (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime));

    List<List<Map<String, dynamic>>> groups = [];
    List<Map<String, dynamic>> currentGroup = [];
    DateTime groupStartTime = _cartItems.first['timestamp'];

    for (var item in _cartItems) {
      final DateTime itemTime = item['timestamp'];
      if (itemTime.difference(groupStartTime).inMinutes >= 5) {
        groups.add(currentGroup);
        currentGroup = [];
        groupStartTime = itemTime;
      }
      currentGroup.add(item);
    }

    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }

    return groups;
  }
}
