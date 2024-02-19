import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mindmark/helpers/fonts.dart';
import 'package:mindmark/notes/folder.dart';
import 'package:mindmark/notes/note.dart';

class FolderContentScreen extends StatefulWidget {
  final Folder? folder;
  final bool showAllNotes;
  const FolderContentScreen(
    { Key? key, this.folder, bool? showAllNotes}): 
      showAllNotes = showAllNotes ?? false, 
      super(key: key);

  @override
  FolderContentScreenState createState() => FolderContentScreenState();
}

class FolderContentScreenState extends State<FolderContentScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _notesStream;
  late TextEditingController _textController;
  Set<String> _keywords = {};

  @override
  void initState() {
    _textController = TextEditingController();
    if (widget.showAllNotes == true) {
      _notesStream = FirebaseFirestore.instance
        .collection('notes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_notes')
        .snapshots();
    }
    else if (widget.folder == null) {
      _notesStream = FirebaseFirestore.instance
        .collection('notes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_notes')
        .where('folder_id', isNull: true)
        .snapshots();
    }
    else {
      _notesStream = FirebaseFirestore.instance
        .collection('notes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_notes')
        .where('folder_id', isEqualTo: widget.folder!.id!)
        .snapshots();
    }

    _textController.addListener(() {
      setState(() {
        _keywords = _textController.text.split(RegExp(r'[^\w]+')).toSet();
        _keywords.retainWhere((word) => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(word));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Builder(
              builder: (context) {
                String title;

                if (widget.showAllNotes == true) {
                  title = "All notes";
                }
                else if (widget.folder == null) {
                  title = "Unorganized notes";
                }
                else {
                  title = widget.folder!.title;
                }

                return Text(
                  title, 
                  style: TextStyles.title
                );
              },
            ),
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
            sliver: SliverList.list(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40D3D4E2),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: CupertinoTextField(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    style: TextStyles.paragraph,
                    placeholderStyle: const TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.placeholderText),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Icons.search, color: Color(0xFF807A7A)),
                    ),
                    placeholder: "Search",
                    controller: _textController,
                  )
                ),
              ]
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: StreamBuilder(
              stream: _notesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: Text("Loading!"));
                }

                var notes = snapshot.data!.docs.map((doc) => Note.fromSnapshot(doc))
                .where((element) {
                  if (_keywords.isEmpty) {
                    return true;
                  }

                  return element.getKeywords().toSet().intersection(_keywords).isNotEmpty;
                })
                .toList();
                var columnCount = MediaQuery.of(context).size.width ~/ 200;

                return SliverMasonryGrid.count(
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: notes.length,
                  crossAxisCount: columnCount,
                  itemBuilder: (context, index) {
                    return NoteWidget(note: notes[index]);
                  },
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
              (context) => newNoteDialog(context, folderId: widget.folder?.id)
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
    )      
  );
}