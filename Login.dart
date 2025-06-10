import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorx/DeliveryBoyPanel/DelieveryBoyPanel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:doctorx/Pages/Forgotpassword.dart';
import 'package:doctorx/Pages/Signup.dart';
import 'package:doctorx/Pages/bottomnavigation.dart';
import 'AdminDashboardPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFFFAD0A9),
              Color(0xFFF9BABA),
              Color(0xFFFCE8B0),
              Color(0xFFF5F5FA),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.indigo),
                const SizedBox(height: 10),
                Text(
                  "Welcome Back",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputStyle("Email"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                        value!.isEmpty ? "Enter your email" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _inputStyle("Password"),
                        obscureText: true,
                        validator: (value) =>
                        value!.isEmpty ? "Enter your password" : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Login",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const ForgotPasswordPage()),
                          );
                        },
                        child: const Text("Forgot Password?"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        },
                        child: const Text("Don’t have an account? Sign up"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.indigo),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // Sign in the user
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final User? user = userCredential.user;

        if (user != null) {
          print("Authenticated User UID: ${user.uid}");

          // Check if user is an admin in Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data();
            print("User Data from Firestore: $userData");

            final isAdmin = userData?['isAdmin'] == true;
            final isDelivery = userData?['isDelivery'] == true;

            if (isAdmin) {
              print("User is an admin. Navigating to AdminDashboardPage.");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdminDashboardPage()),
              );
              return;
            } else if (isDelivery) {
              print("User is a delivery boy. Navigating to DeliveryBoyPanel.");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DeliveryBoyPanel()),
              );
              return;
            }

          }

          else {
            print("No Firestore document exists for user: ${user.uid}");
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Bottomnav()),
          );


          // If not admin, navigate to user dashboard

        }
      } on FirebaseAuthException catch (e) {
        print("FirebaseAuth Error: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
