import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_assist_chat_app/Classes/user_chat.dart';
import 'package:focus_assist_chat_app/pages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  //final UserChat currentUserChat;
  //HomeScreen({Key key, @required this.currentUserChat}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserChat currentUserChat = new UserChat(id: 'TP31Qc1W5lQqqnRl3nertdvXk2D2', photoUrl: 'https://lh3.googleusercontent.com/a-/AOh14Gg4xzCGGS-I0yp6wbLAxib1uUH8dHVNH_vxXs4M=s96-c', nickname: 'Focus Assist');
  bool isLoading = false;
  // bool isLoggedIn = false;
  int _limit = 20;
  int _limitIncrement = 20;
  SharedPreferences prefs;
  final ScrollController listScrollController = ScrollController();

  //_HomeScreenState({Key key, @required this.currentUserChat});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // isSignedIn();
    listScrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    if (await GoogleSignIn().isSignedIn()) await GoogleSignIn().disconnect();

    // prefs = await SharedPreferences.getInstance();
    //
    // isLoggedIn = await GoogleSignIn().isSignedIn();
    // if (isLoggedIn && prefs?.getString('id') != null) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: prefs!.getString('id') ?? "")),
    //   );
    // }

    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHAT APP',
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Positioned(child: isLoading
            ?CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),)
            :Container()),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').limit(_limit).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildItem(context, snapshot.data.docs[index]),
                    itemCount: snapshot.data.docs.length,
                    controller: listScrollController,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentUserChat.id) {
        return SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                    userChat.photoUrl,
                    fit: BoxFit.cover,
                    width: 50.0,
                    height: 50.0,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                            value: loadingProgress.expectedTotalBytes != null &&
                                loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: Colors.grey[200],
                      );
                    },
                  )
                      : Icon(
                    Icons.account_circle,
                    size: 50.0,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'Nickname: ${userChat.nickname}',
                            maxLines: 1,
                            style: TextStyle(color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        ),
                        // Container(
                        //   child: Text(
                        //     'About me: ${userChat.aboutMe}',
                        //     maxLines: 1,
                        //     style: TextStyle(color: Colors.black87),
                        //   ),
                        //   alignment: Alignment.centerLeft,
                        //   margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        // )
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20.0),
                  ),
                ),
              ],
            ),
            onPressed: () {
              print('$userChat');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chat(userChat: userChat, currentUserChat: currentUserChat,),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[200]),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
