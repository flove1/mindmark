import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mindmark/auth/screen.dart';
import 'package:mindmark/introduction/screen.dart';
import 'package:mindmark/screens/home_screen.dart';
import 'package:mindmark/settings/settings.dart';

import 'firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MindmarkApp());
}

class MindmarkApp extends StatelessWidget {
  const MindmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindMark',
      builder: FToastBuilder(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Nunito",
        colorScheme: const ColorScheme (
          brightness: Brightness.light, 
          primary: Color(0xFF00B267), 
          onPrimary: Color(0xFFF9F8FD), 
          secondary: Color(0xFFF9F8FD), 
          onSecondary: Color(0xFFF9F8FD), 
          error: Color(0xFFFFAAAA), 
          onError: Color(0xFF1E2124), 
          background: Color(0xFFF9F8FD), 
          onBackground: Color(0xFF1E2124), 
          surface: Color(0xFFF9F8FD), 
          onSurface: Color(0xFF1E2124),
          surfaceTint: Colors.transparent,
        ),
        useMaterial3: true,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        overscroll: false
      ),
      home: FutureBuilder<bool>(
        future: SettingsRepository.getSkipIntroduction(), 
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == false) {
            return const IntroScreen();
          }
          else if (FirebaseAuth.instance.currentUser == null) {
            return const AuthScreen();
          } 
          return const HomeScreen();
        }
      ),
    );
  }
}