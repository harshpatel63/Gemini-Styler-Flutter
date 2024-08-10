import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemini_styler/screens/AIBuddyScreen.dart';
import 'package:gemini_styler/screens/OutfitListScreen.dart';
import 'package:gemini_styler/screens/OutfitRecommendationPage.dart';
import 'package:text_gradiate/text_gradiate.dart';

import 'CameraScreen.dart';

class MainScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final String userName;
  final String prompt;
  final String recommendationPrompt;
  bool isDarkMode = false;

  MainScreen({Key? key, required this.userName, required this.prompt, required this.recommendationPrompt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          CircleAvatar(
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : AssetImage('assets/profile_photo.png') as ImageProvider,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextGradiate(
                text: Text(
                  'Hello, ${capitalizeFirstLetter(userName)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                colors: [Color(0xff4c7de5), Color(0xffd36678)],
                gradientType: GradientType.linear,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                tileMode: TileMode.clamp,
              ),
              SizedBox(height: 16),
              Text(
                'How may I help you today?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraScreen(promptString: prompt)),
                        );
                      },
                      child: _buildFeatureCard(
                        'Fit Check',
                        200,
                        30,
                        Icons.camera,
                        isDarkMode? Color(0xFFC6F432) : Color(0xFFE7F9E6),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OutfitRecommendationPage(recommendationPromptString: recommendationPrompt, extraInputCommand: "",)),
                            );
                          },
                          child: _buildFeatureCard(
                            'Recommend Outfit',
                            100,
                            14,
                            Icons.recommend,
                            isDarkMode ? Color(0xFFC09FF8) : Color(0xFFE6E7FD),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AIBuddyScreen()),
                            );
                          },
                          child: _buildFeatureCard(
                            'AI Buddy',
                            100,
                            14,
                            Icons.mic,
                            isDarkMode ? Color(0xFFFEC4DD) : Color(0xFFFFF0E6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI suggestions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See all'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OutfitRecommendationPage(recommendationPromptString: recommendationPrompt, extraInputCommand: "I need to dress up for a special event")),
                  );
                },
                child: _buildHistoryItem(
                  'I need to dress up for a special event...',
                  Icons.mic,
                  isDarkMode? Color(0xFFC6F432) : Color(0xFFE7F9E6),
                ),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OutfitRecommendationPage(recommendationPromptString: recommendationPrompt, extraInputCommand: "Suggest daily outfit")),
                  );
                },
                child: _buildHistoryItem(
                  'Suggest daily outfit...',
                  Icons.chat_bubble_outline,
                  isDarkMode ? Color(0xFFC09FF8) : Color(0xFFE6E7FD),
                ),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OutfitRecommendationPage(recommendationPromptString: recommendationPrompt, extraInputCommand: "Which outfit is best for an interview")),
                  );
                },
                child: _buildHistoryItem(
                  'Which outfit is best for an interview...',
                  Icons.image_search,
                  isDarkMode ? Color(0xFFFEC4DD) : Color(0xFFFFF0E6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, double h, double fontSize, IconData icon, Color bgColor) {
    return Container(
      height: h,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color(0x22000000),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(icon, color: Colors.black, size: 24),
                      )
                  )
              ),
              Spacer(),
              Align(
                alignment: Alignment.topRight,
                child: Icon(CupertinoIcons.arrow_up_right, color: Colors.black54),
              ),
            ],
          ),
          Spacer(),
          Text(
            title,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String text, IconData icon, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[isDarkMode ? 900 : 100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.black,),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Icon(Icons.more_vert, color: Colors.black,),
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
}