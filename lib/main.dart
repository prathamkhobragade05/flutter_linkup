import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/screen_home.dart';
import 'package:linkup/screen_login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'database/app_database.dart';
import 'package:firebase_core/firebase_core.dart';

AppDatabase db = AppDatabase();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://ptqgasrzgpgjxdxxzayt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0cWdhc3J6Z3BnanhkeHh6YXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQzNDY5ODIsImV4cCI6MjA4OTkyMjk4Mn0.r47jNO01CL78-xifLtqe6c4KVvj0kp6lm2ol1EMcHV8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: FutureBuilder(
        future: checkUser(),
        builder: (context, snapshot) {
          // if (!snapshot.hasData) {
          //   return const CircularProgressIndicator();
          // }
          var user= snapshot.data;
          if (user !=null) {
            String userId=user.uid;
            return HomeScreen(userId);
          }
          else {
            return LoginScreen();
          }
        },
      ),
    );
  }
                                                                                //-----check logged in or not
  Future<int?> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && userId != null) {
      return userId;
    } else {
      return null;
    }
  }

  Future<User?> checkUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }
}
