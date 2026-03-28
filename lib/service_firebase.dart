import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

var firebaseCurrentUser=FirebaseAuth.instance.currentUser!;

Future<String?> userLogin(String email, String password) async {
  UserCredential userCredential =
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return userCredential.user!.uid;
}

Future userRegister(String email, String password, String username) async {
  await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password
  );
  final userId= FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore.instance.collection("Users")
      .doc(userId)
      .set({
    "Email": email,
    "ProfileImage":null,
    "Username":username,
    "Phone Number": null
  });
  return userId;
}

Stream<QuerySnapshot> getHomeScreenUsers() {
  return FirebaseFirestore.instance
      .collection('Users')
      .snapshots();
}


Stream<DocumentSnapshot> getUser(String uid) {
  return FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .snapshots();
}

Future updateUserData(String field, String? value) async{
  await FirebaseFirestore.instance.collection("Users")
      .doc(firebaseCurrentUser.uid)
      .update({
        field:value
      });
}

Future<bool> sendEmailLink(String newEmail) async{
  try{
    await firebaseCurrentUser.verifyBeforeUpdateEmail(newEmail);
    return true;
  }catch(e){
    return false;
  }
}

Future<bool> reAuthenticateUser(String password) async {
  String? email=firebaseCurrentUser.email;
  print("----------------->>>>>>>$email----->>>>----------$password");
  AuthCredential credential = EmailAuthProvider.credential(
    email: email!,
    password: password,
  );
  try{
    await firebaseCurrentUser.reauthenticateWithCredential(credential);
    return true;
  }catch(e){
    return false;
  }
}

Stream<QuerySnapshot> getChatIdMessages(String chattingId) {
  return FirebaseFirestore.instance
      .collection('Chats').doc(chattingId).collection("Messages").orderBy("TimeStamp", descending: true)
      .snapshots();
}

Future<void> insertMessagesToFirebase(String chattingId, dynamic message, DateTime timestamp ) async {
  try{
    String messageId=timestamp.millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance
        .collection("Chats")
        .doc(chattingId)
        .collection("Messages")
        .doc(messageId)
        .set(message);

  }catch(e){}
}

void signOut() async{
  FirebaseAuth.instance.signOut();
}
