import 'dart:async';
// import 'dart:html';
// import 'package:mygramm/Pages/AccountSettingsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygramm/Pages/ChattingPage.dart';
import 'package:mygramm/Models/user.dart';
import 'package:mygramm/Pages/AccountSettingsPage.dart';
import 'package:mygramm/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mygramm/main.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key key, @required this.currentUserId});
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  final String currentUserId;

  homePageHeader() {
    return AppBar(
      automaticallyImplyLeading: false, //reomove the back button
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.settings,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Setting()));
          },
        )
      ],
      backgroundColor: Colors.lightBlue,
      title: Container(
        margin: new EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          style: TextStyle(fontSize: 18.0, color: Colors.white),
          controller: searchTextEditingController,
          decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            filled: true,
            prefixIcon: Icon(Icons.person_pin, color: Colors.white, size: 30.0),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: emptyTextFormField,
            ),
          ),
          onFieldSubmitted: controlSearching,
        ),
      ),
    );
  }

  controlSearching(String userName) {
    Future<QuerySnapshot> allFoundUsers = FirebaseFirestore.instance
        .collection("users")
        .where("nickname", isGreaterThanOrEqualTo: userName)
        .get();

    setState(() {
      futureSearchResults = allFoundUsers;
    });
  }

  emptyTextFormField() {
    searchTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homePageHeader(),
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUserFoundScreen(),
      // body: ElevatedButton.icon(
      //     onPressed: logoutUser,
      //     icon: Icon(Icons.close),
      //     label: Text("Sign Out")),
    );
    // return ElevatedButton.icon(
    //     onPressed: logoutUser,
    //     icon: Icon(Icons.close),
    //     label: Text("Sign Out"));
  }

  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchUserResult = [];
        //getting User List From FirebaseFirestore
        //data inni jedhu Qinifii Qaba Ture
        dataSnapshot.data.docs.forEach((doc) {
          Userr eachUser = Userr.fromDocument(doc);
          UserResult userResult = UserResult(eachUser);

          if (currentUserId != doc["id"]) {
            searchUserResult.add(userResult);
          }
        });
        return ListView(children: searchUserResult);
      },
    );
  }

  displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group, color: Colors.lightBlueAccent, size: 200.0),
            Text(
              "Search Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 50.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final Userr eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => sendUserToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickname,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "joined: " +
                      DateFormat("dd MMMM, yyyy - hh:mm:aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(eachUser.createdAt))),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendUserToChatPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder:(context)=> Chat(
        receiverId : eachUser.id,
        receiverAvatar: eachUser.photoUrl,
        receiverName: eachUser.nickname,
      )
    ));
  }
}
