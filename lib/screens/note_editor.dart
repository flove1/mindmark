import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mindmark/helpers/fonts.dart';
import 'package:mindmark/notes/note.dart';

enum EditorMode {
  redact,
  view
}

class NoteEditor extends StatefulWidget {
  final Note note;

  const NoteEditor({ Key? key, required this.note }) : super(key: key);

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late DocumentReference<Map<String, dynamic>> _noteRef;
  late EditorMode _mode;

  @override
  void initState() {
    _mode = EditorMode.redact;
    _noteRef = FirebaseFirestore.instance
        .collection('notes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_notes')
        .doc(widget.note.id);
    _titleController = TextEditingController(text: widget.note.title);
    _bodyController = TextEditingController(text: widget.note.content);
    super.initState();
  }

  @override
  void dispose() {
    _noteRef.update(
      {
        'content': _bodyController.text
      }
    );

    _noteRef.update(
      {
        'title': _titleController.text
      }
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: GestureDetector(
              child: Icon(Icons.arrow_back, size: 30, color: Theme.of(context).primaryColor),
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              PopupMenuButton(
                icon: Icon(Icons.more_vert, size: 30, color: Theme.of(context).primaryColor),
                offset: const Offset(0, 50),
                itemBuilder: (context) {
                  return [
                      const PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.attach_file),
                              SizedBox(width: 8),
                              Text("Attach file", style: TextStyles.folderTitle,),
                            ],
                          ),
                      ),
                      const PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text("Delete", style: TextStyles.folderTitle,),
                            ],
                          ),
                      ),
                      PopupMenuItem<int>(
                        value: 2,
                        child: Builder(
                          builder: (context) {
                            if (widget.note.pinned) {
                              return Row(
                                children: [
                                  Icon(Icons.star, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 8),
                                  const Text("Unpin", style: TextStyles.folderTitle),
                                ],
                              );
                            }
                            else {
                              return Row(
                                children: [
                                  Icon(Icons.star_border, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 8),
                                  const Text("Pin", style: TextStyles.folderTitle),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                  ];
                },
                elevation: 4,
                surfaceTintColor: Colors.transparent,
                color: Colors.white,
                onSelected: (value) {
                  var ref = FirebaseFirestore.instance
                    .collection('notes')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('user_notes')
                    .doc(widget.note.id);

                  if (value == 0) {
                  } else if (value == 1) {
                    ref.delete().then((value) => Navigator.of(context).pop());
                  } else if(value == 2) {
                    widget.note.pinned = !widget.note.pinned;

                    ref.update({
                      "pinned": widget.note.pinned
                    });
                  }
                }
              ),
            ],
            snap: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          SliverList.list(
            children: [
              Builder(
                builder: (context) {
                  switch (_mode) {
                    case EditorMode.redact:
                      return TextFormField(
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter note title...",
                          hintStyle: TextStyles.title.apply(color: Colors.black45),
                          contentPadding: const EdgeInsets.all(0.0)
                        ),
                        style: TextStyles.title,
                        controller: _titleController,
                        maxLines: 1,
                      );
                    case EditorMode.view:
                      return MarkdownBody(
                        data: "# ${_titleController.text}",
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          h1: TextStyles.title,
                          p: TextStyles.paragraph
                        ),
                      );
                  }
                }
              ),
              Builder(
                builder: (context) {
                  switch (_mode) {
                    case EditorMode.redact:
                      return TextFormField(
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter note text...",
                          hintStyle: TextStyles.noteParagraph.apply(color: Colors.black45),
                          contentPadding: const EdgeInsets.all(0.0)
                        ),
                        style: TextStyles.noteParagraph,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: _bodyController,
                      );
                    case EditorMode.view:
                      return MarkdownBody(
                        data: _bodyController.text,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          h1: TextStyles.paragraphTitle,
                          p: TextStyles.noteParagraph
                        ),
                      );
                  }
                }
              ),
              if (_mode == EditorMode.redact) 
                Column(
                  children: [
                    const Divider(
                      indent: 64,
                      endIndent: 64,
                      color: Colors.black38,
                    ),
                    Text(
                      "end of the text", 
                      textAlign: TextAlign.center,
                      style: TextStyles.paragraph.copyWith(color: Colors.black38)
                    )
                  ],
                )
            ]
          ),

          // SliverPadding(
          //   padding: EdgeInsets.symmetric(horizontal: 32),
          //   sliver: SliverList.list(
          //     children: [
          //       Container(
          //         margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          //         decoration: const BoxDecoration(
          //           boxShadow: [
          //             BoxShadow(
          //               color: Color(0x40D3D4E2),
          //               spreadRadius: 0,
          //               blurRadius: 8,
          //               offset: Offset(0, 0),
          //             ),
          //           ],
          //         ),
          //         child: CupertinoTextField(
          //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          //           decoration: BoxDecoration(
          //             color: Color(0xFFFFFFFF),
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           style: TextStyle(fontWeight: FontWeight.bold),
          //           placeholderStyle: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.placeholderText),
          //           prefix: const Padding(
          //             padding: EdgeInsets.only(left: 16),
          //             child: Icon(Icons.search, color: Color(0xFF807A7A)),
          //           ),
          //           placeholder: "Search",
          //           controller: _textController,
          //         )
          //       ),
          //     ]
          //   ),
          // ),
          // SliverPadding(
          //   padding: EdgeInsets.symmetric(horizontal: 32),
          //   sliver: StreamBuilder(
          //     stream: _notesStream,
          //     builder: (context, snapshot) {
          //       if (!snapshot.hasData) {
          //         return SliverToBoxAdapter(child: Text("No notes!"));
          //       }

          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return SliverToBoxAdapter(child: Text("Loading!"));
          //       }

          //       var notes = snapshot.data!.docs.map((doc) => Note.fromSnapshot(doc)).toList();
          //       var columnCount = MediaQuery.of(context).size.width ~/ 200;

          //       return SliverMasonryGrid.count(
          //         mainAxisSpacing: 8,
          //         crossAxisSpacing: 8,
          //         childCount: notes.length,
          //         crossAxisCount: columnCount,
          //         itemBuilder: (context, index) {
          //           return NoteCard(note: notes[index]);
          //         },
          //       );
          //     },
          //   )
          // )
        ],
      ),      
    ),
    floatingActionButton: Container(
      margin: const EdgeInsets.all(8),
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
        padding: const EdgeInsets.all(16),
        onPressed: () {
          setState(() {
            var newIndex = (EditorMode.values.indexOf(_mode) + 1) % EditorMode.values.length;

            _mode = EditorMode.values[newIndex];
          });

        },
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF)
        ),
        icon: Builder(
          builder: (context) {
            switch (_mode) {
              case EditorMode.redact:
                return const Icon(Icons.edit, size: 40,);
              case EditorMode.view:
                return const Icon(Icons.chrome_reader_mode_outlined, size: 40);
              default:
                return const Icon(Icons.question_mark, size: 40);
            }
          } 
        ),
        color: Theme.of(context).primaryColor
      ),
    )
  );
}