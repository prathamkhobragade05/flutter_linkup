import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:linkup/screen_home.dart';
import 'package:flutter/material.dart';
import 'package:linkup/screen_user_profile.dart';
import 'package:linkup/service_firebase.dart';
import 'database/app_database.dart';
import 'main.dart';
import 'screen_chatting_.dart';

late String receiverId,receiverName;
late ImageProvider imageProviderC;
dynamic chattingId;
bool isSender=false;

class ChattingScreen extends StatefulWidget {
  final ImageProvider imageProviderC;
  final String receiverId;
  final String receiverName;

  const ChattingScreen(this.receiverId,this.receiverName, this.imageProviderC, {super.key});
  @override
  State<ChattingScreen> createState() => ChattingScreenState();
}

class ChattingScreenState extends State<ChattingScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool readOnly = true;


  @override
  void initState() {
    super.initState();
    imageProviderC=widget.imageProviderC;
    receiverId=widget.receiverId;
    receiverName=widget.receiverName;

    chattingId = generateChattingId(loggedUserId.toString(), receiverId.toString());
                                                                                //----focus text field and scroll last message
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   scrollToLast();
    //   _focusNode.requestFocus();
    // });
    // scrollToLast();
                                                                                //---------screen observer
    WidgetsBinding.instance.addObserver(this);
  }
                                                                                //-------Detects keyboard open / close
  @override
  void didChangeMetrics() {
    Future.delayed(const Duration(milliseconds: 100), () {
      // scrollToLast();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: getReceiver(),
      body:SafeArea(
        child:Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
//-------------chatting messages
              Expanded(child: getMessage()),
//-------------message input
              Padding(
                padding: EdgeInsetsGeometry.fromSTEB(0, 5, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
//-------------TextInputField
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        focusNode: _focusNode,
                        showCursor: true,
                        readOnly: readOnly,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Type Message",
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding:EdgeInsets.symmetric(
                            horizontal: 10,  // left-right padding
                            vertical: 5,    // top-bottom padding
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onTap: () {
                          if (readOnly) {
                            setState(() {
                              readOnly = false;
                            });
                            // _focusNode.requestFocus();
                          }
                        },
                      ) ,
                    ),
//-------------SendButton
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async
                      {
                        final messageText = messageController.text.trim();
                        var timestamp=DateTime.now();
                        if(messageText.isNotEmpty){
                          var message= {
                            "SenderId": loggedUserId,
                            "ReceiverId":receiverId,
                            "Message":messageText,
                            "TimeStamp": timestamp
                          };

                          messageController.clear();
                          await insertMessagesToFirebase(chattingId,message,timestamp);
                          // scrollToLast();
                          // _focusNode.requestFocus();

                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white, // icon color
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }
                                                                                //-------------Receiver / Chatting Header
  PreferredSizeWidget? getReceiver() {
    return AppBar(
      toolbarHeight: 70,
      title: Row(
        children: [

          CircleAvatar(
            radius: 23,
            backgroundImage: imageProviderC ,
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfile(receiverId,false)));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiverName,
                  style: const TextStyle(fontSize: 18),
                ),
                const Text(
                  "Status",
                  style: TextStyle(fontSize: 14),
                ),

              ],
            ),
          )
        ],
      ),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: "profile", child: Text("Profile")),
          ],
        )
      ],
    );
  }

                                                                                //-------------------insertMessageIntoDB
  bool insertMessage(String message){
    try{
      db.insertMessage(MessagesCompanion(
          senderId: Value(loggedUserId.toString()),
          receiverId: Value(receiverId.toString()),
          message: Value(message),
          createdAt: Value(DateTime.now())
      ));
      return true;
    }catch(e){
      return false;
    }
  }

                                                                                //---------- get chatting messages
  StreamBuilder<QuerySnapshot<Object?>> getMessage(){
    return StreamBuilder(
        stream: getChatIdMessages(chattingId),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }//-----Error

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Start Chats"));
          }//-----No data

          var firebaseData = snapshot.data!.docs;                               //----------firebase chatId message data

          return ListView.builder(
            reverse: true,
            controller: _scrollController,
            itemCount: firebaseData.length,
            itemBuilder: (context, index) {
              dynamic messages=firebaseData[index];
              var message = messages.data() as Map<String, dynamic>;

              String senderId = message['SenderId'];
              String messageText= message['Message'];
              DateTime timestamp = message['TimeStamp'].toDate();

              if(senderId == loggedUserId.toString()){
                isSender=true;
              }else{
                isSender=false;
              }

              return Column(
                crossAxisAlignment: isSender
                    ?CrossAxisAlignment.end
                    :CrossAxisAlignment.start,
                children: [
                  Container(
                      constraints: const BoxConstraints(
                        maxWidth: 250,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.yellow,
                          border: Border.all(
                              color: Colors.yellow,
                              width: 2
                          ),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: isSender
                            ? const EdgeInsetsDirectional.fromSTEB(7, 2, 15, 0)
                            : const EdgeInsetsDirectional.fromSTEB(15, 2, 7, 0),
                        child: messageData(messageText,timestamp),
                      )
                  ),
                  SizedBox(height: 15,)
                ],
              );
            }
          );
        }
    );
  }

                                                                                //-------------------getChatMessagesFromDB
  StreamBuilder<List<Message>> getMessages(){
    return StreamBuilder<List<Message>>(
      stream: db.watchChatMessages(loggedUserId.toString(), receiverId.toString()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data!;

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            if(messages[index].senderId == loggedUserId.toString()){
              isSender=true;
            }else{
              isSender=false;
            }
            return Column(
              crossAxisAlignment: isSender
              ?CrossAxisAlignment.end
              :CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 250,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    border: Border.all(
                        color: Colors.yellow,
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(15)
                    ),
                  child: Padding(
                    padding: isSender
                        ? const EdgeInsetsDirectional.fromSTEB(7, 2, 15, 0)
                        : const EdgeInsetsDirectional.fromSTEB(15, 2, 7, 0),
                    // child: itemMessage(messages, index),
                  )
                ),
                SizedBox(height: 15,)
              ],
            );
          },
        );
      },
    );
  }

                                                                                //------------message item single view
  Column messageData(String messageText, timestamp){
    return  Column(
        crossAxisAlignment: isSender? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(messageText),
          Text(messageTime(timestamp),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ]
    );
  }
}
