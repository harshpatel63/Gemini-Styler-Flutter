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

class _OutfitRecommendationPageState extends State<OutfitRecommendationPage> {
  String shirtImageUrl = '';
  String pantImageUrl = '';
  String message = '';
  String prompt = '';
  final GlobalKey<AnimatedComplimentState> _animatedComplimentKey = GlobalKey<AnimatedComplimentState>();


  @override
  void initState() {
    super.initState();
      getOutfitOfTheDay(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> getOutfitOfTheDay(String userId) async {
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
      _animatedComplimentKey.currentState?.setCompliment(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outfit of the Day')),
      body: OutfitOfTheDay(
        shirtImageUrl: shirtImageUrl,
        pantImageUrl: pantImageUrl,
        complimentOrAdvice: message,
        animatedComplimentKey: _animatedComplimentKey,
      ),
    );
  }
}