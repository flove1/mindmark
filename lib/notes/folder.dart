import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mindmark/helpers/fonts.dart';
import 'package:mindmark/screens/folder_content_screen.dart';

class Folder {
  String? id;
  String title;
  Color color;
  bool pinned;

  Folder({
    this.id,
    required this.title,
    required this.color,
    bool? pinned,
  }) : pinned = pinned ?? false;

  factory Folder.fromSnapshot(DocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Folder(
      id: snapshot.id,
      title: data['title'],
      color: Color(data['color']),
      pinned: data['pinned']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'color': color.value,
      'pinned': pinned,
    };
  }
}

class FolderWidget extends StatelessWidget {
  final Folder folder;
  final bool editable;

  const FolderWidget({
    super.key, 
    required this.folder,
    bool? editable,
  }) : editable = editable ?? false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FolderContentScreen(folder: folder)
      )
    ),
    child: Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          const BoxShadow(
            color: Color(0x80D3D4E2),
            spreadRadius: 0,
            blurRadius: 30,
            offset: Offset(15, 0),
          ),
          BoxShadow(
            color: folder.color,
            offset: const Offset(6, 0)
          )
        ],
        borderRadius: const BorderRadius.all(Radius.circular(12))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Builder(builder: (context) {
            if (!editable) {
              return Text(folder.title, style: TextStyles.folderTitle);
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(folder.title, style: const TextStyle(fontSize: 14)),

                PopupMenuButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    Icons.more_vert, 
                    color: Theme.of(context).primaryColor
                  ),
                  // icon: 
                  offset: const Offset(0, 50),
                  itemBuilder: (context){
                    return [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            const Text("Edit", style: TextStyles.folderTitle),
                          ],
                        ),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text("Delete folder", style: TextStyles.folderTitle),
                          ],
                        )
                      ),
                      PopupMenuItem<int>(
                        value: 2,
                        child: Builder(
                          builder: (context) {
                            if (folder.pinned) {
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
                      .collection('folders')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('user_folders')
                      .doc(folder.id);

                    if (value == 0) {
                      showDialog(
                        context: context, builder: 
                        (context) {
                          var color = folder.color.withAlpha(0xff);
                          var textController = TextEditingController(text: folder.title);

                          return AlertDialog(
                            elevation: 0,
                            content: Container(
                              width: 200,
                              height: 325,
                              child: ListView(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text("Edit folder", style: TextStyles.paragraphTitle,),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }, 
                                        icon: const Icon(Icons.close), 
                                        visualDensity: VisualDensity.compact
                                      )
                                    ],
                                  ),
                                  const Text("Name your folder", style: TextStyles.paragraph),
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
                                    placeholder: "Search",
                                    controller: textController,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Choose color of your folder", style: TextStyles.paragraph),
                                  SlidePicker(pickerColor: color, enableAlpha: false, onColorChanged: (newColor) {color = newColor;}),
                                ],
                              ),
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              FilledButton(
                                onPressed: () {
                                  folder.color = color.withAlpha(0x80);
                                  folder.title = textController.text;

                                  ref.update({
                                    'color': folder.color.value,
                                    'title': folder.title,
                                  });
                                  Navigator.of(context).pop();
                                }, 
                                child: const Text(
                                  "Save changes",
                                  style: TextStyles.button,
                                )
                              ),
                            ],
                          );
                        }
                      );
                    } else if (value == 1) {
                      FirebaseFirestore.instance
                        .collection('notes')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('user_notes')
                        .where('folder_id', isEqualTo: ref.id)
                        .get().then((snapshot) {
                          for (var doc in snapshot.docs) {
                            doc.reference.delete();
                          }
                        });

                      ref.delete();
                    } else if ( value == 2) {
                      folder.pinned = !folder.pinned;

                      ref.update({
                        'pinned': folder.pinned
                      });
                    }
                  }
                ),
              ],
            );     
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Divider(thickness: 0.5,),
          ),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('notes')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('user_notes')
                .where('folder_id', isEqualTo: folder.id)
                .count()
                .get(), 
            builder: (context, snapshot) {
              var childCount = 0;

              if (snapshot.hasData) {
                childCount = snapshot.data!.count!;
              }

              return Text("$childCount note${childCount > 1 ? 's': ''}", style: TextStyles.folderSubtitle);

            },
          )
        ],
      ),
    ),
  );
}

AlertDialog newFolderDialog(BuildContext context) {
  var color = Colors.pink.withOpacity(1.0);
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
              const Text("Create folder", style: TextStyles.paragraphTitle,),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                icon: const Icon(Icons.close), 
                visualDensity: VisualDensity.compact
              )
            ],
          ),
          const Text("Name your folder", style: TextStyles.paragraph),
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
            placeholder: "Name your folder....",
            controller: textController,
          ),
          const SizedBox(height: 8),
          const Text("Choose color of your folder", style: TextStyles.paragraph),
          SlidePicker(pickerColor: color, enableAlpha: false, onColorChanged: (newColor) {color = newColor;}),
        ],
      ),
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      FilledButton(
        onPressed: () {
          var folder = Folder(title: textController.text, color: color.withAlpha(0x80));

          FirebaseFirestore.instance
            .collection('folders')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('user_folders')
            .add(folder.toMap())
            .then((value) => value.get()
              .then((value) {
                var folder = Folder.fromSnapshot(value);
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => FolderContentScreen(folder: folder)));
              })
            );
        }, 
        child: const Text(
          "Save changes",
          style: TextStyles.button,
        )),
    ],
  );
}

