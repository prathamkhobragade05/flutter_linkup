import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart'hide Column;
import 'package:linkup/screen_home.dart';
import 'package:linkup/screen_login.dart';
import 'package:linkup/screen_user_profile_.dart';
import 'package:linkup/screen_user_profile_edit.dart';
import 'package:flutter/material.dart';
import 'package:linkup/service_firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/app_database.dart';
import 'main.dart';

bool defaultImage=false;
late ImageProvider imageProvider;

class UserProfile extends StatefulWidget{
  final String profileUserId;
  final bool isEditable;
  const UserProfile(this.profileUserId,this.isEditable, {super.key});

  @override
  UserProfileStatee createState() => UserProfileStatee();
}


class UserProfileStatee extends State<UserProfile> {
  late String profileUserId=widget.profileUserId;
  late bool isEditable=widget.isEditable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditable?"My Profile":"Profile"),),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: getUserProfile(profileUserId)
        ),
      ),
                                                                                //-----log out button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: !isEditable?null:ElevatedButton(
          onPressed: () async {
            signOut();
            Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (_) => LoginScreen()),(route) => false,
            );
          },
          child: const Text("Log out"),
        ),
      ),
    );
  }

  Widget getUserProfile(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: getUser(userId),
      builder: (context, snapshot) {

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text("No user data found"));
        }

        var user = snapshot.data!.data() as Map<String, dynamic>;
        var profileImage= user['ProfileImage'];
        var username= user['Username'] ?? "linkup2026";
        var email= user['Email'] ?? "linkup@gmail.com";
        var phone= user['Phone Number'] ?? "+91 0000000000";

        if(profileImage!=null){
          defaultImage=false;
          imageProvider = NetworkImage(profileImage);
        }else{
          defaultImage=true;
          imageProvider = const AssetImage("assets/images/default_user.jpg");
        }

        return Column(
          children: [
            CircleAvatar(
              minRadius: 50,
              maxRadius: 80,
              backgroundImage: imageProvider,
              child: InkWell(
                  onTap: () async {
                    if(!defaultImage){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProfileView("Profile",imageProvider,isEditable)));
                    }
                    else{
                      UserProfileViewState userProfileView=UserProfileViewState();
                      userProfileView.pickImage();
                    }
                  }
              ),
            ),
            options(Icons.person, "Username", username),
            options(Icons.phone, "Phone Number",phone),
            options(Icons.email, "Email",email),
            if(isEditable)
              options(Icons.lock, "Password","password"),
          ],
        );
      },
    );
  }

  ListTile options(IconData lead,String title,String subTitle){
    if(title.toLowerCase()=="password"){
      subTitle="* * * * * * *";
    }
    return ListTile(
      leading: Icon(lead),
      title: Text(title),
      subtitle: Text(subTitle),
      trailing: !isEditable?null:IconButton(
        onPressed: (){
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))
            ),
            isScrollControlled: true,
            builder:(context){
              return SizedBox(
                // height: MediaQuery.of(context).viewInsets.bottom + 400,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 20,
                      top: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom+20,
                  ),

                  child: BottomSheetModel(title,subTitle),
                ),
              );
            },
          );
        },
        icon: Icon(Icons.edit),
      ),
    );
  }



  Future<void> updateUserData(int userId, String field, String value) async {
    DBUsersCompanion data;

    switch (field) {
      case "Username":
        data = DBUsersCompanion(userName: Value(value));
        break;

      case "Email":
        data = DBUsersCompanion(userEmail: Value(value));
        break;

      case "Phone Number":
        data = DBUsersCompanion(userPassword: Value(value));
        break;

      default:
        return; // no update
    }

    await (db.update(db.dBUsers)
      ..where((tbl) => tbl.userId.equals(userId)))
        .write(data);
  }
                                                                                //-----log out function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}