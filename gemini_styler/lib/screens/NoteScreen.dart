import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini_styler/widgets/AnimatedCompliment.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final GlobalKey<AnimatedComplimentState> _animatedComplimentKey = GlobalKey<AnimatedComplimentState>();
  final TextEditingController _noteController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _loadNote();
  }

  void _loadNote() async {
    if (_userId != null) {
      final doc = await FirebaseFirestore.instance.collection('notes').doc(_userId).get();
      if (doc.exists) {
        setState(() {
          _noteController.text = doc.data()?['content'] ?? '';
        });
      }
    }
  }

  void _saveNote() async {
    _animatedComplimentKey.currentState?.setCompliment(_noteController.text);
    if (_userId != null && _noteController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notes').add({
        'userId': _userId,
        'content': _noteController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note saved')));
      _noteController.clear(); // Clear the text field after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              maxLines: null,
              decoration: InputDecoration(hintText: 'Write your note here...'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Save Note'),
              onPressed: _saveNote,
            ),
            SizedBox(height: 16),
            Container(
              child: AnimatedCompliment(key: _animatedComplimentKey),
            )
          ],
        ),
      ),
    );
  }
}