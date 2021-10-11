import 'dart:async';
import 'dart:io';
import 'package:xfile/xfile.dart' as XFILE;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mygramm/Widgets/ProgressWidget.dart';
import 'package:mygramm/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Account Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingScreen(),
    );
  }
}

class SettingScreen extends StatefulWidget {
  @override
  State createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  TextEditingController nickNameTextEditingController;
  TextEditingController aboutMeTextEditingController;

  SharedPreferences preferences;
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nickNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState

    readDataFromLocal();
  }

  void readDataFromLocal() async {
    //From local Storage Data Taqabala Jirra
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    nickname = preferences.getString("nickname");
    aboutMe = preferences.getString("aboutMe");
    photoUrl = preferences.getString("photoUrl");

    nickNameTextEditingController = TextEditingController(text: nickname);
    aboutMeTextEditingController = TextEditingController(text: aboutMe);

    setState(() {});
  }

  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    PickedFile pickedFile = await _picker.getImage(source: ImageSource.gallery);
    File newImageFile;
    newImageFile = File(pickedFile.path);

    // File newImageFile =
    //     (await _picker.pickImage(source: ImageSource.gallery)) as File;

    // File newImageFile =
    //     File(await _picker.pickImage(source: ImageSource.gallery));
    //(await _picker.pickImage(source: ImageSource.gallery)) as File;

    //or
    // final XFile newImageFile = await _picker.pickImage(source: ImageSource.gallery);

    if (newImageFile != null) {
      setState(() {
        // File file = newImageFile.toFile();
        this.imageFileAvatar = newImageFile;
        isLoading = true;
      });
    }

    uploadImageToFireStoreAndStorage();
  }

  Future uploadImageToFireStoreAndStorage() async {
    String mFileName = id;

    //StorageReference is depretiated Reference
    Reference storageReference =
        FirebaseStorage.instance.ref().child(mFileName);

    UploadTask storageUploadTask = storageReference.putFile(imageFileAvatar);
    TaskSnapshot storageTaskSnapshot;

    await storageUploadTask.then((value) {
      try {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;
          FirebaseFirestore.instance.collection("users").doc(id).update({
            "photoUrl": photoUrl,
            "aboutMe": aboutMe,
            "nickname": nickname,
          }).then((data) async {
            await preferences.setString("photoUrl", photoUrl);
            setState(() {
              isLoading = false;
            });

            Fluttertoast.showToast(msg: "Updated Successfully");
          });
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Error Occured In Getting Download Url");
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  void updateData() {
    nickNameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();

    setState(() {
      isLoading = false;
    });

    FirebaseFirestore.instance.collection("users").doc(id).update({
      "photoUrl": photoUrl,
      "aboutMe": aboutMe,
      "nickname": nickname,
    }).then((data) async {
      await preferences.setString("photoUrl", photoUrl);
      await preferences.setString("aboutMe", aboutMe);
      await preferences.setString("nickname", nickname);
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Updated Successfully");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              //Profile Image - Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (imageFileAvatar == null)
                          ? (photoUrl != "")
                              ? Material(
                                  //display already existing - old image file
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.lightBlueAccent),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(20.0),
                                    ),
                                    imageUrl: photoUrl,
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(125.0)),
                                  clipBehavior: Clip.hardEdge,
                                )

                              //Kun IMmo In Any Case Yoo photoUrl Keenya Hin Jiru Tae Icon Kana Display Godha By Default.
                              : Icon(
                                  Icons.account_circle,
                                  size: 90.0,
                                  color: Colors.grey,
                                )
                          : Material(
                              //Display the new updated image here
                              child: Image.file(
                                imageFileAvatar,
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(125.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          size: 100.0,
                          color: Colors.white54.withOpacity(0.3),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 200.0,
                      )
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

              //Input Fields
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isLoading ? circularProgress() : Container(),
                  ),

                  //Username
                  Container(
                    child: Text(
                      "Profile Name",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "e.g Fani Fike",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: nickNameTextEditingController,
                        onChanged: (value) {
                          nickname = value;
                        },
                        focusNode: nickNameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  Container(
                    child: Text(
                      "About Me/Bio",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Bio...",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: aboutMeTextEditingController,
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        focusNode: aboutMeFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              //Buttons
              Container(
                child: TextButton(
                  onPressed: updateData,
                  child: Text(
                    "Update",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                  ),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
              ),

              //Logout Buttom
              Padding(
                padding: EdgeInsets.only(left: 50.0, right: 50.0),
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: logoutUser,
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        )
      ],
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading:
      false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }
}
