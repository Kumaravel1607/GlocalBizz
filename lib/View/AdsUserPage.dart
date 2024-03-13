import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/DetailPage.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class AdsUserProfilePage extends StatefulWidget {
  final String aduserID;
  final String aduserImage;
  final String aduserName;
  final String aduserJoin;
  AdsUserProfilePage(
      {Key key,
      this.aduserID,
      this.aduserImage,
      this.aduserName,
      this.aduserJoin})
      : super(key: key);

  @override
  _AdsUserProfilePageState createState() => _AdsUserProfilePageState();
}

class _AdsUserProfilePageState extends State<AdsUserProfilePage> {
  String image;
  String name;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    myADs_list();
  }

  bool _isLoading = true;
  int page = 1;

  void myADs_list() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': widget.aduserID,
      'page': page.toString(),
      'limit': limit,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/user_ads"), body: data);

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });

      if (page == 1) {
        get_adsList(json.decode(response.body)).then((value) {
          setState(() {
            ads = value;
          });
        });
      } else {
        get_adsList(json.decode(response.body)).then((value) {
          setState(() {
            ads.addAll(value);
          });
        });
      }

      print('---------------NK-----------');
      print(json.decode(response.body));
    } else {
      _isLoading = false;
    }
  }

  List<AdsList> ads = List<AdsList>();

  Future<List<AdsList>> get_adsList(adsJson) async {
    var ads = List<AdsList>();
    for (var adJson in adsJson) {
      ads.add(AdsList.fromJson(adJson));
    }
    return ads;
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
    myADs_list();
    _refreshController.refreshToIdle();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted)
      setState(() {
        page++;
        myADs_list();
      });
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: FloatingActionButton(
                    elevation: 10,
                    mini: true,
                    foregroundColor: black,
                    backgroundColor: white,
                    child: Icon(
                      Icons.arrow_back,
                      color: black,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                // SizedBox(height: 5,),
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFFf8f8f8),
                  child: CircleAvatar(
                    backgroundColor: white,
                    radius: 35,
                    backgroundImage: NetworkImage(widget.aduserImage),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  widget.aduserName,
                  style: TextStyle(
                      color: black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Member Since " + widget.aduserJoin,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(
                  height: 5,
                ),
                divider(),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    "Published ads",
                    style: TextStyle(
                        color: black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Expanded(
                  child: ads.length != 0
                      ? SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: true,
                          header: MaterialClassicHeader(),
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          child: new ListView.builder(
                              shrinkWrap: false,
                              scrollDirection: Axis.vertical,
                              itemCount: ads.length,
                              itemBuilder: (context, index) {
                                return adslist(ads, index);
                              }),
                        )
                      : _isLoading == true
                          ? Container(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                backgroundColor: primaryColor,
                                valueColor:
                                    new AlwaysStoppedAnimation<Color>(white),
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: Text(
                                "No posts found.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                ),
                // ),
              ]),
          //  ),
        ),
      ),
    );
  }

  Widget adslist(List<AdsList> ads, int index) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute<bool>(
              fullscreenDialog: true,
              builder: (BuildContext context) =>
                  AdsDetailPage(ads_id: ads[index].id.toString()),
            ),
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      height: 120,
                      width: 130,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(ads[index].ads_image),
                            // fit: BoxFit.fill,
                          )),
                    )),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            ads[index].ads_price,
                            style: TextStyle(
                                color: color2,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ads[index].ads_name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          new Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 22,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(ads[index].city_name,
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
