import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/services.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/chat_list_model.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../DetailPage.dart';

class ChatScreen extends StatefulWidget {
  final String adsId;
  // final String receiverID;
  final String user_name;
  final String sendID;
  final String receiveID;

  ChatScreen({Key key, this.adsId, this.user_name, this.sendID, this.receiveID})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController message = new TextEditingController();
  final GlobalKey<RefreshIndicatorState> refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  ScrollController controller;
  Timer timer;
  int adstatus;
  Future<ChatAdsDetail> addetail;

  // List<String> allmessage = [];
  var messageList = [];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    controller = new ScrollController();
    chat_history();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => chat_Status());
    // timer = Timer.periodic(Duration(seconds: 3),
    //     (Timer t) => controller.jumpTo(controller.position.maxScrollExtent));
    addetail = ads_detail();
    // controller.addListener(_scrollListener);
    super.initState();
    _showMessage();
    // controller.animateTo(controller.position.maxScrollExtent, curve: null, duration: null);
    Timer(Duration(milliseconds: 2500),
        () => controller.jumpTo(controller.position.maxScrollExtent));
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  bool _isLoading = true;

  int sender;

  Future<Null> _onRefresh() {
    return Future.delayed(Duration(seconds: 2), () {
      chat_history();
    });
  }

  _scrollListener() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<ChatAdsDetail> ads_detail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'ads_id': widget.adsId,
      'customer_id': sharedPreferences.getString("user_id"),
    };
    // print(data);
    print('Sender and reviver id');
    print(widget.sendID + widget.receiveID);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/chat_history"), body: data);
    jsonResponse = json.decode(response.body)['ads'];
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body)['ads'];
      setState(() {
        adstatus = json.decode(response.body)['ads']['ads_status'];
      });
      return ChatAdsDetail.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load post');
    }
  }

  void chat_history() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'ads_id': widget.adsId,
      'customer_id': widget.sendID,
      'receiver_id': widget.receiveID,
    };
    print("-00000000----");
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/chat_history"), body: data);

    if (response.statusCode == 200) {
      print(json.decode(response.body));
      setState(() {
        _isLoading = false;
        var senderID = sharedPreferences.getString("user_id");
        sender = int.parse(senderID);
        messageList = json.decode(response.body)['chats'];
      });
      // chatHistory(json.decode(response.body)['chats']).then((value) {
      //   setState(() {
      //     chatList = value;
      //   });
      // });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void chat_Status() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'ads_id': widget.adsId,
      'customer_id': widget.sendID,
      'receiver_id': widget.receiveID,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/chat_status"), body: data);

    if (response.statusCode == 200) {
      print(json.decode(response.body));
      setState(() {
        _isLoading = false;
        // var senderID = sharedPreferences.getString("user_id");
        // sender = int.parse(senderID);
        messageList.addAll(json.decode(response.body)['chats']);
        controller.jumpTo(controller.position.maxScrollExtent);
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // List<ChatHistory> chatList = List<ChatHistory>();

  // Future<List<ChatHistory>> chatHistory(chatsJson) async {
  //   var allchats = List<ChatHistory>();
  //   for (var chatJson in chatsJson) {
  //     allchats.add(ChatHistory.fromJson(chatJson));
  //   }
  //   return allchats;
  // }

  void send_message(msg) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'ads_id': widget.adsId,
      'sender_id': widget.sendID,
      'receiver_id': widget.receiveID,
      'message': msg,
      // 'customer_id': sharedPreferences.getString("user_id"),
    };

    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/send_message"), body: data);
    if (response.statusCode == 200) {
      setState(() {
        Timer(Duration(milliseconds: 100),
            () => controller.jumpTo(controller.position.maxScrollExtent));
      });
      // print("mesg sended");
      // jsonResponse = json.decode(response.body);

    } else {
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  Future<void> _alerDialog(message) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(message),
            //title: Text(),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  Navigator.pop(context, "ok");
                },
                child: const Text("OK"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double px = 1 / pixelRatio;

    BubbleStyle styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
      showNip: true,
    );
    BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, left: 50.0),
      alignment: Alignment.topRight,
      showNip: true,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(widget.user_name != null ? widget.user_name : "user"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        // actions: [
        //   InkWell(
        //     child: Icon(Icons.done_all),
        //     onTap: () {
        //       print("------NK-----");
        //       print(messageList.length);
        //     },
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Column(children: [
            FutureBuilder<ChatAdsDetail>(
                future: addetail,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.all(7),
                      child: InkWell(
                        onTap: () {
                          snapshot.data.ads_status == 1
                              ? Navigator.of(context, rootNavigator: true).push(
                                  CupertinoPageRoute(
                                      builder: (context) => AdsDetailPage(
                                          ads_id: snapshot.data.id.toString())))
                              : _alerDialog("This ad has been De-activated");
                        },
                        child: Card(
                          elevation: 3.0,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Container(
                                  height: 60,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(snapshot.data.ads_image),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data.ads_name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "₹ " + snapshot.data.ads_price,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    snapshot.data.ads_status == 1
                                        ? Text(
                                            "Active",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.w500),
                                          )
                                        : Text(
                                            "Ad Inactive, This chat will be deleted soon",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red[700],
                                                fontWeight: FontWeight.w500),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: primaryColor,
                        valueColor: new AlwaysStoppedAnimation<Color>(white),
                      ),
                    );
                  }
                }),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: RefreshIndicator(
                  key: refreshKey,
                  onRefresh: _onRefresh,
                  child:
                      // new ListView.builder(
                      //     controller: controller,
                      //     shrinkWrap: true,
                      //     reverse: false,
                      //     scrollDirection: Axis.vertical,
                      //     itemCount: chatList.length,
                      //     itemBuilder: (context, index) {
                      //       print("------nk chat-----");
                      //       print(chatList[index].message);
                      // allmessage.add(chatList[index].message);
                      //       return
                      ListView(
                          controller: controller,
                          shrinkWrap: true,
                          reverse: false,
                          scrollDirection: Axis.vertical,
                          children: [
                        for (var item in messageList)
                          sender == item['sender_id']
                              ? Bubble(
                                  margin: BubbleEdges.only(right: 8, left: 50),
                                  style: styleMe,
                                  child: Text(item['message']),
                                  // RichText(
                                  //   text: TextSpan(
                                  //     style: TextStyle(
                                  //         color: color2, fontSize: 14),
                                  //     children: [
                                  //       TextSpan(
                                  //         text: item['message'] + "  ",
                                  //       ),
                                  //       WidgetSpan(
                                  //         child: Icon(Icons.done_all, size: 15),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // )
                                  // Text(item['message'] + Icon(Icons.done)),
                                )
                              : Bubble(
                                  margin: BubbleEdges.only(left: 8, right: 50),
                                  style: styleSomebody,
                                  child: Text(item['message']),
                                ),
                      ]),
                  // }),
                ),
              ),
            ),
          ]),
          adstatus == 1
              ? Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(
                        left: 15, right: 15, bottom: 10, top: 5),
                    height: 60,
                    child: TextField(
                      cursorHeight: 18,
                      controller: message,
                      obscureText: false,
                      onTap: () {
                        Timer(
                            Duration(seconds: 1),
                            () => controller
                                .jumpTo(controller.position.maxScrollExtent));
                      },
                      onSubmitted: (newValue) {
                        Timer(
                            Duration(seconds: 1),
                            () => controller
                                .jumpTo(controller.position.maxScrollExtent));
                      },
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: white,
                        filled: true,
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        prefixIcon: Icon(
                          Icons.keyboard,
                          color: primaryColor,
                        ),
                        suffixIcon: IconButton(
                            splashRadius: 32,
                            icon: Icon(
                              Icons.send,
                              color: primaryColor,
                            ),
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              message.text.isNotEmpty
                                  ? send_message(message.text)
                                  : () {};
                              setState(() {
                                Map data = {
                                  'ads_id': widget.adsId.toString(),
                                  'sender_id': sender,
                                  'receiver_id': int.parse(widget.receiveID),
                                  'message': message.text,
                                };
                                messageList.add(data);
                                print(data);
                                // Timer(
                                //     Duration(seconds: 1),
                                //     () => controller.jumpTo(
                                //         controller.position.maxScrollExtent));
                              });
                              message.clear();
                            }),
                        hintText: ("Type a message"),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 0.5),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 0.5),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 0.5),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 0.5),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    color: color2,
                    child: Center(
                        child: Text(
                      "This Ad has been disabled by the seller",
                      style: TextStyle(color: white),
                    )),
                  ),
                ),
        ],
      ),
    );
  }

  void _showMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showModalBottomSheet(
          context: context,
          builder: (builder) {
            return SingleChildScrollView(
              child: new Container(
                height: 420.0,
                color: Colors
                    .transparent, //could change this to Color(0xFF737373),
                //so you don't have to change MaterialApp canvasColor
                child: new Container(
                    padding: EdgeInsets.all(15),
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(25.0),
                            topRight: const Radius.circular(25.0))),
                    child: Column(
                      children: [
                        new Text(
                          "Tips for a safe deal",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins"),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        ListTile(
                          leading: Icon(Icons.flag_outlined),
                          title: Text(
                            "Be safe take necessary precautions while meeting with buyers and sellers",
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 14),
                          ),
                        ),
                        divider(),
                        ListTile(
                          leading: Icon(Icons.credit_card_outlined),
                          title: Text(
                            "Do not enter UPI PIN while receiving money",
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 14),
                          ),
                        ),
                        divider(),
                        ListTile(
                          leading: Icon(Icons.money),
                          title: Text(
                            "Never give money or product in advance",
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 14),
                          ),
                        ),
                        divider(),
                        ListTile(
                          leading: Icon(Icons.flag_outlined),
                          title: Text(
                            "Report suspicious users to Glocal Bizz",
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 14),
                          ),
                        ),
                        divider(),
                        Spacer(),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: ElevatedBtn1(() {
                              Navigator.pop(context);
                              print("model closed");
                            }, "Continue to chat")),
                      ],
                    )),
              ),
            );
          });
    });
  }
}
