import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linkup/screen_chatting.dart';
import 'package:flutter/material.dart';
import 'package:linkup/screen_user_profile.dart';
import 'package:linkup/screen_user_profile_.dart';
import 'package:linkup/service_firebase.dart';
import 'package:linkup/services/user_status.dart';

late String loggedUserId;

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen(this.userId, {super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  ImageProvider? loggedUserImage;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  List<QueryDocumentSnapshot> users = [];
  List<QueryDocumentSnapshot> filteredList = [];

  @override
  void initState() {
    super.initState();
    loggedUserId = widget.userId;
//---------------------status set online
    UserStatus().startMonitoring();
  }

  @override
  void dispose() {
    super.dispose();
    // Optionally set user offline when leaving screen
    UserStatus().setOffline();
    print("home screen------------------setting offline------");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: !isSearching?Image.asset("assets/images/app_icon.png",scale: 10,):
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              isSearching = false;
              searchController.clear();
              filteredList = users;
            });
          },
        ),

        title: !isSearching ? const Text("LinkUP")
          :TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
            ),
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  filteredList = users;
                } else {
                  filteredList = users.where((doc) {
                    String name =
                    doc['Username'].toString().toLowerCase();
                    return name.contains(value.toLowerCase());
                  }).toList();
                }
              });
            },
          ) ,
        actions: [
          Padding(
              padding:EdgeInsetsGeometry.only(right: 15),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(isSearching ? Icons.close : Icons.search),
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;

                        if (!isSearching) {
                          searchController.clear();
                          filteredList = users;
                        }
                      });
                    },
                  ),
                  if (!isSearching)
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: loggedUserImage??AssetImage("assets/images/default_user.jpg"),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => UserProfile(loggedUserId, true)));
                        },
                      ),
                    )
                ],
              ),
            )
        ],
      ),
//---------------------main body
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: getHomeUsers(),
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder getHomeUsers() {
    return StreamBuilder(
      stream: getHomeScreenUsers(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }//loading

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }//error

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found"));
        }//no data

        // if (users.isEmpty) {
        //   users = snapshot.data!.docs;
        //   filteredList = users;
        // }

        users = snapshot.data!.docs;
        if (filteredList.isEmpty) {
          filteredList = users;
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {

            var user = users[index];
            var data = user.data() as Map<String, dynamic>;

            String userId = user.id;
            String name = data['Username'] ?? "linkup2026";
            String? profileImage = data['ProfileImage'];
            bool? isOnline = data['isOnline'] ?? false;
            String status=isOnline!?"Online":"Offline";
            ImageProvider? imageProviderH;

            if (profileImage != null && profileImage.isNotEmpty) {
              imageProviderH = NetworkImage(profileImage);
            }

            if (loggedUserId == userId && loggedUserImage == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  loggedUserImage = imageProviderH;
                });
              });
            }
            // if(loggedUserId == userId){
            //   return SizedBox();
            // }

            return ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: imageProviderH??const AssetImage("assets/images/default_user.jpg"),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) =>UserProfileView(name, imageProviderH, false),),);
                  },
                ),
              ),
              title: Text(name),
              subtitle: Text(status),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("date"),
                  Text("time"),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChattingScreen(userId, name, imageProviderH,status),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}