import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Google%20ADs/AdMob_Helper.dart';
import 'package:glocal_bizz/Model/Store_model.dart';
import 'package:glocal_bizz/View/CreateStore/Create_store.dart';
import 'package:glocal_bizz/Widgets/OurProduct_widget.dart';

import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'dart:async';
import 'package:url_launcher/link.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as locationPackage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AboutStore.dart';

class StoreDetails extends StatefulWidget {
  final int store_id;
  StoreDetails({Key key, this.store_id}) : super(key: key);

  @override
  _StoreDetailsState createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  final TextEditingController commend = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<StoreDetail> _storedetail;
  SharedPreferences prefs;
  bool store = false;
  bool delivery = false;

  @override
  void initState() {
    super.initState();
    _storedetail = store_detail();
    our_product();
  }

  Future<StoreDetail> store_detail() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'store_id': widget.store_id.toString(),
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/store_detail"), body: data);
    print(json.decode(response.body));
    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print("--------------NK-----------");
      print(jsonResponse);

      return StoreDetail.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<void> our_product() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'store_id': widget.store_id.toString(),
    };
    var response =
        await http.post(Uri.parse(api_url + "/get_product"), body: data);

    if (response.statusCode == 200) {
      get_productList(json.decode(response.body)).then((value) {
        setState(() {
          productList = value;
        });
      });
    }
  }

  List<Products> productList = List<Products>();

  Future<List<Products>> get_productList(productListsJson) async {
    var productLists = List<Products>();
    for (var productListJson in productListsJson) {
      productLists.add(Products.fromJson(productListJson));
    }
    return productLists;
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
      _permissionGranted =
          (await _locationService.requestPermission()) as PermissionStatus;
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await _locationService.getLocation();
    print("-------------NK---------------");
    print(_locationData.latitude + _locationData.longitude);
    openMap(_locationData.latitude, _locationData.longitude);
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    var uri = Uri.parse("google.navigation:q=$latitude,$longitude&mode=d");
    print(googleUrl);
    _launchMap(googleUrl);
  }

  Future<void> _launchMap(mapURL) async {
    if (await canLaunch(mapURL.toString())) {
      await launch(
        mapURL,
        forceWebView: true,
        forceSafariVC: true,
      );
    } else {
      throw 'Could not open the map.';
    }
  }

  // void _launchCall(number) async => await canLaunch(number)
  //     ? await launch(number)
  //     : throw 'Could not launch $number';

  Future<void> _launchCall(phone) async {
    // const url = 'tel:9876543210';
    if (await canLaunch('tel:' + phone)) {
      await launch('tel:' + phone);
    } else {
      throw 'Could not launch $phone';
    }
  }

  void reportStore(storeID, issue, cmnd) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "reported_by": prefs.getString("user_id"),
      "store_id": storeID,
      "issuses_type": issue,
      "comments": cmnd,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/store_report"), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      Navigator.of(context).pop();
      commend.clear();
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("Report send successfully!!")));
      print(jsonResponse);
    } else {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      key: _scaffoldKey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FutureBuilder<StoreDetail>(
                  future: _storedetail, // async work
                  builder: (BuildContext context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Container(
                          height: 600,
                          alignment: Alignment.bottomCenter,
                          child: Center(
                              child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(primaryColor),
                          )),
                        );
                      default:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else if (snapshot.data.store_open == 1) {
                          store = true;
                        } else {
                          store = false;
                        }

                        if (snapshot.data.delivery_option == 1) {
                          delivery = true;
                        } else {
                          delivery = false;
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: snapshot.data.store_banner,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    height: 220,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      image: imageProvider,
                                      // fit: BoxFit.fill
                                    )),
                                  ),
                                ),
                                // BackButton(),
                                Container(
                                  alignment: Alignment.topLeft,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  height: 220,
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0)),
                                    child: CloseButton(
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot.data.store_name ??
                                                    "--",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  // Icon(
                                                  //   Icons
                                                  //       .location_on_outlined,
                                                  //   size: 22,
                                                  //   color: Colors.green,
                                                  // ),
                                                  Text(
                                                    snapshot.data
                                                            .store_address +
                                                        ". ",
                                                    style: TextStyle(),
                                                  ),
                                                  // Icon(
                                                  //   Icons
                                                  //       .directions_walk_outlined,
                                                  //   size: 20,
                                                  //   color: Colors.green,
                                                  // ),
                                                  // Text(
                                                  //   "  850 mts",
                                                  //   style: TextStyle(),
                                                  // ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              snapshot.data.from_time != null
                                                  ? Text("OPEN : " +
                                                      snapshot.data.from_time +
                                                      " to " +
                                                      snapshot.data.to_time)
                                                  : SizedBox(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                                snapshot.data.store_logo ??
                                                    "--"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _launchCall(snapshot
                                                    .data.store_contact);
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: Icon(
                                                  Icons.call_outlined,
                                                  size: 26,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "Call",
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Icon(
                                                Icons.chat_outlined,
                                                size: 26,
                                                color: primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "Chat",
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Share.share(
                                                    snapshot.data.store_link ??
                                                        "--");
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: Icon(
                                                  Icons.share_outlined,
                                                  size: 26,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "Share",
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        // Padding(
                                        //   padding: EdgeInsets.only(
                                        //       top: 10, bottom: 10),
                                        //   child: LiteRollingSwitch(
                                        //     value: store,
                                        //     textOn: 'Open',
                                        //     textOff: 'Closed',
                                        //     colorOn: Colors.deepOrange,
                                        //     colorOff: Colors.blueGrey,
                                        //     iconOn: Icons.lightbulb_outline,
                                        //     iconOff: Icons.power_settings_new,
                                        //     onSwipe: () {
                                        //       return false;
                                        //     },
                                        //     onTap: () {
                                        //       return false;
                                        //     },
                                        //     onChanged: (store) {
                                        //       return false;
                                        //     },
                                        //   ),
                                        // ),
                                        RichText(
                                          text: TextSpan(
                                            text: 'Store: ',
                                            style: TextStyle(
                                                color: color2,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                            children: <TextSpan>[
                                              store
                                                  ? TextSpan(
                                                      text: 'Open',
                                                      style: TextStyle(
                                                          color: primaryColor))
                                                  : TextSpan(
                                                      text: "Closed",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[700])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Column(
                                      children: [
                                        // Padding(
                                        //   padding: EdgeInsets.only(
                                        //       top: 10, bottom: 10),
                                        //   child: LiteRollingSwitch(
                                        //     value: delivery,
                                        //     textOn: 'active',
                                        //     textOff: 'inactive',
                                        //     colorOn: Colors.deepOrange,
                                        //     colorOff: Colors.blueGrey,
                                        //     iconOn: Icons.lightbulb_outline,
                                        //     iconOff: Icons.power_settings_new,
                                        //     onChanged: (bool state) {
                                        //       print(
                                        //           'turned ${(state) ? 'on' : 'off'}');
                                        //     },
                                        //   ),
                                        // ),
                                        RichText(
                                          text: TextSpan(
                                            text: 'Delivery: ',
                                            style: TextStyle(
                                                color: color2,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                            children: <TextSpan>[
                                              delivery
                                                  ? TextSpan(
                                                      text: 'On',
                                                      style: TextStyle(
                                                          color: primaryColor))
                                                  : TextSpan(
                                                      text: "Off",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[700])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "About",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        InkWell(
                                          child: Text(
                                            "MORE",
                                            style: TextStyle(
                                                color: Colors.blue.shade900,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => AboutStore(
                                                        title: snapshot.data
                                                                .store_name ??
                                                            "--",
                                                        address: snapshot.data
                                                                .store_address ??
                                                            "--",
                                                        workTimeFrom: snapshot
                                                                .data
                                                                .from_time ??
                                                            "--",
                                                        workTimeTo: snapshot
                                                                .data.to_time ??
                                                            "--",
                                                        mobileNO: snapshot.data
                                                                .store_contact ??
                                                            "--")));
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      snapshot.data.about_us ?? "--",
                                      style: TextStyle(
                                          color: color2,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    snapshot.data.business_since != null
                                        ? Text(
                                            "On GlocalBizz since " +
                                                snapshot.data.business_since,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10,
                                                fontWeight: FontWeight.normal),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Location",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: color2,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        InkWell(
                                          child: Text(
                                            "GET DIRECTIONS",
                                            style: TextStyle(
                                                color: Colors.blue.shade900,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          // onTap: getLocation,
                                          onTap: () {
                                            openMap(
                                              double.parse(snapshot
                                                  .data.latitude
                                                  .toString()),
                                              double.parse(snapshot
                                                  .data.longitude
                                                  .toString()),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            snapshot.data.store_address ?? "--",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                        // Spacer(),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Image.asset(
                                              "assets/store.png",
                                              height: 70,
                                              width: 70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            // Align(
                            //   alignment: Alignment.topCenter,
                            //   child: Container(
                            //     width: AdmobHelper.getBannerAd()
                            //         .size
                            //         .width
                            //         .toDouble(),
                            //     height: AdmobHelper.getBannerAd()
                            //         .size
                            //         .height
                            //         .toDouble(),
                            //     child: AdWidget(
                            //         ad: AdmobHelper.getBannerAd()..load()),
                            //   ),
                            // ),
                            InkWell(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 15),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: color2,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Report",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: color2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      int selectedRadio;
                                      String commendType;

                                      final _buttonOptions = [
                                        TimeValue(0, "Offensive content"),
                                        TimeValue(1, "Fraud"),
                                        TimeValue(2, "Duplicate store"),
                                        TimeValue(3, "Selling Expierd product"),
                                        TimeValue(4, "Other"),
                                      ];
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        content: Container(
                                          width: 400,
                                          // color: Colors.amber,
                                          child: Stack(
                                              overflow: Overflow.visible,
                                              children: <Widget>[
                                                Positioned(
                                                  right: -15.0,
                                                  top: -13.0,
                                                  child: InkResponse(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: CircleAvatar(
                                                      child: Icon(
                                                        Icons.close,
                                                        color: white,
                                                      ),
                                                      backgroundColor:
                                                          primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                SingleChildScrollView(
                                                  child: Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Report about this store",
                                                          style: TextStyle(
                                                              color: color2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        SizedBox(
                                                          height: 7,
                                                        ),
                                                        Container(
                                                          child: StatefulBuilder(
                                                              builder: (BuildContext
                                                                      context,
                                                                  StateSetter
                                                                      setState) {
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children:
                                                                  _buttonOptions
                                                                      .map((timeValue) =>
                                                                          RadioListTile(
                                                                            contentPadding:
                                                                                EdgeInsets.all(0),
                                                                            groupValue:
                                                                                selectedRadio,
                                                                            title:
                                                                                Text(timeValue._value),
                                                                            value:
                                                                                timeValue._key,
                                                                            // value: timeValue._key,
                                                                            onChanged:
                                                                                (val) {
                                                                              setState(() {
                                                                                debugPrint('VAL = $val');
                                                                                selectedRadio = val;
                                                                                commendType = timeValue._value;
                                                                                debugPrint(timeValue._value);
                                                                              });
                                                                            },
                                                                          ))
                                                                      .toList(),
                                                            );
                                                          }),
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                        ),
                                                        TextFormField(
                                                          maxLines: 3,
                                                          validator: (value) {
                                                            if (value.isEmpty) {
                                                              return 'Write your comment';
                                                            }
                                                            return null;
                                                          },
                                                          cursorHeight: 18,
                                                          onSaved:
                                                              (String value) {},
                                                          controller: commend,
                                                          obscureText: false,
                                                          onTap: () {},
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            color: black,
                                                          ),
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          decoration:
                                                              textDecoration(
                                                                  'Commend',
                                                                  'Write your command'),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            OutlinedButton(
                                                              child: Text(
                                                                  'Cancel'),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width: 15,
                                                            ),
                                                            OutlinedButton(
                                                              child:
                                                                  Text('Send'),
                                                              onPressed: () {
                                                                reportStore(
                                                                    snapshot
                                                                        .data.id
                                                                        .toString(),
                                                                    commendType,
                                                                    commend
                                                                        .text);
                                                              },
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ]),
                                        ),
                                      );
                                    });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "OUR PRODUCT",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                            // Container(
                            //   width: MediaQuery.of(context).size.width,
                            //   height: 210,
                            //   // color: appcolor,
                            //   child: new ListView.builder(
                            //       shrinkWrap: false,
                            //       scrollDirection: Axis.horizontal,
                            //       itemCount: 5,
                            //       itemBuilder: (context, index) {
                            //         return OurProductWidget();
                            //       }),
                            // ),
                          ],
                        );
                    }
                  }),
            ),
            productList.length == 0
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Center(
                          child: Text(
                        "No Products available",
                        style: TextStyle(color: Colors.grey),
                      )),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 3,
                        childAspectRatio: 0.90,
                        crossAxisCount:
                            (orientation == Orientation.portrait) ? 2 : 3),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return OurProductWidget(productList[index]);
                      },
                      childCount: productList.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class TimeValue {
  final int _key;
  final String _value;
  TimeValue(this._key, this._value);
}
