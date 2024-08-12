import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import '../service/PromptService.dart';
import 'OutfitRecommendationPage.dart';

class AIBuddyScreen extends StatefulWidget {
  @override
  _AIBuddyScreenState createState() => _AIBuddyScreenState();
}

class _AIBuddyScreenState extends State<AIBuddyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _text = '';

  String recommendationPrompt = "";

  String defaultText = 'Hold the mic to start speaking';

  @override
  void initState() {
    super.initState();
    fetchRecommendationPrompt();
    _animationController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_animationController);
    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(_animationController);

    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15,5,15,5),
            decoration: BoxDecoration(
              color: Color(0xFFC6F432),
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              'AI Buddy',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFFC6F432),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                'Online',
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.asset('assets/orb.png', width: 200, height: 200),
              ),
            );
          },
        ),
        SizedBox(height: 40),
        Text(
          _text.isNotEmpty ? _text : defaultText,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(FontAwesomeIcons.keyboard, color: Colors.grey),
            onPressed: () {},
          ),
          GestureDetector(
            onTapDown: (_) => _startListening(),
            onTapUp: (_) => _stopListening(),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Color(0xFFC6F432),
                shape: BoxShape.circle,
              ),
              child: Icon(FontAwesomeIcons.microphone, color: Colors.black, size: 40,),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _animationController.duration = Duration(seconds: 1);
        _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_animationController);
        _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
        await _flutterTts.speak("Listening");
        await Future.delayed(Duration(seconds: 1));
        _speech.listen(
          onResult: (result) => setState(() {
            _text = result.recognizedWords;
          }),
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _text = capitalizeFirstLetter(_text);
      });
      _speech.stop();
      _animationController.duration = Duration(seconds: 5);
      _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_animationController);
      _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(_animationController);
      setState(() => _isListening = false);
      if(_text.trim().isNotEmpty) {
        routeToRecommendationScreen();
      }
    }
  }

  void routeToRecommendationScreen() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OutfitRecommendationPage(recommendationPromptString: recommendationPrompt, extraInputCommand: _text,)),
    );
  }

  void fetchRecommendationPrompt() async {
    PromptService promptService = PromptService();
    recommendationPrompt = await promptService.getRecommendationPrompt();
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

}