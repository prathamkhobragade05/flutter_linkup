import 'dart:io';

import 'package:linkup/screen_home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service_firebase.dart';


String getImageUrl(String fileName) {
  final supabase=Supabase.instance.client;
  String imageUrl= supabase.storage.from("linkup").getPublicUrl(fileName);
  return imageUrl;
}

Future<bool> uploadImage(File file) async {
  final supabase=Supabase.instance.client;
  // final String fileExt = file.path.split('.').last;
  // final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
  final String fileName=loggedUserId;

  final String filePath = fileName;

  try {
    await supabase.storage.from("linkup")
        .upload(filePath, file);
    String uploadUrl="https://ptqgasrzgpgjxdxxzayt.supabase.co/storage/v1/object/public/linkup/$filePath";
    await updateUserData("ProfileImage",uploadUrl);
    return true;
  }
  catch (e) {
    return false;
  }
}


Future<bool> removeImage(String fileName) async {
  final supabase=Supabase.instance.client;
  try{
    await supabase.storage.from("linkup").remove([fileName]);
    await updateUserData("ProfileImage",null);
    return true;
  }catch(e){
    print("removeing error-------------------$e");
    return false;
  }
}


