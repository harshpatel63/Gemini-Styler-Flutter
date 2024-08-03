import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_styler/widgets/AnimatedCompliment.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

const String apiKey = 'YOUR_GEMINI_API_KEY';

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedComplimentState> _animatedComplimentKey = GlobalKey<AnimatedComplimentState>();
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  Timer? _timer;
  String? apiResponseText;
  late AnimationController _animationController;
  String displayText = '';
  bool isAnimatingText = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    // Find the rear main camera
    CameraDescription? backCamera;
    for (final camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        backCamera = camera;
        break;
      }
    }

    if (backCamera == null) {
      print('No rear camera found');
      return;
    }

    _controller = CameraController(
    backCamera,
    ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    _initializeControllerFuture?.then((_) {
      _timer = Timer(Duration(seconds: 5), _takePicture);
    });
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = join(
        directory.path,
        'test.png',
      );

      XFile picture = await _controller!.takePicture();
      await picture.saveTo(imagePath);
      await _sendPhotoToNetwork(imagePath);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendPhotoToNetwork(String imagePath) async {
    print('Sending photo to network: $imagePath');

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final firstImage = await File(imagePath).readAsBytes();
    final prompt = TextPart('''
You are an AI stylist. The user in this picture is asking you "How am I looking today?" Analyze the outfit in the provided image and generate a JSON response with ratings for each subtopic on a scale of 1-10. Include a UUID for the query, an overall rating for the outfit, and a compliment about the overall look. Do not provide any explanations or descriptions beyond the compliment.

Return your analysis in the following JSON format:

{
  "uuid": "Generate a unique UUID for this query",
  "gender": "Identified gender",
  "overall_rating": "Rate the overall look of the outfit from 1-10",
  "compliment": "Provide a catchy, sweet compliment (max 100 characters) about the overall look, using wordplay or a pun related to fashion or the occasion",
  "occasion_appropriateness": {
    "formal": 0,
    "business_casual": 0,
    "weekend": 0,
    "interview": 0,
    "beach": 0,
    "special_event": 0,
    "exercise": 0,
    "running_errands": 0,
    "lounging": 0
  },
  "climate_suitability": {
    "hot_humid": 0,
    "warm_sunny": 0,
    "cool_breezy": 0,
    "chilly": 0,
    "freezing": 0,
    "rainy_snowing": 0,
    "transitional": 0
  },
  "body_type_flattering": {
    "hourglass": 0,
    "pear_shaped": 0,
    "apple_shaped": 0,
    "petite": 0,
    "tall": 0,
    "athletic": 0,
    "curvy": 0,
    "slender": 0,
    "broad_shoulders": 0,
    "wide_hips": 0
  },
  "style_execution": {
    "classic": 0,
    "minimalist": 0,
    "bohemian": 0,
    "edgy": 0,
    "preppy": 0,
    "vintage": 0,
    "grunge": 0,
    "streetwear": 0,
    "glamorous": 0,
    "romantic": 0,
    "feminine": 0,
    "masculine": 0
  },
  "color_harmony": {
    "monochrome": 0,
    "complementary": 0,
    "analogous": 0,
    "neutral_palette": 0,
    "bold_accents": 0,
    "patterns_prints": 0,
    "color_blocking": 0
  }
}

Replace all '0' values with your actual ratings from 1 to 10. Ensure that every field has a rating, even if it's not directly applicable. The 'gender' field should contain the identified gender as a string. Generate a unique UUID for each query and include it in the 'uuid' field. Provide an overall rating for the outfit in the 'overall_rating' field.

For the 'compliment' field, provide a brief, catchy, and sweet compliment about the overall look of the outfit. This compliment should be memorable, using wordplay or a pun related to type of the outfit or the occasion, and should not exceed 100 characters. For example, "You're sew stylish, you've got this outfit all buttoned up!" or "Beach, please! Your seaside style is making waves!"

Return only the JSON object without any additional text or explanation.
''');    final imagePart = DataPart("image/png", firstImage);
    final response = await model.generateContent([
      Content.multi([prompt, imagePart])
    ]);
    final responseText = response.text;
    print(responseText);
    saveOutfitRating(responseText!);
    Map<String, dynamic> jsonMap = json.decode(responseText!);

    // Extract the "compliment" field
    final compliment = jsonMap['compliment'];
    setState(() {
      apiResponseText = compliment;
      _animationController.stop();
      isAnimatingText = true;
    });

    _animatedComplimentKey.currentState?.setCompliment(compliment);
  }

  // void _animateText(String text) {
  //   setState(() {
  //     displayText = '';
  //   });
  //   Future.delayed(Duration(milliseconds: 100), () {
  //     for (int i = 0; i <= text.length; i++) {
  //       Future.delayed(Duration(milliseconds: 50 * i), () {
  //         setState(() {
  //           displayText = text.substring(0, i);
  //         });
  //       });
  //     }
  //     setState(() {
  //       isAnimatingText = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI fashion assistant')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                SizedBox(height: 20), // Add spacing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: AspectRatio(
                      aspectRatio: 3/4,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Add spacing
                  Visibility(
                    visible: !isAnimatingText,
                    child: Center(
                      child: ScaleTransition(
                        scale: _animationController,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20), // Add spacing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AnimatedCompliment(key: _animatedComplimentKey)
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  Future<void> saveOutfitRating(String jsonData) async {
    try {
      // Ensure user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Parse the JSON data
      Map<String, dynamic> ratingData = json.decode(jsonData);

      // Add timestamp and user ID to the data
      ratingData['timestamp'] = FieldValue.serverTimestamp();
      ratingData['userId'] = user.uid;

      // Save the data to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('outfit_ratings')
          .doc(ratingData['uuid'])
          .set(ratingData);

      print('Outfit rating saved successfully');
    } catch (e) {
      print('Error saving outfit rating: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserOutfitRatings() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('outfit_ratings')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching user outfit ratings: $e');
      rethrow;
    }
  }
}