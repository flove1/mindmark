
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmark/auth/screen.dart';
import 'package:mindmark/helpers/fonts.dart';
import 'package:mindmark/notes/folder.dart';
import 'package:mindmark/notes/note.dart';
import 'package:mindmark/screens/folder_content_screen.dart';
import 'package:mindmark/screens/folders_screen.dart';
import 'package:mindmark/screens/note_editor.dart';

class PinnedFolders extends StatefulWidget {
  const PinnedFolders({ Key? key }) : super(key: key);

  @override
  PinnedFoldersState createState() => PinnedFoldersState();
}

class PinnedFoldersState extends State<PinnedFolders> {
  final Stream<QuerySnapshot> _pinnedFoldersStream = FirebaseFirestore.instance
      .collection('folders')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('user_folders')
      .where('pinned', isEqualTo: true)
      .snapshots();

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: _pinnedFoldersStream, 
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        //TODO: image instead of text
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text("No pinned folders", style: TextStyles.paragraph),
        );
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        //TODO: loading animation
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Loading", style: TextStyles.paragraph),
        );
      }

      var folders = snapshot.data!.docs.map((doc) => Folder.fromSnapshot(doc)).toList();
      var columnCount = max(MediaQuery.of(context).size.width ~/ 200, 1);

      return Table(
        children: List.generate((folders.length / columnCount).ceil(), (index) {
          List<Widget> children = folders.asMap().entries
            .where((entry) => index * columnCount <= entry.key && entry.key < ((index + 1) * columnCount))
            .map((entry) => Container(
              margin: const EdgeInsets.all(6),
              child: FolderWidget(
                folder: entry.value,
              )
            ))
            .toList();

          if (children.length < columnCount) {
            for (var i = 0; i <= (columnCount - children.length - 1); i++) {
              children.add(Container());
            }
          }

          return TableRow(
            children: children
          );
        })
      );
    }
  );
}

class RecentNotesTable extends StatefulWidget {
  const RecentNotesTable({ Key? key }) : super(key: key);

  @override
  RecentNotesState createState() => RecentNotesState();
}

class RecentNotesState extends State<RecentNotesTable> {
  final Stream<QuerySnapshot> _recentNotesStream = FirebaseFirestore.instance
    .collection('notes')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('user_notes')
    .orderBy('modified_at', descending: true)
    .limit(4)
    .snapshots();

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: _recentNotesStream, 
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text("No recent notes", style: TextStyles.paragraph, textAlign: TextAlign.center,),
          )
        );
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        //TODO: loading animation
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text("Loading...", style: TextStyles.paragraph, textAlign: TextAlign.center),
          )
        );
      }

      var notes = snapshot.data!.docs.map((doc) => Note.fromSnapshot(doc)).toList();
      var columnCount = max(MediaQuery.of(context).size.width ~/ 300, 1);

      return SliverMasonryGrid.count(
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childCount: notes.length,
        crossAxisCount: columnCount,
        itemBuilder: (context, index) {
          return NoteWidget(note: notes[index], limitContent: true,);
        },
      );
    }
  );
}
class PinnedNotes extends StatefulWidget {
  const PinnedNotes({ Key? key }) : super(key: key);

  @override
  PinnedNotesState createState() => PinnedNotesState();
}

