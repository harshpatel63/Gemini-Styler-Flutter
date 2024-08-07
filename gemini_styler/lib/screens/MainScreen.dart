import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_styler/screens/OutfitRecommendationPage.dart';

import 'CameraScreen.dart';

class MainScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final String userName;
  final String prompt;
  final String recommendationPrompt;

  MainScreen({Key? key, required this.userName, required this.prompt, required this.recommendationPrompt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
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
              Text(
                'Hi, $userName 👋',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                        Icons.camera_alt,
                        Color(0xFFE7F9E6),
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
                                  builder: (context) => OutfitRecommendationPage(recommendationPromptString: recommendationPrompt)),
                            );
                          },
                          child: _buildFeatureCard(
                            'Recommend Outfit',
                            100,
                            14,
                            Icons.chat_bubble_outline,
                            Color(0xFFE6E7FD),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildFeatureCard(
                          'Search by Image',
                          100,
                          14,
                          Icons.image_search,
                          Color(0xFFFFF0E6),
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
              _buildHistoryItem(
                'I need to dress up for a special event...',
                Icons.mic,
                Color(0xFFE7F9E6),
              ),
              SizedBox(height: 12),
              _buildHistoryItem(
                'Suggest daily outfit...',
                Icons.chat_bubble_outline,
                Color(0xFFE6E7FD),
              ),
              SizedBox(height: 12),
              _buildHistoryItem(
                'Which outfit is best for an interview...',
                Icons.image_search,
                Color(0xFFFFF0E6),
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
                child: Icon(Icons.arrow_forward, color: Colors.black54),
              ),
            ],
          ),
          Spacer(),
          Text(
            title,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String text, IconData icon, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
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
            child: Icon(icon, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.more_vert),
        ],
      ),
    );
  }
}