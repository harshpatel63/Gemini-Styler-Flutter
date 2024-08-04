import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_styler/widgets/AnimatedCompliment.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final String promptString;
  const CameraScreen({Key? key, required this.promptString}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

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
    final prompt = TextPart(widget.promptString);
    final imagePart = DataPart("image/png", firstImage);
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
                Spacer(), // Add spacing
                  Visibility(
                    visible: !isAnimatingText,
                    child: Center(
                      child: RotationTransition(
                        turns: Tween<double>(begin: 0, end: 1).animate(_animationController),
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
                          ),
                          child: Container(
                            width: 70,
                            height: 70,
                            child: CircleAvatar(
                              backgroundImage: AssetImage('assets/orb.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Spacer(),// Add spacing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AnimatedCompliment(key: _animatedComplimentKey)
                ),
                Spacer()
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