import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/model/Notification_model.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    notification_list();
  }

  void notification_list() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': sharedPreferences.getString("user_id"),
    };
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/notification"), body: data);

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
      get_notificationList(json.decode(response.body)).then((value) {
        setState(() {
          notificationList = value;
        });
      });
      close_notification();
      // print('---------------NK-----------');
      print(json.decode(response.body));
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<NotificationList> notificationList = List<NotificationList>();

  Future<List<NotificationList>> get_notificationList(notificationsJson) async {
    var notifications = List<NotificationList>();
    for (var notificationJson in notificationsJson) {
      notifications.add(NotificationList.fromJson(notificationJson));
    }
    return notifications;
  }

  Future<void> close_notification() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': sharedPreferences.getString("user_id"),
    };
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/notification_close"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
    } else {
      print("error");
      print(json.decode(response.body));
    }
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    _refreshController.refreshToIdle();
    notification_list();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // allAPI();
    // if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Notifications",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.close, color: white),
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: notificationList.length != 0
            ? new ListView.builder(
                shrinkWrap: false,
                scrollDirection: Axis.vertical,
                itemCount: notificationList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Color(0xFFf8f8f8),
                          child: ListTile(
                            focusColor: Color(0xFFf8f8f8),
                            title: Text(
                              notificationList[index].notification_title,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: black,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              notificationList[index].notification_description,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: black,
                                  fontWeight: FontWeight.w500),
                            ),
                            leading: Image.asset(
                              "assets/user.png",
                              height: 30,
                              width: 30,
                            ),
                            onTap: () {},
                          ),
                        ),
                        divider3(),
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
                      "No notification found...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
      ),
    );
  }
}
