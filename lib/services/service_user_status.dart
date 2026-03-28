import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatusService {
  void updateStatus() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final dbRef = FirebaseDatabase.instance.ref("status/$uid");
    final firestoreRef = FirebaseFirestore.instance.collection("Users").doc(uid);

    final online = {
      "state": "online",
      "lastSeen": ServerValue.timestamp,
    };

    final offline = {
      "state": "offline",
      "lastSeen": ServerValue.timestamp,
    };

    // Listen connection state
    FirebaseDatabase.instance.ref(".info/connected").onValue.listen((event) {
      final isConnected = event.snapshot.value as bool? ?? false;

      if (!isConnected) return;

      // When app disconnects → mark offline
      dbRef.onDisconnect().set(offline);

      // When connected → mark online
      dbRef.set(online);
    });

    // 🔥 Sync Realtime DB → Firestore
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;

      if (data == null) return;

      final isOnline = data["state"] == "online";

      firestoreRef.set({
        "isOnline": isOnline,
        "lastSeen": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}