import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text("Help & Support", style: GoogleFonts.poppins(color: Colors.white)),
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
        child: ListView(
          children: [
            _buildSectionTitle("Frequently Asked Questions"),
            _buildFaq("How do I track my orders?", "Go to Profile > Orders to see your order status."),
            _buildFaq("How can I edit my profile?", "Navigate to Profile > Edit Profile."),
            _buildFaq("Who can I contact for help?", "You can contact us using the details below."),

            const SizedBox(height: 30),
            _buildSectionTitle("Contact Us"),
            _buildContactInfo(Icons.phone, "Call Us", "+91 9876543210"),
            _buildContactInfo(Icons.email, "Email", "support@doctorx.in"),
            _buildContactInfo(Icons.location_on, "Address", "MedLab Tower, Mumbai, India"),

            const SizedBox(height: 30),
            _buildSectionTitle("Send us your Feedback"),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Your feedback here...",
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Feedback Submitted!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Submit", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
    );
  }

  Widget _buildFaq(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            Text(answer, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: GoogleFonts.poppins()),
    );
  }
}
