import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/Add%20Package/Packages.dart';
import 'package:glocal_bizz/View/DetailPage.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'EditPost.dart';

class MyPostPage extends StatefulWidget {
  MyPostPage({Key key}) : super(key: key);

  @override
  _MyPostPageState createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  SharedPreferences prefs;

  bool _refreshing = false;
  String adstatus;
  String adstatusText;
  static const _pageSize = 10;
  final PagingController<int, AdsList> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    // myPost_list();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      prefs = await SharedPreferences.getInstance();
      Map data = {
        'customer_id': prefs.getString("user_id"),
        'page': (((pageKey + 10) / (_pageSize)).toString()),
        'limit': limit,
      };
      print(data);
      var result;
      var response =
          await http.post(Uri.parse(api_url + "/user_ads"), body: data);
      result = json.decode(response.body);
      print(result);

      List<AdsList> list = AdsListResponse(jsonEncode(result));

      final newItems = list;
      print(newItems.length);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        print(newItems.length);
        _pagingController.appendPage(newItems, nextPageKey);
      }
      print(_pagingController);
    } catch (error) {
      _pagingController.error = error;
    }
  }

  static List<AdsList> AdsListResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<AdsList>((json) => AdsList.fromJson(json)).toList();
  }

  int page = 1;

  // void myPost_list() async {
  //   prefs = await SharedPreferences.getInstance();
  //   Map data = {
  //     'customer_id': prefs.getString("user_id"),
  //     'page': page.toString(),
  //     'limit': limit,
  //   };
  //   print(data);
  //   var jsonResponse;
  //   var response =
  //       await http.post(Uri.parse(api_url + "/user_ads"), body: data);

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     print(json.decode(response.body));

  //     if (page == 1) {
  //       get_myPostList(json.decode(response.body)).then((value) {
  //         setState(() {
  //           myPostList = value;
  //         });
  //       });
  //     } else {
  //       get_myPostList(json.decode(response.body)).then((value) {
  //         setState(() {
  //           myPostList.addAll(value);
  //         });
  //       });
  //       print("____nandhu--------");
  //     }
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // List<AdsList> myPostList = List<AdsList>();

  // Future<List<AdsList>> get_myPostList(myPostsJson) async {
  //   var myPostList = List<AdsList>();
  //   for (var myPostJson in myPostsJson) {
  //     myPostList.add(AdsList.fromJson(myPostJson));
  //   }
  //   return myPostList;
  // }

  delete_post(adID) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      'ads_id': adID,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + '/destroy_ads'), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Post deleted.'),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void ads_sold(adsID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'customer_id': prefs.getString("user_id"),
      'ads_id': adsID,
      'ads_status': "2",
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/ads_update_status"), body: data);

    if (response.statusCode == 200) {
      var result = (json.decode(response.body));
      setState(() {
        page = 1;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Ad marked as sold..'),
        ),
      );
      // myPost_list();
      _pagingController.refresh();
      print(result);
    } else {
      print("sold error");
    }
  }

  void ads_deactivate(adsID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'customer_id': prefs.getString("user_id"),
      'ads_id': adsID,
      'ads_status': "3",
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/ads_update_status"), body: data);

    if (response.statusCode == 200) {
      var result = (json.decode(response.body));
      setState(() {
        page = 1;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Your Ad De-activated..'),
        ),
      );
      // myPost_list();
      _pagingController.refresh();
      print(result);
    } else {
      print("deactivate error");
    }
  }

  void ads_activate(adsID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'customer_id': prefs.getString("user_id"),
      'ads_id': adsID,
      'ads_status': "1",
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/ads_update_status"), body: data);

    if (response.statusCode == 200) {
      var result = (json.decode(response.body));
      setState(() {
        page = 1;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Your Ad activated..'),
        ),
      );
      // myPost_list();
      _pagingController.refresh();
      print(result);
    } else {
      print("deactivate error");
    }
  }

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      page = 1;
    });
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: const Text('Refresh Completed...'),
      ),
    );
    // myPost_list();
    _pagingController.refresh();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted)
      setState(() {
        page++;
        // myPost_list();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "My Posts",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: () async {
            Future.sync(
              () => _pagingController.refresh(),
            );
          },
          child: PagedListView<int, AdsList>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<AdsList>(
                  itemBuilder: (context, item, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: myPostlist(item, index),
                );
              })),
        ),
      ),
    );
  }

  Widget myPostlist(AdsList myPostList, int index) {
    final adsdate = myPostList.ads_date;
    final split = adsdate.split(' ');
    final Map<int, String> values = {
      for (int i = 0; i < split.length; i++) i: split[i]
    };
    switch (myPostList.ads_status) {
      case 0:
        adstatus = 'Pending';
        adstatusText =
            'This ad is not posted now, currently pending for review';
        break;
      case 1:
        adstatus = 'Active';
        adstatusText = 'This ad is currently live';
        break;
      case 2:
        adstatus = 'Sold';
        adstatusText = 'This ad is currently solded';
        break;
      case 3:
        adstatus = 'De-activated';
        adstatusText = 'This ad is currently De-activated';
        break;
      case 4:
        adstatus = 'Expired';
        adstatusText = 'This ad was Expired';
        break;
      case 5:
        adstatus = 'Deleted';
        adstatusText = 'This ad is already delete.';
        break;
      case 6:
        adstatus = 'Blocked';
        adstatusText = 'This ad is currently blocked';
        break;
      default:
    }
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 7),
              color: Colors.cyan[50],
              child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'FROM: ',
                      style: TextStyle(
                          fontSize: 12,
                          color: myPostList.ads_status == 0 ||
                                  myPostList.ads_status == 1
                              ? color2
                              : Colors.grey[400]),
                      children: <TextSpan>[
                        TextSpan(
                            text: values[0],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' - TO: '),
                        TextSpan(
                            text: values[1],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Spacer(),
                  myPostList.ads_status == 1
                      ? myPopMenu(myPostList, index)
                      : myPostList.ads_status == 3
                          ? myPopMenu_1(myPostList, index)
                          : myPopMenu_2(myPostList, index),
                ],
              ),
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute<bool>(
                          fullscreenDialog: true,
                          builder: (BuildContext context) =>
                              AdsDetailPage(ads_id: myPostList.id.toString()),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Container(
                              height: 120,
                              width: 130,
                              // child: Image.asset(
                              //   "assets/car_sale.jpg",
                              //   fit: BoxFit.fill,
                              // ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(myPostList.ads_image),
                                    // fit: BoxFit.fill,
                                  )),
                            )),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    myPostList.ads_name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        myPostList.ads_price != null
                                            ? myPostList.ads_price
                                            : "",
                                        style: TextStyle(
                                            color: color2,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.visibility,
                                        size: 18,
                                        color: Colors.green[200],
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Views: " +
                                            myPostList.total_views.toString(),
                                        style: TextStyle(fontSize: 10),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  new Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: color2,
                                        size: 22,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        // width: 130,
                                        // color: primaryColor,
                                        child: Container(
                                          // color: primaryColor,
                                          child: Text(myPostList.city_name,
                                              // textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                      // Spacer(),
                                      Expanded(
                                        flex: 2,
                                        // width: 80,
                                        // color: primaryColor,
                                        child: Center(
                                          child: Text(
                                            myPostList.posted_at,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 8.5),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                myPostList.ads_status == 0 || myPostList.ads_status == 1
                    ? SizedBox()
                    : Container(
                        height: 120,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5).withOpacity(0.7)),
                      )
              ],
            ),
            Divider(),
            myPostList.ads_status_text != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      myPostList.ads_status_text,
                      style: TextStyle(
                          color: color2,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.cyan[100],
                        borderRadius: BorderRadius.circular(13)),
                  )
                : SizedBox(),
            adstatusText != null
                ? Text(
                    "  " + adstatusText,
                    style: TextStyle(
                        color: color2,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  )
                : SizedBox(),
            SizedBox(
              height: 5,
            ),
            myPostList.feature_status == 1
                ? SizedBox()
                : myPostList.ads_status == 0 || myPostList.ads_status == 1
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () {
                              // print(myPostList[index].category_id);
                              Navigator.of(context, rootNavigator: true)
                                  .push(CupertinoPageRoute(
                                      builder: (_) => SelectPackages(
                                            title: "Feature Package",
                                            pkg_type: "1",
                                            category_id: myPostList.category_id
                                                .toString(),
                                            ads_id: myPostList.id.toString(),
                                          )));
                            },
                            child: Text(
                              "Sell Faster Now",
                              style: TextStyle(
                                  color: color2,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                            style: OutlinedButton.styleFrom(
                                primary: color2,
                                side: BorderSide(color: color2, width: 1.8)),
                          ),
                        ),
                      )
                    : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget myPopMenu(AdsList myPostList, int index) {
    return PopupMenuButton(
        icon: Icon(Icons.more_horiz),
        onSelected: (value) async {
          print("object");
          switch (value) {
            case 1:
              Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          EditPost(ads_id: myPostList.id.toString())));
              break;
            case 2:
              // if (myPostList[index].ads_status == 1) {
              //   ads_deactivate(myPostList[index].id.toString());
              // } else if (myPostList[index].ads_status == 2) {
              //   _scaffoldKey.currentState.showSnackBar(
              //     SnackBar(
              //       content: const Text(
              //           'This Ad is sold, so again is not activated'),
              //     ),
              //   );
              // } else if (myPostList[index].ads_status == 4) {
              //   _scaffoldKey.currentState.showSnackBar(
              //     SnackBar(
              //       content: const Text('This Ad is expired, Is not activated'),
              //     ),
              //   );
              // } else if (myPostList[index].ads_status == 0) {
              //   _scaffoldKey.currentState.showSnackBar(
              //     SnackBar(
              //       content:
              //           const Text('This Ad is Pending now, Is not activated'),
              //     ),
              //   );
              // } else {
              //   ads_activate(myPostList[index].id.toString());
              // }
              myPostList.ads_status == 1
                  ? ads_deactivate(myPostList.id.toString())
                  : ads_activate(myPostList.id.toString());
              break;
            case 3:
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text("Confirm to Delete post"),
                      //title: Text(),
                      actions: <Widget>[
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "No",
                            style: TextStyle(color: color2),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            print("delete");
                            delete_post(myPostList.id.toString());
                            setState(() {
                              _pagingController.refresh();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: color2),
                          ),
                        ),
                      ],
                    );
                  });
              break;
            case 4:
              myPostList.ads_status == 2
                  ? _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: const Text('This Ad already sold'),
                      ),
                    )
                  : ads_sold(myPostList.id.toString());
              break;
          }
        },
        itemBuilder: (context) => [
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(Icons.edit_outlined, color: color2),
                      ),
                      Text(
                        'EDIT',
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(
                            myPostList.ads_status == 1
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: color2),
                      ),
                      Text(
                        myPostList.ads_status == 1 ? 'DEACTIVATE' : "ACTIVATE",
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(Icons.delete_outlined, color: color2),
                      ),
                      Text(
                        'DELETE',
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(Icons.done_outlined, color: color2),
                      ),
                      Text(
                        myPostList.ads_status == 2
                            ? 'ALREADY SOLD'
                            : 'MARK AS SOLD',
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
            ]);
  }

  Widget myPopMenu_1(AdsList myPostList, int index) {
    return PopupMenuButton(
        icon: Icon(Icons.more_horiz),
        onSelected: (value) async {
          print("object");
          switch (value) {
            case 1:
              Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          EditPost(ads_id: myPostList.id.toString())));
              break;
            case 2:
              myPostList.ads_status == 1
                  ? ads_deactivate(myPostList.id.toString())
                  : ads_activate(myPostList.id.toString());
              break;
            case 3:
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text("Confirm to Delete post"),
                      //title: Text(),
                      actions: <Widget>[
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "No",
                            style: TextStyle(color: color2),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            print("delete");
                            delete_post(myPostList.id.toString());
                            setState(() {
                              _pagingController.refresh();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: color2),
                          ),
                        ),
                      ],
                    );
                  });
              break;
          }
        },
        itemBuilder: (context) => [
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(Icons.edit_outlined, color: color2),
                      ),
                      Text(
                        'EDIT',
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(
                            myPostList.ads_status == 1
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: color2),
                      ),
                      Text(
                        myPostList.ads_status == 1 ? 'DEACTIVATE' : "ACTIVATE",
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(Icons.delete_outlined, color: color2),
                      ),
                      Text(
                        'DELETE',
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
            ]);
  }

  Widget myPopMenu_2(AdsList myPostList, int index) {
    return PopupMenuButton(
        icon: Icon(Icons.more_horiz),
        onSelected: (value) async {
          print("object");
          switch (value) {
            case 1:
              Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          EditPost(ads_id: myPostList.id.toString())));
              break;

            case 2:
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text("Confirm to Delete post"),
                      //title: Text(),
                      actions: <Widget>[
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "No",
                            style: TextStyle(color: color2),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            print("delete");
                            delete_post(myPostList.id.toString());
                            setState(() {
                              _pagingController.refresh();
                              //   myPostList.removeAt(index);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: color2),
                          ),
                        ),
                      ],
                    );
                  });
              break;
          }
        },
        itemBuilder: (context) => [
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(Icons.edit_outlined, color: color2),
                      ),
                      Text(
                        'EDIT',
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 5, 2),
                        child: Icon(Icons.delete_outlined, color: color2),
                      ),
                      Text(
                        'DELETE',
                        style: TextStyle(fontSize: 14, color: color2),
                      )
                    ],
                  )),
            ]);
  }
}
