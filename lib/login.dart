import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            Image.asset(
              "images/logo.jpg",
              fit: BoxFit.cover,
              width: 180.0,
            ),
            SizedBox(height: 30.0),
            Text(
              "Sign In",
              style: TextStyle(fontSize: 40.0, color: Colors.white),
            ),
            SizedBox(height: 10.0),
            Text(
              "Sign in now to plant for all.",
              style: TextStyle(fontSize: 20.0, color: Colors.grey),
            ),
            SizedBox(height: 120.0),
            SignInButton(
              Buttons.Google,
              text: "GOOGLE",
              onPressed: () {
                signInWithGoogle().whenComplete(() => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(title: "Home"),
                      ),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount googleUser = await googleSignIn.signIn();

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}
