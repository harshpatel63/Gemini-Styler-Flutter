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

  const OutfitRecommendationPage({Key? key, required this.recommendationPromptString}) : super(key: key);

  @override
  _OutfitRecommendationPageState createState() => _OutfitRecommendationPageState();
}

String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

class _OutfitRecommendationPageState extends State<OutfitRecommendationPage> {
  String imageUrl = '';
  String message = '';
  String prompt = '';
  final GlobalKey<AnimatedComplimentState> _animatedComplimentKey = GlobalKey<AnimatedComplimentState>();


  @override
  void initState() {
    super.initState();
      getOutfitOfTheDay(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<Map<String, dynamic>> getOutfitOfTheDay(String userId) async {
    // Fetch user outfits from Firestore
    final outfits = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('outfit_ratings')
        .get();

    print(outfits.docs.map((doc) => doc.data()).toList());

    // Fetch current weather and user preferences (implement this part)
    final currentConditions = getCurrentConditions();

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    print("${widget.recommendationPromptString}");
    final prompt = TextPart(
        "${widget.recommendationPromptString}. Following is the data. Current Conditions in my location $currentConditions. The firebase data : ${outfits.docs.map((doc) => doc.data()).toList()}");
    final response = await model.generateContent([
      Content.multi([prompt])
    ]);
    final responseText = response.text;

    print(responseText);

    // Parse the response
    final outfitRecommendation = json.decode(responseText!);

    setState(() {
      message = outfitRecommendation["reason"];
      imageUrl = outfitRecommendation["downloadUrl"];
      _animatedComplimentKey.currentState?.setCompliment(message);
    });

    return outfitRecommendation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outfit of the Day')),
      body: OutfitOfTheDay(imageUrl: imageUrl, message: message, animatedComplimentKey: _animatedComplimentKey,),
    );
  }
}