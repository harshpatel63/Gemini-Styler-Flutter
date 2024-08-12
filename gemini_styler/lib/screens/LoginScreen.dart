import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signInWithEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check if email or password is empty
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password cannot be empty';
      });
      return;
    }

    // Add basic email format validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Clear error message on successful sign in
      setState(() {
        _errorMessage = null;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Sign In'),
          automaticallyImplyLeading: false
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: Color(0xFFD8F0D8), // Lighter green for circle
                child: Image.asset(
                  'assets/app_icon.png', // Make sure to add this asset
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome Back To',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
              ),
              Text(
                'Gemini Styler',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              // TextField(
              //   controller: _emailController,
              //   decoration: InputDecoration(
              //     labelText: 'Email',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // SizedBox(height: 16.0),
              // TextField(
              //   controller: _passwordController,
              //   decoration: InputDecoration(
              //     labelText: 'Password',
              //     border: OutlineInputBorder(),
              //   ),
              //   obscureText: true,
              // ),
              // SizedBox(height: 16.0),
              // if (_errorMessage != null)
              //   Text(
              //     _errorMessage!,
              //     style: TextStyle(color: Colors.red),
              //   ),
              // SizedBox(height: 16.0),
              // ElevatedButton(
              //   child: Text('Sign in with Email'),
              //   onPressed: signInWithEmailPassword,
              // ),
              // SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage("assets/google_logo.png"),
                        height: 24.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
