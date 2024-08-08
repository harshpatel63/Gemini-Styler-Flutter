import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'OutfitDetailScreen.dart';

class OutfitListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outfit List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('outfit_ratings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new Container(
                child: new SingleChildScrollView(
                    child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              children: List.generate(
                snapshot.data?.docs.length ?? 0,
                (index) {
                  final outfit =
                      snapshot.data?.docs[index].data() as Map<String, dynamic>;
                  return StaggeredGridTile.count(
                    crossAxisCellCount: index.isEven ? 2 : 1,
                    mainAxisCellCount: index.isEven ? 2 : 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OutfitDetailScreen(
                              outfit: outfit,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.network(
                          outfit['downloadUrl'] ??
                              "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
