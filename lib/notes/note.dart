import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mindmark/helpers/fonts.dart';
import 'package:mindmark/screens/note_editor.dart';

class Note {
  String? id;
  String? folderId;

  String title;
  String content;
  Color color;
  bool pinned;

  final DateTime createdAt;
  DateTime modifiedAt;

  Note({
    this.id,
    this.folderId,
    required this.title,
    required this.content,
    Color? color,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? pinned,
  }) : 
    createdAt = createdAt ?? DateTime.now(), 
    modifiedAt = modifiedAt ?? DateTime.now(), 
    color = color ?? Color(0x40FF0000),
    pinned = pinned ?? false;

  factory Note.fromQuerySnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Note(
      id: snapshot.id,
      folderId: data['folder_id'],
      title: data['title'],
      content: data['content'],
      color: Color(data['color']) ,
      createdAt: DateTime.parse(data['created_at']),
      modifiedAt: DateTime.parse(data['modified_at']),
      pinned: data['pinned']
    );
  }

  factory Note.fromSnapshot(DocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Note(
      id: snapshot.id,
      folderId: data['folder_id'],
      title: data['title'],
      content: data['content'],
      color: Color(data['color']) ,
      createdAt: DateTime.parse(data['created_at']),
      modifiedAt: DateTime.parse(data['modified_at']),
      pinned: data['pinned']
    );
  }

  Set<String> getKeywords() {
    List<String> keywords = title.split(RegExp(r'[^\w]+'));
    keywords.retainWhere((word) => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(word));
    return keywords.toSet();
  }

  Map<String, dynamic> toMap() {
    return {
      'folder_id': folderId,
      'title': title,
      'content': content,
      'color': color.value,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'pinned': pinned,
      'keywords': getKeywords().toList(),
    };
  }
}

class NoteWidget extends StatelessWidget {
  final Note note;
  final bool limitContent;

  const NoteWidget({
    super.key, 
    required this.note,
    bool? limitContent
  }) : limitContent = limitContent ?? false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditor(note: note)
      )
    ),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40D3D4E2),
            spreadRadius: 0,
            blurRadius: 30,
            offset: Offset(15, 0),
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: TextStyles.noteCardTitle,
          ),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            String content;
            if (limitContent) {
              content = note.content.characters.take(255).toString();
            }
            else {
              content = note.content;
            }

            return MarkdownBody(
              // padding: EdgeInsets.zero,
              data: content,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                h1: TextStyles.title,
                p: TextStyles.noteCardText
              ),
            );
          })
        ],
      ),
    ),
  );
}

AlertDialog newNoteDialog(BuildContext context, {String? folderId}) {
  var color = Colors.pinkAccent.withOpacity(1.0);
  var textController = TextEditingController();

  return AlertDialog(
    elevation: 0,
    content: SizedBox(
      width: 200,
      height: 325,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Create note", style: TextStyles.paragraphTitle,),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                icon: const Icon(Icons.close), 
                visualDensity: VisualDensity.compact
              )
            ],
          ),
          const Text("Name your note", style: TextStyles.paragraph),
          CupertinoTextField(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4DFDF))
            ),
            style: TextStyles.paragraph,
            placeholderStyle: TextStyles.paragraph.copyWith(
              color: CupertinoColors.placeholderText
            ),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.search, color: Color(0xFF807A7A)),
            ),
            placeholder: "Name your note....",
            controller: textController,
          ),
          const SizedBox(height: 8),
          const Text("Choose color of your note", style: TextStyles.paragraph),
          SlidePicker(pickerColor: color, enableAlpha: false, onColorChanged: (newColor) {color = newColor;}),
        ],
      ),
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      FilledButton(
        onPressed: () {
          FirebaseFirestore.instance
            .collection('notes')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('user_notes')
            .add(Note(
              folderId: folderId ?? "default",
              title: textController.text, 
              content: "", 
              color: color.withAlpha(0x40)
            ).toMap())
            .then(
              (note) => note.get().then((value) {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoteEditor(note: Note.fromSnapshot(value))
                    )
                  );
                }
              )
            );
        }, 
        child: const Text(
          "Continue",
          style: TextStyles.button,
        ))
        ,
    ],
  );
}