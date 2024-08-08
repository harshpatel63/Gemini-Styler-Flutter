import 'package:flutter/material.dart';

class OutfitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> outfit;

  const OutfitDetailScreen({Key? key, required this.outfit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              outfit['downloadUrl'],
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appbar
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      IconButton(
                        icon: Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {
                          // Handle favorite button press
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit['name'] ?? 'Outfit',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      _buildProgressBar('Occasion Appropriateness', outfit['occasion_appropriateness']),
                      SizedBox(height: 16.0),
                      _buildProgressBar('Climate Suitability', outfit['climate_suitability']),
                      SizedBox(height: 16.0),
                      _buildProgressBar('Body Type Flattering', outfit['body_type_flattering']),
                      SizedBox(height: 16.0),
                      _buildProgressBar('Style Execution', outfit['style_execution']),
                      SizedBox(height: 16.0),
                      _buildProgressBar('Color Harmony', outfit['color_harmony']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.0),
        ...data.entries.map((entry) {
          final value = entry.value as num;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(color: Colors.white),
                ),
                LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: Colors.grey.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}