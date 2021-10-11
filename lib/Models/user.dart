import 'package:cloud_firestore/cloud_firestore.dart';

class Userr {
  final String id;
  final String nickname;
  final String photoUrl;
  final String createdAt;

  Userr({
    this.id,
    this.nickname,
    this.photoUrl,
    this.createdAt,
  });

  factory Userr.fromDocument(DocumentSnapshot doc) {
    return Userr(
      id:doc.id,
      // id: doc.documentID,
      photoUrl: doc['photoUrl'],
      nickname: doc['nickname'],
      createdAt: doc['createdAt'],
    );
  }
}