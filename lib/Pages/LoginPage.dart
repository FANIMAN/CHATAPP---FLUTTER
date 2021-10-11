import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mygramm/Pages/HomePage.dart';
import 'package:mygramm/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;

  bool isLoggedIn = false;
  bool isLoading = false;
  User currentUser; //FirebaseUser

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoggedIn = true;
    });

    preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: preferences.getString("id"))));
    }

    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Chat App',
                style: TextStyle(
                    fontSize: 82, color: Colors.white, fontFamily: "Signatra"),
              ),
              GestureDetector(
                onTap: controlSignIn,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 278.0,
                        height: 65.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage("assets/images/signIn_button.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(1.0),
                        child: isLoading ? circularProgress() : Container(),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Future<Null> controlSignIn() async {
    preferences = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);

    User firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    //Sign In Success
    if (firebaseUser != null) {
      //check if already signed up
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("users")
          .where("id", isEqualTo: firebaseUser.uid)
          .get();

      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      //Save data to Firestore  - if new user
      if (documentSnapshots.length == 0) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser.uid)
            .set({
          "nickname": firebaseUser.displayName,
          "photoUrl": firebaseUser.photoURL,
          "id": firebaseUser.uid,
          "aboutMe": "I am Using Faniman Chat App",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null
        });

        //Write to local data
        currentUser = firebaseUser;
        await preferences.setString("id", currentUser.uid);
        await preferences.setString("nickname", currentUser.displayName);
        await preferences.setString("photoUrl", currentUser.photoURL);
      } else {
        //Write to local data   i.e yoo Userichi jira tae just data isaa dubbisudha.
        currentUser = firebaseUser;
        await preferences.setString("id", documentSnapshots[0]["id"]);
        await preferences.setString(
            "nickname", documentSnapshots[0]["nickname"]);
        await preferences.setString(
            "photoUrl", documentSnapshots[0]["photoUrl"]);
        await preferences.setString("aboutMe", documentSnapshots[0]["aboutMe"]);
        //In Which One Is Always And The Other Thing Is It Is ALways And It Is One Of My 
      }
      Fluttertoast.showToast(msg: "Congrats. Sign In Successful!");
      this.setState(() {
        isLoading = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: firebaseUser.uid)));
    }

    

    //Sign In Failed
    else {
      Fluttertoast.showToast(msg: "Try Again. Sign In Failed!");
      this.setState(() {
        isLoading = false;
      });
    }
  }
}

