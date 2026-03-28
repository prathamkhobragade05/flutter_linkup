
import 'package:flutter/material.dart';
import 'package:linkup/service_firebase.dart';

class BottomSheetModel extends StatefulWidget{
  final String title;
  final String subtitle;

  const BottomSheetModel(this.title, this.subtitle,{super.key});

  // const BottomSheetModel(this.title, this.subtitle,{super.key, required this.onUpdate});

  @override
  BottomSheetModelState createState()=> BottomSheetModelState();
}

class BottomSheetModelState extends State<BottomSheetModel> {
  late FocusNode firstFocusNode;
  late FocusNode secondFocusNode;

  late TextEditingController controllerInputOne;
  late TextEditingController controllerInputTwo;
  late String title,userValueNew,userValueOld,hintInputOne;
  String buttonText = "Save";
  bool isReadOnly=false;
  bool isSecondInputVisible=false;
  bool isPassword=false;
  bool autoFocus=true;

  String secondInputLabel="";
  String secondInputHint="";

  @override
  void initState() {
    super.initState();

    // Request focus when sheet opens
    firstFocusNode = FocusNode();
    secondFocusNode = FocusNode();

    // Auto focus first field
    Future.delayed(Duration(milliseconds: 300), () {
      firstFocusNode.requestFocus();
    });

    title=widget.title;
    controllerInputOne = TextEditingController();
    controllerInputTwo = TextEditingController();
    userValueOld = widget.subtitle;

    setTitleText();
    setButtonText();
  }

  @override
  void dispose() {
    firstFocusNode.dispose();
    secondFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
                                                                                //-------new input value
        TextFormField(
          focusNode: firstFocusNode,
          readOnly: isReadOnly,
          controller: controllerInputOne,
          obscureText: isPassword,
          decoration: InputDecoration(
            hint: Text(isPassword?"* * * * * *":userValueOld),
            labelText: title,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 20,),
                                                                                //------otp verification / confirm password
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: isSecondInputVisible
              ? TextFormField(
                  key: ValueKey("second"),
                  focusNode: secondFocusNode,
                  controller: controllerInputTwo,
                  obscureText: isPassword,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: secondInputLabel,
                    hint: Text(secondInputHint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              : SizedBox(),
        ),
        SizedBox(height: 20,),
                                                                                //-----save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () async {
                if(inputValidation() && (userValueOld!=controllerInputOne.text.toString())){
                  await buttonAction();
                }
                else{
                  return;
                }

                if(isReadOnly){
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).requestFocus(secondFocusNode);
                  });
                }
                setState(() { });
              },
              child: Text(buttonText)
          ),
        )
      ],
    );
  }
  void setTitleText(){
    if(title=="Password" || title=="Email"){
      title="Current Password";
      isPassword=true;
    }else{
      title="New $title";
    }
  }

  void setButtonText(){
    if(title.toLowerCase()=="new phone number"){
      buttonText="Send OTP";
    }
    else if(title.toLowerCase()=="current password"){
      buttonText="Verify";
    }else{
      buttonText="Save";
    }
  }

  bool inputValidation(){
    if(controllerInputOne.text.isNotEmpty){
      if(isSecondInputVisible){
        if(controllerInputTwo.text.isNotEmpty){
          return true;
        }else{
          return false;
        }
      }else{
        return true;
      }
    }else{
      return false;
    }
  }

  Future<void> buttonAction() async {
    userValueNew=controllerInputOne.text.toString();
    if(buttonText=="Save"){
      if(widget.title=="Password"){
        await setNewPassword();
      }else{
        await updateUserData(widget.title,userValueNew);
      }
      Navigator.pop(context);
    }
    else if(buttonText=="Send Verification Link"){
      if(await sendEmailLink(userValueNew)){
      }else{
      }
    }
    else if(buttonText=="Verify OTP"){
      //otp verification code
      await updateUserData(widget.title,userValueNew);
      Navigator.pop(context);
    }
    else if(buttonText=="Send OTP"){
      isSecondInputVisible=true;
      isReadOnly=true;
      secondInputLabel="OTP";
      buttonText="Verify OTP";
      autoFocus=false;
    }
    else if(buttonText=="Verify"){
                                                                                //-----reAuthenticate
      if(await reAuthenticateUser(userValueNew)){
        if(widget.title=="Email"){
          title="New Email";
          buttonText="Send Verification Link";
          isPassword=false;
          controllerInputOne.clear();
        }else{
          currentPassword=userValueNew;
          isSecondInputVisible=true;
          isPassword=true;
          title="New Password";
          secondInputLabel="Confirm $title";
          secondInputHint="* * * * * * *";
          buttonText="Save";
          controllerInputOne.clear();
        }
      }
    }
  }



  late String currentPassword;
  Future<void> setNewPassword() async {
    String password=controllerInputOne.text.toString();
    String passwordConfirm=controllerInputTwo.text.toString();
    if(password.length>6){
      if(password==passwordConfirm){
        if(password==currentPassword){
          print("Enter new password not old one");
        }
        else{
          await firebaseCurrentUser.updatePassword(password);
        }
      }else{
        print("password and password confirm not matched");
      }
    }else{
      print("password length must be 7 char");
    }
  }

}