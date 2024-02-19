import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mindmark/helpers/fonts.dart';
import 'package:mindmark/notes/folder.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({ Key? key }) : super(key: key);

  @override
  FoldersScreenState createState() => FoldersScreenState();
}

class FoldersScreenState extends State<FoldersScreen> {
  final Stream<QuerySnapshot> _foldersStream = FirebaseFirestore.instance
      .collection('folders')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('user_folders')
      .snapshots();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text("All folders", style: TextStyles.title,),
          centerTitle: true,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back, size: 30, color: Theme.of(context).primaryColor),
            onTap: () => Navigator.pop(context),
          ),
          snap: true,
          floating: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          sliver: StreamBuilder(
            stream: _foldersStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(child: Text("No notes!"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Text("Loading!"));
              }

              var folders = snapshot.data!.docs.map((doc) => Folder.fromSnapshot(doc)).toList();
              var columnCount = max(MediaQuery.of(context).size.width ~/ 200, 1);

              return SliverMasonryGrid.count(
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childCount: folders.length,
                crossAxisCount: columnCount,
                itemBuilder: (context, index) => FolderWidget(folder: folders[index], editable: true)
              );
            },
          )
        )
      ],
    ),
    floatingActionButton: Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x80D3D4E2),
            spreadRadius: 5,
            blurRadius: 30,
            offset: Offset(-2, 1),
          ),
        ]
      ),
      child: IconButton(
        padding: const EdgeInsets.all(12),
        onPressed: () {
          showDialog(
            context: context, builder: 
            (context) => newFolderDialog(context)
          );
        },
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF)
        ),
        icon: const Icon(
          Icons.add,
          size: 40,
        ),
        color: Theme.of(context).primaryColor
      ),
    ),   
  );

}