import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_styler/screens/OutfitOfTheDay.dart';
import 'package:gemini_styler/service/CurrentConditions.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../widgets/AnimatedCompliment.dart';

class OutfitRecommendationPage extends StatefulWidget {
  final String recommendationPromptString;
  final String extraInputCommand;

  const OutfitRecommendationPage({Key? key, required this.recommendationPromptString, required this.extraInputCommand}) : super(key: key);

  @override
  _OutfitRecommendationPageState createState() => _OutfitRecommendationPageState();
}

String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

class _OutfitRecommendationPageState extends State<OutfitRecommendationPage> with SingleTickerProviderStateMixin {
  String shirtImageUrl = '';
  String pantImageUrl = '';
  String message = '';
  String prompt = '';
  bool isLoading = true;
  final GlobalKey<AnimatedComplimentState> _animatedComplimentKey = GlobalKey<AnimatedComplimentState>();

  late AnimationController _orbAnimationController;
  late Animation<double> _orbScaleAnimation;
  late Animation<double> _orbRotationAnimation;

  @override
  void initState() {
    super.initState();
    _orbAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _orbScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_orbAnimationController);
    _orbRotationAnimation = Tween<double>(begin: 0, end: 0.05).animate(_orbAnimationController);

    getOutfitOfTheDay(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void dispose() {
    _orbAnimationController.dispose();
    super.dispose();
  }

  Future<void> getOutfitOfTheDay(String userId) async {
    setState(() {
      isLoading = true;
    });

    // Fetch user outfits from Firestore
    final upperOutfits = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('upper_body')
        .get();

    final lowerOutfits = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lower_body')
        .get();

    // Fetch current weather and user preferences (implement this part)
    final currentConditions = getCurrentConditions();

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    print("${widget.recommendationPromptString}");
    final prompt = TextPart(
        "${widget.recommendationPromptString}"
            "And more instructions are as follows: ${widget.extraInputCommand}"
            "Current Conditions in my location $currentConditions."
            "The firebase data for upper body segment of the outfit: ${upperOutfits.docs.map((doc) => doc.data()).toList()}. The firebase data for lower body segment of the outfit: ${lowerOutfits.docs.map((doc) => doc.data()).toList()}"
    );

    final response = await model.generateContent([
      Content.multi([
        prompt
      ])
    ]);
    final responseText = response.text;

    print(responseText);

    // Parse the response
    final outfitRecommendation = json.decode(responseText!);

    setState(() {
      shirtImageUrl = outfitRecommendation["upper_body"]["downloadUrl"];
      pantImageUrl = outfitRecommendation["lower_body"]["downloadUrl"];
      message = outfitRecommendation["compliment_or_advice"];
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animatedComplimentKey.currentState?.setCompliment(message);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outfit of the Day')),
      body: isLoading ? _buildLoadingScreen() : OutfitOfTheDay(
        shirtImageUrl: shirtImageUrl,
        pantImageUrl: pantImageUrl,
        complimentOrAdvice: message,
        animatedComplimentKey: _animatedComplimentKey,
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _orbAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _orbRotationAnimation.value,
                child: Transform.scale(
                  scale: _orbScaleAnimation.value,
                  child: Image.asset('assets/orb.png', width: 100, height: 100),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Text(
            "Our AI is crafting your perfect look...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}