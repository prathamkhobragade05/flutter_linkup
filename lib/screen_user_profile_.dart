
import 'dart:io';

import 'package:linkup/screen_home.dart';
import 'package:linkup/screen_user_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/services/api.dart';


class UserProfileView extends StatefulWidget{
  final ImageProvider? imageProvider;
  final String username;
  final bool isUserProfile;
  const UserProfileView(this.username,this.imageProvider,this.isUserProfile,{super.key});
  @override
  UserProfileViewState createState()=> UserProfileViewState();
}

class UserProfileViewState extends State<UserProfileView> {
  // bool isProfileDeleted= false;
  // bool isNewProfileImage=false;
  late bool isUserProfile=widget.isUserProfile;
  late ImageProvider? imageProvider=widget.imageProvider;
  late String username=widget.username;
                                                                                //---change profileImg
  List<IconButton> appBarActions(){
    return [
                                                                                //---change profileImg
      IconButton(onPressed: (){ pickImage(); }, icon: Icon(Icons.edit)),
                                                                                //---delete profileImg
      IconButton(onPressed: () async {
        if(await removeImage(loggedUserId)){
          // imageCache.clear();
          setState(() {
            Navigator.pop(context);
          });
        }

      }, icon: Icon(Icons.delete)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        actions: isUserProfile?appBarActions():null,
      ),
//--------body
      body:Center(
        child: Image(
          image: imageProvider??const AssetImage("assets/images/default_user.jpg"),
        ),
      )
    );
  }

  final ImagePicker picker = ImagePicker();
  Future pickImage() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if(pickedImage!=null){
      final CroppedFile? croppedImage=await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: true,
          )
        ],
      );

      if (croppedImage != null) {
        File? selectedImage = File(croppedImage.path);
        imageProvider = FileImage(selectedImage);
        if(!await uploadImage(selectedImage)){
          return;
        }
        if(defaultImage){
          setState(() {});
        }
      }
    }
  }
}