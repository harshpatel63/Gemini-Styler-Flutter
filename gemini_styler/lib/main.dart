import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_styler/firebase_options.dart';
import 'package:gemini_styler/screens/FashionSplashScreen.dart';
import 'package:gemini_styler/screens/LoginScreen.dart';
import 'package:gemini_styler/screens/MainScreen.dart';
import 'package:gemini_styler/service/PromptService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Styler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InitializationScreen(userName: snapshot.data?.displayName ?? 'User');
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class InitializationScreen extends StatefulWidget {
  final String userName;

  const InitializationScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _InitializationScreenState createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  final PromptService _promptService = PromptService();
  String? _prompt;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      _prompt = await _promptService.getPrompt();
    } catch (e) {
      print('Error initializing app: $e');
    }

    // Simulate a delay to show the splash screen
    await Future.delayed(Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainScreen(userName: widget.userName, prompt: _prompt ?? '')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FashionSplashScreen(
      onInitializationComplete: () {}, // This is now handled in _initializeApp
    );
  }
}