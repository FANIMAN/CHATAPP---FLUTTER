import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mygramm/Widgets/FullImageWidget.dart';
import 'package:mygramm/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  Chat({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
    @required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          receiverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: receiverId, receiverAvatar: receiverAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;

  ChatScreen({Key key, this.receiverId, this.receiverAvatar}) : super(key: key);
  @override
  State createState() =>
      ChatScreenState(receiverId: receiverId, receiverAvatar: receiverAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  final String receiverId;
  final String receiverAvatar;

  ChatScreenState(
      {Key key, @required this.receiverId, @required this.receiverAvatar});
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isDisplayStricker;
  bool isLoading;

  File imageFile;
  String imageUrl;

  String chatId;
  SharedPreferences preferences;
  String id;
  var listMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);

    isDisplayStricker = false;
    isLoading = false;

    chatId = "";
    readLocal();
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";

    if (id.hashCode <= receiverId.hashCode) {
      chatId = '$id-$receiverId';
    } else {
      chatId = '$receiverId-$id';
    }

    FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({'chattingWith': receiverId});

    setState(() {});
  }

  onFocusChange() {
    if (focusNode.hasFocus) {
      //hide stickers whenever keypad appears
      setState(() {
        isDisplayStricker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              //create list of Messages
              createListMessages(),

              //Show Stickers
              (isDisplayStricker ? createStickers() : Container()),

              //Input Controllers
              createInput(),
            ],
          ),
          createLoading(),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  createLoading() {
    return Positioned(
      child: isLoading ? circularProgress() : Container(),
    );
  }

  Future<bool> onBackPress() {
    if (isDisplayStricker) {
      setState(() {
        isDisplayStricker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  //function
  createStickers() {
    return Container(
      child: Column(
        children: <Widget>[
          //First Row
          Row(
            children: <Widget>[
              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi1", 2),
                child: Image.asset(
                  "images/mimi1.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),

              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi2", 2),
                child: Image.asset(
                  "images/mimi2.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),

              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi3", 2),
                child: Image.asset(
                  "images/mimi3.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //Second Row
          Row(
            children: <Widget>[
              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi4", 2),
                child: Image.asset(
                  "images/mimi4.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),

              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi5", 2),
                child: Image.asset(
                  "images/mimi5.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),

              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi6", 2),
                child: Image.asset(
                  "images/mimi6.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          //Third Row
          Row(
            children: <Widget>[
              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi7", 2),
                child: Image.asset(
                  "images/mimi7.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),

              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi8", 2),
                child: Image.asset(
                  "images/mimi8.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),

              //FlatButton ture ija hin jirefudha Malee
              TextButton(
                onPressed: () => onSendMessage("mimi9", 2),
                child: Image.asset(
                  "images/mimi9.gif",
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisplayStricker = !isDisplayStricker;
    });
  }

  createListMessages() {
    return Flexible(
      child: chatId == ""
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .doc(chatId)
                  .collection(chatId)
                  .orderBy("timestamp", descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    ),
                  );
                } else {
                  listMessage = snapshot.data.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        createItem(index, snapshot.data.docs[index]),
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget createItem(int index, DocumentSnapshot document) {
    //My Messages - Right Side
    if (document["idFrom"] == id) {
      return Row(
        children: <Widget>[
          document["type"] == 0
              //Txt Msg
              ? Container(
                  child: Text(
                    document["content"],
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
                )

              //Image Msg
              : document["type"] == 1
                  ? Container(
                      child: TextButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlueAccent),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                "images/img_not_available.jpeg",
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document["content"],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: document["content"])));
                        },
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )

                  //Sticker  .gif Msg    //Else Ihe ne Malet nw Implement Yemideregewu
                  : Container(
                      child: Image.asset(
                        "images/${document['content']}.gif",
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    //Reciever Messages  - Left Side
    else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMsgLeft(index)
                    ? Material(
                      //display receiver profile image
                      child: CachedNetworkImage(
                           placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlueAccent),
                              ),
                              width: 35.0,
                              height: 35.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                            imageUrl: receiverAvatar,
                            width: 35.0,
                            height:35.0,
                            fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(18.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    )
                    :Container(width: 35.0,),
                    //displayMessages
                     document["type"] == 0
              //Txt Msg
              ? Container(
                  child: Text(
                    document["content"],
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                    left: 10.0,
                      ),
                )

                 //Image Msg
              : document["type"] == 1
                  ? Container(
                      child: TextButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlueAccent),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                "images/img_not_available.jpeg",
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document["content"],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: document["content"])));
                        },
                      ),
                      margin: EdgeInsets.only(
                          bottom: 10.0),
                    )

                    //Sticker  .gif Msg    //Else Ihe ne Malet nw Implement Yemideregewu

                    : Container(
                      child: Image.asset(
                        "images/${document['content']}.gif",
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
              ],
            ),
            isLastMsgLeft(index) 
            ? Container(
              child: Text(
                DateFormat("dd MMMM, yyyy - hh:mm:aa").format(DateTime.fromMillisecondsSinceEpoch((int.parse(document["timestamp"])))),
                style:TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 50.0, bottom: 5.0),
            ) 
            : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  createInput() {
    return Container(
      child: Row(
        children: <Widget>[
          //pick image icon button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.lightBlueAccent,
                onPressed: getImage,
                //onPressed: getImageFromGallery,
              ),
            ),
            color: Colors.white,
          ),

          //emoji icon button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                color: Colors.lightBlueAccent,
                onPressed: getSticker,
                //onPressed: getImageFromGallery,
              ),
            ),
            color: Colors.white,
          ),

          //TextField To Send Message
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: "Write here...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          //Send Message Icon Button
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.lightBlueAccent,
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
    );
  }

  void onSendMessage(String contentMsg, int type) {
    //type=0 its text msg
    //type=1 its imageFile
    //type=2 its sticker-emoji-gifs
    if (contentMsg != "") {
      textEditingController.clear();
      var docRef = FirebaseFirestore.instance
          .collection("messages")
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          docRef,
          { 
            "idFrom": id,
            "idTo": receiverId,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Empty Message can not be send.");
    }
  }

  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    // imageFile = (await _picker.pickImage(source: ImageSource.gallery)) as File;

    PickedFile pickedFile = await _picker.getImage(source: ImageSource.gallery);
    File imageFile;
    imageFile = File(pickedFile.path);

    //or
    // final XFile newImageFile = await _picker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      isLoading = true;
    }
    uploadImageFile();
  }

  Future uploadImageFile() async {
    String filename = DateTime.now().millisecondsSinceEpoch.toString();

    //StorageReference is depretiated Reference
    Reference storageReference =
        FirebaseStorage.instance.ref().child("Chat Images").child(filename);

    UploadTask storageUploadTask = storageReference.putFile(imageFile);
    TaskSnapshot storageTaskSnapshot;

    await storageUploadTask.then((value) {
      try {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          imageUrl = downloadUrl;
          setState(() {
            isLoading = false;
            onSendMessage(imageUrl, 1);
          });
        }, onError: (error) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Error" + error);
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Error" + error);
      }
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error" + error);
    });
  }
}

