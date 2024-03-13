import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/chat_model.dart';
import 'package:glocal_bizz/View/Chatting/NewChatScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListPage extends StatefulWidget {
  ChatListPage({Key key}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final GlobalKey<RefreshIndicatorState> refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    chat_list();
  }

  String uID;
  void chat_list() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': sharedPreferences.getString("user_id"),
    };
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/chat_list"), body: data);

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });

      uID = sharedPreferences.getString("user_id");
      get_chatList(json.decode(response.body)).then((value) {
        setState(() {
          chatList = value;
        });
      });
      // print('---------------NK-----------');
      print(json.decode(response.body));
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ChatList> chatList = List<ChatList>();

  Future<List<ChatList>> get_chatList(chatsJson) async {
    var chats = List<ChatList>();
    for (var chatJson in chatsJson) {
      chats.add(ChatList.fromJson(chatJson));
    }
    return chats;
  }

  Future<Null> _onRefresh() {
    return Future.delayed(Duration(seconds: 2), () {
      chat_list();
    });
  }

  FutureOr onGoBack(dynamic value) {
    chat_list();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Chat List",
          style: TextStyle(color: white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: _onRefresh,
        child: chatList.length != 0
            ? new ListView.builder(
                shrinkWrap: false,
                scrollDirection: Axis.vertical,
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            chatList[index].display_name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatList[index].ads_name,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              chatList[index].ads_status == 1
                                  ? Text(
                                      "Active",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500),
                                    )
                                  : Text(
                                      "Ad inactive, This chat will be deleted soon",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.w500),
                                    ),
                            ],
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(2),
                            height: 47,
                            width: 47,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: chatList[index].ads_image != null
                                        ? NetworkImage(
                                            chatList[index].ads_image)
                                        : AssetImage(
                                            'assets/images/user.png'))),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                chatList[index].display_time != null
                                    ? chatList[index].display_time
                                    : "",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              chatList[index].unread_count != 0
                                  ? FittedBox(
                                      child: Container(
                                        child: Center(
                                          child: Text(
                                              chatList[index]
                                                  .unread_count
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10)),
                                        ),
                                        padding: EdgeInsets.all(3),
                                        constraints: BoxConstraints(
                                            minHeight: 23, minWidth: 23),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                color:
                                                    Colors.black.withAlpha(50))
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color:
                                              primaryColor, // This would be color of the Badge
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          onTap: () {
                            Route route = MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      adsId: chatList[index].ads_id,
                                      // receiverID: chatList[index].receiver_id
                                      user_name: chatList[index].display_name,
                                      sendID: uID,
                                      receiveID:
                                          chatList[index].sender_id != uID
                                              ? chatList[index].sender_id
                                              : chatList[index].receiver_id,
                                    ));
                            Navigator.push(context, route).then(onGoBack);
                            // Navigator.of(context, rootNavigator: true).push(
                            //     MaterialPageRoute(
                            //         builder: (BuildContext context) =>
                            //            ));
                            // print("sendID"+ chatList[index].receiver_id,);
                            // print("receiveID"+ chatList[index].sender_id,);
                          },
                        ),
                        divider2(),
                      ],
                    ),
                  );
                })
            : _isLoading == true
                ? Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      backgroundColor: primaryColor,
                      valueColor: new AlwaysStoppedAnimation<Color>(white),
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    child: Text(
                      "No chat history found ):",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
      ),
    );
  }
}
