import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/screen_home.dart';
import 'package:linkup/screen_register_.dart';
import 'package:flutter/material.dart';
import 'package:linkup/service_firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();

}

class LoginScreenState extends State<LoginScreen>{
  bool isLoading = false;
  bool isAuthenticate=false;
  String? errorMessage;

  bool _isPassHidden=true;
  late int userId;
  TextEditingController controllerEmail=TextEditingController();
  TextEditingController controllerPass=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Login")),
      body:Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child:Center(
                  child: SingleChildScrollView(
                    child: Form(
                      child:Column(
                        children: [
                          if (errorMessage != null)
                            Text(
                              errorMessage!,
                              style: TextStyle(color:isAuthenticate?Colors.green:Colors.red),
                            ),
//---input email
                          TextFormField(
                            controller: controllerEmail,
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color:Colors.black12,
                                      width: 2
                                  )
                              ),
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          SizedBox(height: 30),
//---input password
                          TextFormField(
                            controller: controllerPass,
                            obscureText: _isPassHidden,
                            decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color:Colors.black12,
                                        width: 2
                                    )
                                ),
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: (){
                                    _isPassHidden= !_isPassHidden;
                                    setState(() {});
                                  },
                                  icon: Icon(_isPassHidden ? Icons.visibility_off:Icons.visibility,),
                                )
                            ),
                          ),
                          SizedBox(height: 40),
//------login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();

                                String? userId;
                                String message=" ";
                                isAuthenticate=false;

                                setState(() {
                                  errorMessage=message;
                                  isLoading=true;
                                });
                                String inputEmail= controllerEmail.text.toString().toLowerCase().trim();
                                String inputPass= controllerPass.text.toString().trim();

                                if(!inputValidation(inputEmail,inputPass)){
                                  setState(() => isLoading = false);
                                  return;
                                }
//------firebase service
                                try{
                                  userId= await userLogin(inputEmail,inputPass);
                                  if (userId != null) {
                                    isAuthenticate=true;
                                    message="Authentication successful";
                                    if (mounted){
                                      Future.delayed(const Duration(seconds: 2), () {
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(userId!)),);
                                      });
                                    }
                                  }
                                }catch(e){
                                  if (e is FirebaseAuthException) {
                                    switch (e.code) {
                                      case 'network-request-failed':
                                        message="No internet access";
                                        break;

                                      case 'invalid-credential':
                                        message="Incorrect email or password";
                                        break;

                                      case 'user-not-found':
                                        message="No user found";
                                        break;

                                      case 'wrong-password':
                                        message="Incorrect password";
                                        break;

                                      case 'invalid-email':
                                        message="Invalid email";
                                        break;

                                      default:
                                        message= "Login failed. Please try again";
                                    }
                                  }
                                }finally{
                                  setState(() {
                                    errorMessage=message;
                                    isLoading=false;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape:RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  )
                              ),
                              child: !isLoading?Text("Login"):SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?"),
                              TextButton(
                                  onPressed: (){
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context)=>RegisterScreen())
                                    );
                                  },
                                  child: Text("Register")),
                            ],
                          ),
                        ],
                      ) ,
                    ),
                  ),
                )
            ),
          ),
        ],
      )
    );
  }

  bool inputValidation(String inputEmail, String inputPassword){
    bool isValid=false;
    String? message;
    if(inputEmail.isNotEmpty && inputPassword.isNotEmpty){
      if(inputPassword.length>6){
        isValid= true;
      }else{
        message="Password must be at least 7 characters long";
        isValid= false;
      }
    }else{
      message="All fields are required";
      isValid= false;
    }
    if(!isValid){
      setState(() {
        errorMessage=message;
      });
    }
    return isValid;
  }

  Future<void> saveLogin() async {                                              //----save login session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userId", userId);
    await prefs.setBool('isLoggedIn', true);
  }
}