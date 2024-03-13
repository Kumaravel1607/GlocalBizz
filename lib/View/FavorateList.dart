import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Controller/fav_controller.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/DetailPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class FavoriteList extends StatefulWidget {
  FavoriteList({Key key}) : super(key: key);

  @override
  _FavoriteListState createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  bool _isLoading = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    fav_list();
  }

  int page = 1;

  void fav_list() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      'page': page.toString(),
      'limit': limit,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/my_favroite"), body: data);

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = true;
      });
      print(json.decode(response.body));

      if (page == 1) {
        get_favList(json.decode(response.body)).then((value) {
          setState(() {
            favList = value;
          });
        });
      } else {
        get_favList(json.decode(response.body)).then((value) {
          setState(() {
            favList.addAll(value);
          });
        });
        print("____nandhu--------");
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AdsList> favList = List<AdsList>();

  Future<List<AdsList>> get_favList(favsJson) async {
    var favList = List<AdsList>();
    for (var favJson in favsJson) {
      favList.add(AdsList.fromJson(favJson));
    }
    return favList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "My Favorites",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
      ),
      body: Container(
        child: _isLoading
            ? favList.length != 0
                ? ListView.builder(
                    shrinkWrap: false,
                    scrollDirection: Axis.vertical,
                    itemCount: favList.length,
                    itemBuilder: (context, index) {
                      return favlist(favList, index);
                    })
                : Container(
                    alignment: Alignment.center,
                    child: Image.asset("assets/nodata.png"))
            : Center(
                child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
              )),
      ),
    );
  }

  Widget favlist(List<AdsList> favList, int index) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute<bool>(
              fullscreenDialog: true,
              builder: (BuildContext context) =>
                  AdsDetailPage(ads_id: favList[index].id.toString()),
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
                      // child: Image.asset(
                      //   "assets/car_sale.jpg",
                      //   fit: BoxFit.fill,
                      // ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(favList[index].ads_image),
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
                            favList[index].ads_price,
                            style: TextStyle(
                                color: color2,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            favList[index].ads_name,
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
                              Text(favList[index].city_name,
                                  style: TextStyle(fontSize: 12)),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  deleteFav(favList[index].id.toString());
                                  setState(() {
                                    favList.removeAt(index);
                                  });
                                },
                                child: Icon(
                                  Icons.favorite,
                                  size: 22,
                                  color: primaryColor,
                                ),
                              ),
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
