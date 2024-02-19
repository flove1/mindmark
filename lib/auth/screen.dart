import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:mindmark/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({ Key? key }) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context){
    return FlutterLogin(
      userType: LoginUserType.email,
      logo: Image.asset('assets/logo.png').image,
      loginAfterSignUp: true,
      theme: LoginTheme(
        pageColorLight: Theme.of(context).canvasColor,
        pageColorDark: Theme.of(context).canvasColor,
        cardTheme: CardTheme(
          color: Colors.white,
        ),
      ),
      hideForgotPasswordButton: true,
      onSignup: signUp,
      onLogin: signIn, 
      onRecoverPassword: (data) {
        return null;
      }
    );
  }

  Future<String?> signIn(LoginData data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: data.name, password: data.password)
        .then((value) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen())
        ));
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(SignupData data) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: data.name!, password: data.password!)
        .then((value) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen())
        ));
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

}