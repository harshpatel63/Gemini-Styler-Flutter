import 'package:flutter/material.dart';
import '../widgets/AnimatedCompliment.dart';

class OutfitOfTheDay extends StatelessWidget {
  final String shirtImageUrl;
  final String pantImageUrl;
  final String complimentOrAdvice;
  final GlobalKey<AnimatedComplimentState> animatedComplimentKey;

  const OutfitOfTheDay({
    Key? key,
    required this.shirtImageUrl,
    required this.pantImageUrl,
    required this.complimentOrAdvice,
    required this.animatedComplimentKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'You should wear this TODAY!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                      child: _buildOutfitImage(shirtImageUrl, 'Top')
                  ),
                  Container(
                      alignment: Alignment.bottomRight,
                      child: _buildOutfitImage(pantImageUrl, 'Bottom')
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedCompliment(
              key: animatedComplimentKey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitImage(String imageUrl, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}