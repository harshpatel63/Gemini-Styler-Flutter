import 'package:flutter/material.dart';

import '../widgets/AnimatedCompliment.dart';

class OutfitOfTheDay extends StatelessWidget {
  final String imageUrl;
  final String message;
  final GlobalKey<AnimatedComplimentState> animatedComplimentKey;

  const OutfitOfTheDay({Key? key, required this.imageUrl, required this.message, required this.animatedComplimentKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("ImageUrl = $imageUrl");
    return Column(
      children: [
        SizedBox(height: 20), // Add spacing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AspectRatio(
              aspectRatio: 3/4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Spacer(), // Add spacing
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AnimatedCompliment(key: animatedComplimentKey)
        ),
        Spacer()
      ],
    );
  }
}