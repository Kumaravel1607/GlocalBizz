import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/Service.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Controller/fav_controller.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
import 'package:glocal_bizz/Google%20ADs/ad_helper.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/CreateStore/Cart.dart';
import 'package:glocal_bizz/View/CreateStore/StoreList.dart';
import 'package:glocal_bizz/View/Login.dart';
import 'package:glocal_bizz/View/Post/ListAdPost.dart';
import 'package:glocal_bizz/View/NotificationPage.dart';
import 'package:glocal_bizz/View/SearchList.dart';
import 'package:glocal_bizz/Widgets/GridWidget.dart';
import 'package:glocal_bizz/Widgets/FeatureListWidget.dart';
import 'package:glocal_bizz/Widgets/Search.dart';
import 'package:glocal_bizz/Controller/location_controller.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:intl/intl.dart';
// import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:glocal_bizz/Model/Store_model.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'Category.dart';
import 'Chatting/NewChatList.dart';
import 'CreateStore/StoreDetail.dart';
import 'DemoTest.dart';
import 'OnBoarding.dart';
import 'PostDonePage.dart';
import 'SubCategory.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as locationPackage;
import 'package:new_version/new_version.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // COMPLETE: Add _bannerAd
  // BannerAd _bannerAd;

  // COMPLETE: Add _isBannerAdReady
  bool _isBannerAdReady = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchData = new TextEditingController();
  final TextEditingController _location = new TextEditingController();

  // final GlobalKey<RefreshIndicatorState> refreshKey =
  //     new GlobalKey<RefreshIndicatorState>();

  bool _refreshing = false;
  SharedPreferences prefs;
  int notificationCount;
  int chatCount = 0;
  int cartCount;
  bool notify = false;

  // bool fav = false;
  String cityName;
  String cityId;
  bool loading = true;
  bool _adsLoading = false;
  bool _isLoading = false;
  String getCurrentAddress;
  static const _pageSize = 10;
  final PagingController<int, AdsList> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    print("homeeeeeeeeeee");
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    // TODO: implement initState
    super.initState();
    _checkVersion();
    cityNameAndId();
    // COMPLETE: Initialize _bannerAd
    // _bannerAd = BannerAd(
    //   adUnitId: AdHelper.bannerAdUnitId,
    //   request: AdRequest(),
    //   size: AdSize(width: 400, height: 250),
    //   listener: BannerAdListener(
    //     onAdLoaded: (_) {
    //       setState(() {
    //         _isBannerAdReady = true;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, err) {
    //       print('Failed to load a banner ad: ${err.message}');
    //       _isBannerAdReady = false;
    //       ad.dispose();
    //     },
    //   ),
    // );

    // _bannerAd.load();
  }

  void _checkVersion() async {
    final newVersion = NewVersion(androidId: "com.glocalbizz.gb");
    final status = await newVersion.getVersionStatus();

    status.canUpdate
        ? newVersion.showUpdateDialog(
            context: context,
            versionStatus: status,
            dialogTitle: "Update app?",
            dialogText: "A new version of Upgrader is available! Version " +
                '${status.storeVersion}' +
                " is now available-you have " +
                '${status.localVersion}',
            dismissAction: () {
              SystemNavigator.pop();
            })
        : print("------------NK----------");

    // newVersion.showUpdateDialog(
    //     context: context,
    //     versionStatus: status,
    //     dialogTitle: "Update app?",
    //     dialogText: "A new version of Upgrader is available! Version " +
    //         '${status.storeVersion}' +
    //         " is now available-you have " +
    //         '${status.localVersion}',
    //     dismissAction: () {
    //       SystemNavigator.pop();
    //     });

    // print("localVersion " + '${status.localVersion}');
    // print("storeVersion " + '${status.storeVersion}');
    // print("can update " + '${status.canUpdate}');
    // print("Link " + '${status.appStoreLink}');
  }

  Future<void> cityNameAndId() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString("city_Name") != null) {
      cityName = prefs.getString("city_Name");
      cityId = prefs.getString("city_Id");
    }
    homeAPI();
    _pagingController.refresh();
    // ads_list();
  }

  locationPackage.Location _locationService = new locationPackage.Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  locationPackage.LocationData _locationData;

  getLocation() async {
    _serviceEnabled = await _locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationService.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    if (_permissionGranted == PermissionStatus.denied) {
      setState(() {
        getCurrentAddress = "Enable Location";
      });
      _permissionGranted =
          (await _locationService.requestPermission()) as PermissionStatus;
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      getCurrentAddress = "Enable Location...";
    });
    _locationData = await _locationService.getLocation();
    print("-------------NK---------------");
    print(_locationData.latitude + _locationData.longitude);
    getAddress(_locationData.latitude, _locationData.longitude);
  }

  void getAddress(latitude, longitude) async {
    prefs = await SharedPreferences.getInstance();
    final coordinates = new Coordinates(latitude, longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    setState(() {
      _location.text =
          first.subAdminArea.toString() + ', ' + first.adminArea.toString();
      print(first.locality.toString());
      if (first.locality != null) {
        cityName =
            first.locality.toString() + ', ' + first.subAdminArea.toString();
        getCurrentAddress =
            first.locality.toString() + ', ' + first.subAdminArea.toString();
      } else {
        cityName = first.subAdminArea.toString();
        getCurrentAddress = first.subAdminArea.toString();
      }
    });
    getCityId(first.subAdminArea.toString());
  }

  Future<void> getCityId(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'city_name': value,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/city_name"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        cityId = jsonResponse['id'].toString();
        prefs.setString("city_Name", value);
        prefs.setString("city_Id", jsonResponse['id'].toString());
        homeAPI();
        // ads_list();

        _pagingController.refresh();
      });
      print("cuty id enabled");
      Navigator.pop(context);
    } else {
      // ads_list();
      _alerDialog("Your city is not found \n Please choose manully...");
      print("error getlocation api");
      print(json.decode(response.body));
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  Future<void> checkLogoutStatus() async {
    _logoutDialog("Account is Deactivated");
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
  }

  Future<Null> _logOutFB() async {
    await facebookSignIn.logOut();
  }

  Future<void> _logoutDialog(message) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message),
            //title: Text(),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () async {
                  prefs = await SharedPreferences.getInstance();
                  prefs.clear();
                  prefs.commit();
                  _signOut();
                  _logOutFB();

                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()),
                      (Route<dynamic> route) => false);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: color2),
                ),
              )
            ],
          );
        });
  }

  Future<void> homeAPI() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "customer_id": prefs.getString("user_id"),
      "city_id": cityId != null ? cityId : "",
    };
    print(jsonEncode(data));
    var response = await http.post(Uri.parse(api_url + "/home"), body: data);
    print(Uri.parse(api_url + "/home"));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result['customer_data'] == 0) {
        checkLogoutStatus();
      }
      setState(() {
        _isLoading = true;
        notificationCount = result['notification'];
        cartCount = result['cart'];

        chatCount = result['chats_count'];
        notify = true;
      });

      get_banner(result['banner']).then((value) {
        setState(() {
          headerBanner = value;
        });
      });

      get_categoryList(result['category']).then((value) {
        setState(() {
          categoryList = value;
        });
      });

      feature_adsList(result['feature_ads']).then((value) {
        setState(() {
          feature_ads = value;
        });
      });

      get_store(result['store']).then((value) {
        setState(() {
          storesList = value;
        });
      });

      // cityName = prefs.getString("city_Name");
      // cityId = prefs.getString("city_Id");

      // getLocation();
    } else {
      setState(() {
        _isLoading = false;
      });
      print("error home api");
    }
  }

  List<HeaderBanner> headerBanner = List<HeaderBanner>();

  Future<List<HeaderBanner>> get_banner(headerBannersJson) async {
    var headerBanner = List<HeaderBanner>();
    for (var headerBannersJson in headerBannersJson) {
      headerBanner.add(HeaderBanner.fromJson(headerBannersJson));
    }
    return headerBanner;
  }

  List<CategoryList> categoryList = List<CategoryList>();

  Future<List<CategoryList>> get_categoryList(categorysJson) async {
    var categorys = List<CategoryList>();
    for (var categoryJson in categorysJson) {
      categorys.add(CategoryList.fromJson(categoryJson));
    }
    return categorys;
  }

  List<AdsList> feature_ads = List<AdsList>();

  Future<List<AdsList>> feature_adsList(adsJson) async {
    var feature_ads = List<AdsList>();
    for (var adJson in adsJson) {
      feature_ads.add(AdsList.fromJson(adJson));
    }
    return feature_ads;
  }

  List<AllStoreList> storesList = List<AllStoreList>();

  Future<List<AllStoreList>> get_store(storesListsJson) async {
    var storesList = List<AllStoreList>();
    for (var storesListsJson in storesListsJson) {
      storesList.add(AllStoreList.fromJson(storesListsJson));
    }
    return storesList;
  }

  int page = 1;

  Future<void> _fetchPage(int pageKey) async {
    try {
      prefs = await SharedPreferences.getInstance();
      print("-------------");
      Map data = {
        "page": (((pageKey + 10) / (_pageSize)).toString()),
        'limit': limit,
        'category_id': "",
        'sub_category_id': "",
        'customer_id': prefs.getString("user_id"),
        'city_id': cityId != null ? cityId : "",
        'search_text': "",
      };
      print(data);
      var result;

      var response = await http.post(Uri.parse(api_url + "/ads"), body: data);
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

  // void ads_list() async {
  //   prefs = await SharedPreferences.getInstance();
  //   Map data = {
  //     'page': page.toString(),
  //     'limit': limit,
  //     'category_id': "",
  //     'sub_category_id': "",
  //     'customer_id': prefs.getString("user_id"),
  //     'city_id': cityId != null ? cityId : "",
  //     'search_text': "",
  //   };
  //   print(data);
  //   var result;
  //   var response = await http.post(Uri.parse(api_url + "/ads"), body: data);
  //   // print(json.decode(response.body));
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _adsLoading = true;
  //     });
  //     result = json.decode(response.body);
  //     print(result);
  //     // if (page == 1) {
  //     //   get_adsList(result).then((value) {
  //     //     setState(() {
  //     //       ads = value;
  //     //     });
  //     //   });
  //     // } else {
  //     //   get_adsList(result).then((value) {
  //     //     setState(() {
  //     //       ads.addAll(value);
  //     //     });
  //     //   });
  //     // }
  //   } else {
  //     print("error ads list api");
  //     setState(() {
  //       _adsLoading = false;
  //     });
  //   }
  // }

  // Future<void> _fetchPage(int pageKey) async {
  //   print(pageKey);

  //   try {
  //     final newItems = await Service.getMatchDetails(page, limit, cityId, "");

  //     ads = newItems;
  //     final isLastPage = newItems.length < _pageSize;
  //     if (isLastPage) {
  //       _pagingController.appendLastPage(newItems);
  //     } else {
  //       // if (pageKey == 0) {
  //       //   final nextPageKey = pageKey + newItems.length;
  //       //   _pagingController.set(newItems, nextPageKey);
  //       // } else {
  //       final nextPageKey = pageKey + newItems.length;
  //       _pagingController.appendPage(newItems, nextPageKey);
  //       // }
  //     }
  //   } catch (error) {
  //     _pagingController.error = error;
  //   }
  // }

  // List<AdsList> ads = List<AdsList>();

  // Future<List<AdsList>> get_adsList(adsJson) async {
  //   var ads = List<AdsList>();
  //   for (var adJson in adsJson) {
  //     ads.add(AdsList.fromJson(adJson));
  //   }
  //   return ads;
  // }

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
                  Navigator.pop(context, "ok");
                },
                child: const Text("OK"),
              )
            ],
          );
        });
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
    homeAPI();
    // ads_list();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted)
      setState(() {
        page++;
        //  ads_list();
      });
  }

  FutureOr onGoBack(dynamic value) {
    homeAPI();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFf8f8f8),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0), // here the desired height
        child: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: primaryColor,
          automaticallyImplyLeading: false,
          title: GestureDetector(
            child: Row(
              children: [
                Image.asset(
                  "assets/glocal_logo.png",
                  height: 50,
                  width: 50,
                ),
                Text(
                  "Glocal Bizz",
                  style: TextStyle(
                      color: white, fontWeight: FontWeight.w600, height: 2.5),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(
                    Icons.my_location_outlined,
                    color: white,
                    size: 22,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      _showLocation();
                    },
                    child: Text(cityName != null ? cityName : "All India",
                        style:
                            TextStyle(fontSize: 14, color: white, height: 3))),
              ],
            ),
            onTap: () {
              // _showLocation();
            },
          ),

          /*  actions: [
            InkWell(
              child: Icon(Icons.shopping_cart_sharp, color: white),
              onTap: () {
                // _checkVersion();
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) => CartPage()));
              },
            ),
          ], */
          flexibleSpace: Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 12.0),
              height: 50.0,
              // width: 355,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      readOnly: true,
                      // enabled: false,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          PageRouteBuilder(
                            pageBuilder: (c, a1, a2) => SearchListPage(),
                            transitionsBuilder: (c, anim, a2, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration: Duration(milliseconds: 100),
                          ),
                        );
                      },
                      onSubmitted: (value) {
                        // _searchData.text.isEmpty
                        //     ? null
                        //     : Navigator.of(context, rootNavigator: true).push(
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 AdsListingPage(seachData: _searchData.text)));
                      },
                      cursorColor: color2,
                      keyboardType: TextInputType.text,
                      controller: _searchData,
                      placeholder: 'Search here...',
                      placeholderStyle: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.grey,
                      ),
                      prefix: Padding(
                        padding: const EdgeInsets.fromLTRB(9.0, 7.0, 9.0, 8.0),
                        child: InkWell(
                            child: Icon(
                              Icons.search_sharp,
                              color: Colors.grey,
                              size: 23,
                            ),
                            onTap: () {
                              // _searchData.text.isEmpty
                              //     ? null
                              //     : Navigator.of(context, rootNavigator: true).push(
                              //         MaterialPageRoute(
                              //             builder: (context) => AdsListingPage(
                              //                 seachData: _searchData.text)));
                            }),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Color(0xffF0F1F5),
                      ),
                    ),
                  ),
                  // InkWell(
                  //   child: Icon(Icons.business, color: white),
                  //   onTap: _getyear,
                  // ),
                  SizedBox(
                    width: 12,
                  ),
                  InkWell(
                    child: cartCount != null
                        ? Badge(
                            badgeContent: Text(
                              '$cartCount',
                              style: TextStyle(color: white),
                            ),
                            child:
                                Icon(Icons.shopping_cart_sharp, color: white))
                        : Icon(Icons.shopping_cart_sharp, color: white),
                    onTap: () {
                      // _checkVersion();
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(
                              builder: (context) => CartPage()))
                          .then(onGoBack);
                    },
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  notify
                      ? notificationCount == 0
                          ? GestureDetector(
                              child: Icon(Icons.notifications, color: white),
                              onTap: () {
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationPage()));
                              })
                          : GestureDetector(
                              child: Badge(
                                badgeContent: Text(
                                  '$notificationCount',
                                  style: TextStyle(color: white),
                                ),
                                child: Icon(Icons.notifications, color: white),
                              ),
                              onTap: () {
                                // close_notification();
                                setState(() {
                                  notificationCount = 0;
                                });
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationPage()));
                              })
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        child: FittedBox(
          child: Stack(
            alignment: Alignment(1.3, -1.3),
            children: [
              FloatingActionButton(
                  backgroundColor: white,
                  splashColor: color2,
                  elevation: 8,
                  mini: false,
                  onPressed: () {
                    setState(() {
                      chatCount = 0;
                    });
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => ChatListPage()));
                  },
                  tooltip: 'Chat',
                  shape: StadiumBorder(
                      side: BorderSide(color: primaryColor, width: 1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.forum,
                        size: 22,
                        color: primaryColor,
                      ),
                      Text(
                        "Chat",
                        style: TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  )),
              chatCount != 0
                  ? Container(
                      child: Center(
                        child: Text('$chatCount',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                      padding: EdgeInsets.all(3),
                      constraints: BoxConstraints(minHeight: 23, minWidth: 23),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 1,
                              blurRadius: 5,
                              color: Colors.black.withAlpha(50))
                        ],
                        borderRadius: BorderRadius.circular(16),
                        color: color2, // This would be color of the Badge
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                Future.sync(
                  () => _pagingController.refresh(),
                );
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        banner_carousel(),
                        Container(
                          color: Color(0xEEFFFFFF),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Text(
                                  "Category",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .push(CupertinoPageRoute(
                                            builder: (context) =>
                                                CategoryPage()));
                                  },
                                  child: Text(
                                    "View All",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 130,
                          color: Color(0xEEFFFFFF),
                          child: new ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryList.length,
                            itemBuilder: (context, index) =>
                                category(categoryList[index]),
                            // children: [
                            //   category("Mobile", "assets/smartphone.png"),
                            //   category("Car", "assets/car1.png"),
                            //   category("Headset", "assets/headset.png"),
                            //   category("Electronic", "assets/electronics.png"),
                            //   category("Bike", "assets/scooter.png"),
                            // ],
                          ),
                        ),
                        // if (_isBannerAdReady)
                        //   Align(
                        //     alignment: Alignment.topCenter,
                        //     child: Container(
                        //       width: _bannerAd.size.width.toDouble(),
                        //       height: _bannerAd.size.height.toDouble(),
                        //       child: AdWidget(ad: _bannerAd),
                        //     ),
                        //   ),
                        storesList.length == 0
                            ? SizedBox()
                            : Container(
                                color: Color(0xEEFFFFFF),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Near By Stores",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(CupertinoPageRoute(
                                                  builder: (context) =>
                                                      StoreLists()));
                                        },
                                        child: Text(
                                          "View All",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        storesList.length == 0
                            ? SizedBox()
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                height: 130,
                                color: Color(0xEEFFFFFF),
                                child: new ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: storesList.length,
                                  itemBuilder: (context, index) =>
                                      nearStore(storesList[index]),
                                ),
                              ),
                        feature_ads.length == 0
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "Feature Ads",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                        feature_ads.length == 0
                            ? SizedBox()
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                height: 240,
                                // color: appcolor,
                                child: new ListView.builder(
                                    shrinkWrap: false,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: feature_ads.length,
                                    itemBuilder: (context, index) {
                                      List<String> savedFav = List<String>();
                                      String favID =
                                          feature_ads[index].id.toString();
                                      savedFav.remove(favID);
                                      if (feature_ads[index].favorite_status ==
                                          "1") {
                                        savedFav.add(favID);
                                      }
                                      bool issaved = savedFav.contains(favID);

                                      void selectFav() {
                                        setState(() {
                                          print(savedFav.contains(favID));
                                          if (issaved) {
                                            feature_ads[index].favorite_status =
                                                "0";
                                            savedFav.remove(favID);

                                            deleteFav(feature_ads[index]
                                                .id
                                                .toString());
                                          } else {
                                            feature_ads[index].favorite_status =
                                                "1";
                                            savedFav.add(favID);
                                            saveFav(feature_ads[index]
                                                .id
                                                .toString());
                                          }
                                        });
                                      }

                                      return FeatureListWidget(issaved,
                                          selectFav, feature_ads, index);
                                    }),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Recent Ads",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PagedSliverGrid<int, AdsList>(
                    pagingController: _pagingController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 100 / 100,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                    ),
                    builderDelegate: PagedChildBuilderDelegate<AdsList>(
                        itemBuilder: (context, item, index) {
                      List<String> savedFav = List<String>();
                      String favID = item.id.toString();
                      savedFav.remove(favID);
                      if (item.favorite_status == "1") {
                        savedFav.add(favID);
                      }
                      bool issaved = savedFav.contains(favID);

                      void selectFav() {
                        setState(() {
                          print(savedFav.contains(favID));
                          if (issaved) {
                            item.favorite_status = "0";
                            savedFav.remove(favID);

                            deleteFav(item.id.toString());
                          } else {
                            item.favorite_status = "1";
                            savedFav.add(favID);
                            saveFav(item.id.toString());
                          }
                        });
                      }

                      return GridWidget(issaved, selectFav, item, index);
                    }),
                  ),
                ],
              ),
            )
          : Container(
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
              )),
            ),
    );
  }

  Widget banner_carousel() => GestureDetector(
        child: new Container(
          child: CarouselSlider.builder(
              options: CarouselOptions(
                height: 180,
                viewportFraction: 1.0,
                // aspectRatio: 2.0,
                autoPlay: true,
                enableInfiniteScroll: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayCurve: Curves.easeInCubic,
                enlargeCenterPage: false,
                reverse: false,
              ),
              itemCount: headerBanner.isNotEmpty ? headerBanner.length : 1,
              itemBuilder: (context, index, int) {
                return Builder(
                  builder: (BuildContext context) {
                    return CachedNetworkImage(
                      imageUrl: headerBanner[index].banner_image != null
                          ? headerBanner[index].banner_image
                          : AssetImage("assets/car_sale.jpg"),
                      imageBuilder: (context, imageProvider) => Container(
                        padding: EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        // margin: EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          // color: Color(0xFFf8f8f8),
                          // borderRadius: BorderRadius.circular(2),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    );
                  },
                );
              }),
        ),
        onTap: () {
          // photoView();
        },
      );

  Widget category(CategoryList categoryList) {
    return Padding(
      padding: EdgeInsets.only(top: 13, bottom: 13, left: 7),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              builder: (context) =>
                  SubCategoryPage(category_id: categoryList.id)));
        },
        child: Container(
          // height: 120,
          width: 90,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            // color: Color(0xEEFFFFFF),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                height: 70,
                width: 75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFf8f8f8)),
                child: CachedNetworkImage(
                  imageUrl: categoryList.category_image,
                ),
                // child: Image.network(imgName),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                categoryList.category_name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: black, fontSize: 14),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget nearStore(AllStoreList storesList) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 7),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              builder: (context) => StoreDetails(store_id: storesList.id)));
        },
        child: Container(
          // height: 120,
          width: 90,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            // color: Color(0xEEFFFFFF),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(13),
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Color(0xFFf8f8f8)),
                child: Image.network(storesList.store_logo),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                storesList.store_name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: black, fontSize: 14),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showLocation() {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
            height: MediaQuery.of(context).size.height,
            color: white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Search Your Location",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: appcolor,
                  ),
                ),
                SizedBox(
                  height: 13,
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  minVerticalPadding: 0,
                  leading: Icon(
                    Icons.my_location_outlined,
                    size: 27,
                    color: Colors.indigo[900],
                  ),
                  title: Text(
                    "Use Current Location",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    getCurrentAddress != null
                        ? getCurrentAddress
                        : "Enable Location..",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: color2,
                    ),
                  ),
                  onTap: getLocation,
                  // onTap: () async {
                  //   getLocation();
                  //   await Future.delayed(Duration(seconds: 2), () {
                  //     Navigator.pop(context);
                  //   });
                  // },
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  minVerticalPadding: 0,
                  leading: Image.asset(
                    "assets/flag.png",
                    height: 27,
                    width: 27,
                  ),
                  title: Text(
                    "All India",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "All Over India",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: color2,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      cityId = "";
                      cityName = "All India";
                      _location.text = "All India";
                      prefs.setString("city_Name", "All India");
                      prefs.setString("city_Id", "");
                    });
                    homeAPI();
                    _pagingController.refresh();
                    //ads_list();
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                  },
                ),
                // InkWell(
                //   onTap: () {
                //     setState(() {
                //       cityName = "All India";
                //       _location.text = "All India";
                //       cityId = "";
                //     });
                //     ads_list();
                //     Navigator.pop(context);
                //   },
                //   child: Text(
                //     "              All India",
                //     style: TextStyle(
                //       fontSize: 15.0,
                //       color: Colors.indigo[900],
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 45,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200],
                      blurRadius: 5.0,
                      spreadRadius: 3.0,
                    ),
                  ]),
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        controller: _location,
                        decoration: textDecoration2("Search Location")),
                    suggestionsCallback: (pattern) async {
                      print(pattern);
                      return await get_locationData(pattern);
                    },
                    itemBuilder: (context, item) {
                      return list(item);
                    },
                    onSuggestionSelected: (item) async {
                      prefs = await SharedPreferences.getInstance();
                      setState(() {
                        _location.text = item.city_name;
                        cityName = item.city_name;
                        cityId = item.id;
                        prefs.setString("city_Name", item.city_name);
                        prefs.setString("city_Id", item.id);
                      });
                      page = 1;
                      homeAPI();
                      _pagingController.refresh();
                      //  ads_list();
                      Navigator.pop(context);
                      // ads_list();
                      // page = 1;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    print('modal closed');
    _location.clear();
    // Navigator.pop(context);
  }
}
