import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('normalusers')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? '';
          address = data['address'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        await FirebaseFirestore.instance
            .collection('normalusers')
            .doc(user.uid)
            .update({
          'name': name,
          'address': address,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple[100],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                "Full Name",
                name,
                Icons.person,
                    (val) => name = val,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                "Address",
                address,
                Icons.home,
                    (val) => address = val,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveChanges,
                child: Text(
                  "Save Changes",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String initialValue,
      IconData icon,
      Function(String) onSaved,
      ) {
    return TextFormField(
      initialValue: initialValue,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.poppins(color: Colors.deepPurple),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      onSaved: (value) => onSaved(value!),
    );
  }
}
