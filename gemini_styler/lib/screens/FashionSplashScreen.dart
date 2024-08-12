import 'package:flutter/material.dart';
import 'dart:async';

class FashionSplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const FashionSplashScreen({Key? key, required this.onInitializationComplete}) : super(key: key);

  @override
  _FashionSplashScreenState createState() => _FashionSplashScreenState();
}

class _FashionSplashScreenState extends State<FashionSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentEmojiIndex = 0;
  final List<String> _emojis = ['👗', '👠', '👜', '💄', '👒', '🕶️', '💍', '⌚'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Change emoji every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentEmojiIndex = (_currentEmojiIndex + 1) % _emojis.length;
        });
      }
    });

    // Trigger onInitializationComplete after 5 seconds
    Future.delayed(Duration(seconds: 5), widget.onInitializationComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple[100]!, Colors.pink[100]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated emoji
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_controller.value * 0.2),
                    child: Text(
                      _emojis[_currentEmojiIndex],
                      style: TextStyle(fontSize: 80),
                    ),
                  );
                },
              ),
              SizedBox(height: 40),
              // App name
              Text(
                'Gemini Styler',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}