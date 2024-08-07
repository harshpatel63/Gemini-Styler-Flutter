import 'package:cloud_firestore/cloud_firestore.dart';

class PromptService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getPrompt() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('config').doc('prompt').get();
      if (doc.exists) {
        return doc.get('content') as String;
      } else {
        throw Exception('Prompt document does not exist');
      }
    } catch (e) {
      print('Error fetching prompt: $e');
      rethrow;
    }
  }

  Future<String> getRecommendationPrompt() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('config').doc('recommendation_prompt').get();
      if (doc.exists) {
        return doc.get('content') as String;
      } else {
        throw Exception('Recommendation Prompt document does not exist');
      }
    } catch (e) {
      print('Error fetching prompt: $e');
      rethrow;
    }
  }
}