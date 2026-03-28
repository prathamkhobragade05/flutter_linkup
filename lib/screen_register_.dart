
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/screen_home.dart';
import 'package:linkup/screen_login.dart';
import 'package:flutter/material.dart';
import 'package:linkup/service_firebase.dart';


class RegisterScreen extends StatefulWidget{
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}


class RegisterScreenState extends State<RegisterScreen> {
  bool isLoading = false;
  bool isRegistered=false;
  String? errorMessage;
  bool _isPassHiddenC = true;
  bool _isPassHidden = true;

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerPasswordR = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Register")),
        body:Stack(
          children: [
            AbsorbPointer(
              absorbing: isLoading,
              child: AbsorbPointer(
                absorbing: isLoading,
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child:Center(
                        child: SingleChildScrollView(
                            child: Form(
                                child: Column(
                                  children: [
                                    if (errorMessage != null)
                                      Text(
                                        errorMessage!,
                                        style: TextStyle(color: isRegistered?Colors.green:Colors.red),
                                      ),
//----------input Email
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
//----------input username
                                    TextFormField(
                                      controller: controllerUsername,
                                      decoration: InputDecoration(
                                        labelText: "Username",
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
//----------input Password
                                    TextFormField(
                                      controller: controllerPassword,
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
//----------input password repeat
                                    TextFormField(
                                      controller: controllerPasswordR,
                                      obscureText: _isPassHiddenC,
                                      // obscuringCharacter: "*",
                                      decoration: InputDecoration(
                                          labelText: "Repeat Password",
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
                                              _isPassHiddenC= !_isPassHiddenC;
                                              setState(() {});
                                            },
                                            icon: Icon(_isPassHiddenC ? Icons.visibility_off:Icons.visibility,),
                                          )
                                      ),
                                    ),
                                    SizedBox(height: 30),
//----------button register
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async{
                                          FocusScope.of(context).unfocus();

                                          String message=" ";
                                          setState(() {
                                            errorMessage=message;
                                            isLoading=true;
                                          });

                                          String inputEmail=controllerEmail.text.toString().trim().toLowerCase();
                                          String inputUsername=controllerUsername.text.toString().trim();
                                          String inputPass=controllerPassword.text.toString().trim();
                                          String inputPassR=controllerPasswordR.text.toString().trim();

                                          if(!inputValidation(inputEmail,inputUsername,inputPass,inputPassR)){
                                            setState(() => isLoading = false);
                                            return;
                                          }

                                          try{
                                            String? userId=await userRegister(inputEmail,inputPass,inputUsername);
                                            if (userId != null) {
                                              isRegistered=true;
                                              message="Authentication successful";
                                              if (mounted){
                                                Future.delayed(const Duration(seconds: 2), () {
                                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(userId)));
                                                });
                                              }
                                            }
                                          }
                                          catch(e){
                                            if (e is FirebaseAuthException) {
                                              switch (e.code) {
                                                case 'email-already-in-use':
                                                  message="This email is already registered";

                                                case 'invalid-email':
                                                  message="Please enter a valid email address";

                                                case 'weak-password':
                                                  message="Password must be at least 7 characters long";

                                                case 'operation-not-allowed':
                                                  message= "Email/password accounts are not enabled";

                                                case 'network-request-failed':
                                                  message= "No internet connection";

                                                default:
                                                  message= "Registration failed. Please try again";
                                              }
                                            }
                                          }
                                          finally{
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
                                        child: !isLoading?Text("Register"):SizedBox(
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
                                        Text("Already have an account?"),
                                        TextButton(
                                            onPressed: (){
                                              Navigator.pop(
                                                  context, MaterialPageRoute(builder: (context)=>LoginScreen())
                                              );
                                            },
                                            child: Text("Login")),
                                      ],
                                    ),
                                  ],
                                )
                            )
                        )
                    )
                ),
              )
            ),
          ],
        )
    );
  }

  bool inputValidation(String inputEmail,String inputUsername,String inputPass,String inputPassR) {
    bool isValid=false;
    String? message;

    if(inputEmail.isNotEmpty && inputUsername.isNotEmpty && inputPass.isNotEmpty && inputPassR.isNotEmpty){
      if(inputPass.length>6){
        if(inputPass==inputPassR){
          isValid=true;
        }
        else{
          message="Confirm password doesn't match";
          isValid=false;
        }
      }
      else{
        message="Password must be at least 7 characters long";
        isValid=false;
      }
    }
    else{
      message="All fields are required";
      isValid=false;
    }
    if(!isValid){
      setState(() {
        errorMessage=message;
      });
    }
    return isValid;
  }

}