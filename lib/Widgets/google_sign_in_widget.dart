import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_assist_chat_app/Classes/user_chat.dart';
import 'package:focus_assist_chat_app/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  UserChat userChat;
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
      )
          : OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        onPressed: () async {
          handleSignIn();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/google_logo.png"),
                height: 35.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> handleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });

    if (await GoogleSignIn().isSignedIn()) await GoogleSignIn().disconnect();

    GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      User firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          // Update data to server if new user
          FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
            'nickname': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoURL,
            'id': firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'chattingWith': null
          });
        } else {
          DocumentSnapshot documentSnapshot = documents[0];
          userChat = UserChat.fromDocument(documentSnapshot);
        }
        Fluttertoast.showToast(msg: "Sign in success");
        this.setState(() {
          _isSigningIn = false;
        });

        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserChat: userChat,)));
      } else {
        Fluttertoast.showToast(msg: "Sign in fail");
        this.setState(() {
          _isSigningIn = false;
        });
      }
    }
    else {
      Fluttertoast.showToast(msg: "Can not init google sign in");
      this.setState(() {
        _isSigningIn = false;
      });
    }
  }
}