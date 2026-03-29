import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:linkup/screen_home.dart';

import '../service_firebase.dart';

class UserStatus {

  final _db = FirebaseDatabase.instance.ref();
  late final userRef = _db.child('status/$loggedUserId');

  void startMonitoring() {
    FirebaseFirestore.instance.collection("Users")
        .doc(firebaseCurrentUser.uid)
        .update({
      "isOnline": true
    });

    _db.child('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;

      userRef.onDisconnect().set({
        'state': 'offline'
      });

      // Set online immediately
      userRef.set({
        'state': 'online',
      });

      // if(!connected) return;
      if(connected){
        FirebaseFirestore.instance.collection("Users")
            .doc(loggedUserId)
            .update({
          "isOnline": true
        });
        print("userStatus -----------++++-status-- true");
      }else{
        FirebaseFirestore.instance.collection("Users")
            .doc(loggedUserId)
            .update({
          "isOnline": false
        });
        print("userStatus -----------++++-status-- false");
      }
    });
  }

  void setOffline(){
    FirebaseFirestore.instance.collection("Users")
        .doc(firebaseCurrentUser.uid)
        .update({
          "isOnline": false
        });
  }
}