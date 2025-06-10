import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createAdminUser() async {
  try {
    // Get the current logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Define the user data
      Map<String, dynamic> userData = {
        'email': user.email,
        'name': 'Admin User',  // This could be dynamic based on your input
        'role': 'admin',  // Set the role as 'admin' for the admin user
        'isAdmin': true,  // Make sure to mark the user as admin
      };

      // Add this data to Firestore in the 'users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Use the user UID as the document ID
          .set(userData);

      print('Admin user data written to Firestore');
    }
  } catch (e) {
    print('Error creating admin user: $e');
  }
}