class PinnedNotesState extends State<PinnedNotes> {
  final Stream<QuerySnapshot> _pinnedNotesStream = FirebaseFirestore.instance
    .collection('notes')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('user_notes')
    .where('pinned', isEqualTo: true)
    .snapshots();

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: _pinnedNotesStream, 
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text("No pinned notes", style: TextStyles.paragraph, textAlign: TextAlign.center),
          )
        );
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        //TODO: loading animation
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text("Loading...", style: TextStyles.paragraph, textAlign: TextAlign.center),
          )
        );
      }

      var notes = snapshot.data!.docs.map((doc) => Note.fromSnapshot(doc)).toList();
      var columnCount = max(MediaQuery.of(context).size.width ~/ 300, 1);

      return SliverMasonryGrid.count(
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childCount: notes.length,
        crossAxisCount: columnCount,
        itemBuilder: (context, index) {
          return NoteWidget(note: notes[index]);
        },
      );
    }
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {  
  final _key = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerTheme: const DividerThemeData(color: Colors.transparent),
                  ),
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Menu", style: TextStyles.title.copyWith(color: Colors.white),),
                        IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 32, color: Colors.white,))
                      ],
                    )
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          useRootNavigator: true,
                          useSafeArea: false,
                          // enableDrag: false,
                          isScrollControlled: true,
                          // backgroundColor: Colors.red,
                          context: context, 
                          builder: (context) {
                            return const SizedBox.expand(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("TO BE DONE", textAlign: TextAlign.center)
                              ),
                            );
                          });
                      }, 
                      icon: const Icon(Icons.settings),
                      label: const Text(
                        "Account settings", 
                        style: TextStyles.button
                      )
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FoldersScreen()
                          )
                        );
                      }, 
                      icon: const Icon(Icons.folder),
                      label: const Text(
                        "Folders", 
                        style: TextStyles.button
                      )
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FolderContentScreen(showAllNotes: true)
                          )
                        );
                      }, 
                      icon: const Icon(Icons.note_alt),
                      label: const Text(
                        "All notes", 
                        style: TextStyles.button
                      )
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut()
                          .then((value) => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const AuthScreen())
                          ));
                      }, 
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Logout", 
                        style: TextStyles.button
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
          endDrawer: Container(
            color: Colors.blue,
          ),
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).primaryColor,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light
            ),
            leading: Builder(builder: (context) => GestureDetector(
              child: Icon(Icons.menu, size: 30, color: Theme.of(context).primaryColor),
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
            )),
            actions: const [
              Padding(
                padding: EdgeInsets.all(4),
                child: ClipOval(child: Image(image: AssetImage('./assets/person.jpg'))),
              )
            ],
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              constraints: BoxConstraints.loose(const Size.fromWidth(800)),
              child: CustomScrollView(
                slivers: [
                  SliverList.list(
                    children: [
                        Text("Hello, ${FirebaseAuth.instance.currentUser!.email}", style: TextStyles.paragraphTitle),
                        const Text("Note your thoughts", style: TextStyles.paragraph),
                    ],
                  ),
                  SliverList.list(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 16),
                        child: const Text("Pinned Folders", style: TextStyles.paragraphTitle),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: PinnedFolders(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const FoldersScreen()
                                )
                              );
                            }, 
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("See all", style: TextStyles.paragraph),
                                Icon(Icons.arrow_right_alt, size: 36)
                              ]
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text("Pinned Notes", style: TextStyles.paragraphTitle),
                    ),
                  ),
                  const PinnedNotes(),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FolderContentScreen()
                              )
                            );
                          }, 
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("See unorganized notes", style: TextStyles.paragraph),
                              Icon(Icons.arrow_right_alt, size: 36)
                            ]
                          )
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text("Recent Files", style: TextStyles.paragraphTitle),
                    ),
                  ),
                  const RecentNotesTable(),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FolderContentScreen(showAllNotes: true)
                              )
                            );
                          }, 
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("See all notes", style: TextStyles.paragraph),
                              Icon(Icons.arrow_right_alt, size: 36)
                            ]
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ),
          ),
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: Container(
            margin: const EdgeInsets.all(16),
            child: ExpandableFab(
              type: ExpandableFabType.fan,
              distance: 128,
              key: _key,
              openButtonBuilder: FloatingActionButtonBuilder(
                size: 120,
                builder: (context, onPressed, progress) => AnimatedBuilder(
                  animation: progress,
                  builder: (context, child) => Container(
                    margin: EdgeInsets.all(4 * progress.value),
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
                      padding: EdgeInsets.all(8 + 4 * (1.0 - progress.value)),
                      onPressed: onPressed,
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
                ),
              ),
              closeButtonBuilder: FloatingActionButtonBuilder(
                size: 120,
                builder: (context, onPressed, progress) => AnimatedBuilder(
                  animation: progress,
                  builder: (context, child) => Container(
                    margin: EdgeInsets.all(4 * progress.value),
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
                      onPressed: onPressed,
                      padding: EdgeInsets.all(8 + 4 * (1.0 - progress.value)),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF)
                      ),
                      icon: const Icon(
                        Icons.close,
                        size: 40,
                      ),
                      color: Theme.of(context).primaryColor
                    ),
                  ),  
                ),
              ),
              children: [
                Container(
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
                    onPressed: () => showDialog(context: context, builder: (context) => newNoteDialog(context)),
                    padding: const EdgeInsets.all(16),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF)
                    ),
                    icon: const Icon(
                      Icons.note_alt,
                      size: 40,
                    ),
                    color: Theme.of(context).primaryColor
                  ),
                ),
                Container(
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
                  child: IconButton.filled(
                    onPressed: () => showDialog(context: context, builder: (context) => newFolderDialog(context)),
                    padding: const EdgeInsets.all(16),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF)
                    ),
                    icon: const Icon(
                      Icons.folder,
                      size: 40,
                    ),
                    color: Theme.of(context).primaryColor
                  ),
                ),
                Container(
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
                  child: IconButton.filled(
                    onPressed: () async {
                      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                      if (pickedFile == null) {
                        return;
                      }

                      var inputImage = InputImage.fromFilePath(pickedFile!.path);

                      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
                      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
                      
                      String text = recognizedText.text;    

                      Note note = Note(title: "Scanned text", content: text);

                      FirebaseFirestore.instance
                        .collection("notes")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("user_notes")
                        .add(note.toMap())
                        .then(
                          (note) => note.get().then((value) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => NoteEditor(note: Note.fromSnapshot(value))
                                )
                              );
                            }
                          )
                        );
                      
                    },
                    padding: const EdgeInsets.all(16),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF)
                    ),
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 40,
                    ),
                    color: Theme.of(context).primaryColor
                  ),
                ),
              ],
            ),
          )
        ),
      ],
    );
  }
}