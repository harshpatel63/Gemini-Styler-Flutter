import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AnimatedCompliment extends StatefulWidget {
  AnimatedCompliment({Key? key}) : super(key: key);

  @override
  AnimatedComplimentState createState() => AnimatedComplimentState();
}

class AnimatedComplimentState extends State<AnimatedCompliment> {
  late FlutterTts flutterTts;
  bool isSpeaking = false;
  bool showCompliment = false; // New state variable
  String compliment = '';

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (!isSpeaking) {
      setState(() => isSpeaking = true);
      await flutterTts.speak(text);
      setState(() => isSpeaking = false);
    }
  }

  void setCompliment(String newCompliment) {
    setState(() {
      compliment = newCompliment;
      showCompliment = true; // Start showing the compliment
    });

    _speak(compliment);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showCompliment) // Only show the AnimatedTextKit when showCompliment is true
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        compliment,
                        textStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                        speed: Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                    onFinished: () {
                      // setState(() {
                      //   showCompliment = false; // Hide the compliment after animation
                      // });
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
