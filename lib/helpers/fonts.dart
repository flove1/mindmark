import 'package:flutter/material.dart';

class Insets {
  static const double xsmall = 3;
  static const double small = 4;
  static const double medium = 5;
  static const double large = 10;
  static const double extraLarge = 20;
}

const medium = FontWeight.w500;
const semibold = FontWeight.w600;
const bold = FontWeight.w700;

class TextStyles {
  static const TextStyle title = TextStyle(fontWeight: semibold, fontSize: 23);
  static const TextStyle paragraphTitle = TextStyle(fontWeight: bold, fontSize: 14);
  static const TextStyle paragraph = TextStyle(fontSize: 13);
  static const TextStyle button = TextStyle(fontWeight: semibold, fontSize: 18);
  static const TextStyle logo = TextStyle(fontWeight: bold, fontSize: 32);
  static const TextStyle folderTitle = TextStyle(fontWeight: semibold, fontSize: 14);
  static const TextStyle folderSubtitle = TextStyle(fontSize: 10);
  static const TextStyle noteCardTitle = TextStyle(fontWeight: medium, fontSize: 12);
  static const TextStyle noteCardText = TextStyle(fontSize: 10);
  static const TextStyle noteParagraph = TextStyle(fontSize: 16);
  static const TextStyle popupTitle = TextStyle(fontWeight: medium, fontSize: 22);
}