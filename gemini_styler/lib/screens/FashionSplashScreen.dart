import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FashionSplashScreen extends StatelessWidget {
  final VoidCallback onInitializationComplete;

  const FashionSplashScreen({Key? key, required this.onInitializationComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated hanger icon
            TweenAnimationBuilder(
              duration: Duration(seconds: 2),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(Icons.camera_alt_rounded, size: 100, color: Colors.purple),
                );
              },
            ),
            SizedBox(height: 20),
            // Animated text
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Gemini Styler',
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                  speed: Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
              onFinished: onInitializationComplete,
            ),
          ],
        ),
      ),
    );
  }
}