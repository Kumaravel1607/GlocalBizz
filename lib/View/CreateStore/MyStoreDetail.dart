import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/Store_model.dart';
import 'package:glocal_bizz/View/CreateStore/Create_store.dart';
import 'package:glocal_bizz/View/CreateStore/EditProduct.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/MyProductWidget.dart';
import 'package:glocal_bizz/Widgets/OurProduct_widget.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'AddProduct.dart';
import 'EditStore.dart';
import 'ProductDetail.dart';

class MyStoreDetails extends StatefulWidget {
  MyStoreDetails({Key key}) : super(key: key);

  @override
  _MyStoreDetailsState createState() => _MyStoreDetailsState();
}

class _MyStoreDetailsState extends State<MyStoreDetails>
    with AutomaticKeepAliveClientMixin<MyStoreDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<MyStoreDetail> _storedetail;
  SharedPreferences prefs;
  bool store = false;
  bool delivery = false;
  String storename;
  String storebanner;
  String mobile;
  bool _isLoading = false;

  final GlobalKey<RefreshIndicatorState> refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _storedetail = store_detail();
    our_product();
  }

  Future<MyStoreDetail> store_detail() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/user_store"), body: data);
    print(json.decode(response.body));
    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print("--------------NK-----------");
      print(jsonResponse);
      setState(() {
        _isLoading = true;
        storename = (jsonResponse[0]['store_name']);
        storebanner = (jsonResponse[0]['store_banner']);
        mobile = (jsonResponse[0]['contact_number']);
      });

      return MyStoreDetail.fromJson(jsonResponse[0]);
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load post');
    }
  }

  Future<void> our_product() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'store_id': prefs.getString("store_id"),
    };
    var response =
        await http.post(Uri.parse(api_url + "/get_product"), body: data);

    if (response.statusCode == 200) {
      print(json.decode(response.body));
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

  Future<void> deleteStore() async {
    Map data = {
      'store_id': prefs.getString("store_id"),
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/delete_store"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Store Deleted'),
        ),
      );
      Navigator.of(context, rootNavigator: true)
          .pushReplacement(CupertinoPageRoute(builder: (_) => CreateStore()));
      print(jsonResponse);
    } else {
      print("stor not deleted");
    }
  }

  Future<void> storeTongle(option) async {
    Map data = {
      'store_id': prefs.getString("store_id"),
      'store_open': option,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/store_store_open"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      // _scaffoldKey.currentState.showSnackBar(
      //   SnackBar(
      //     content: const Text("Store Updated"),
      //   ),
      // );
    } else {
      print("stor not deleted");
    }
  }

  Future<void> deleveryTongle(option) async {
    Map data = {
      'store_id': prefs.getString("store_id"),
      'delivery_option': option,
    };
    print(data);
    var jsonResponse;
    var response = await http
        .post(Uri.parse(api_url + "/store_delivery_option"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      // _scaffoldKey.currentState.showSnackBar(
      //   SnackBar(
      //     content: const Text("Store Updated"),
      //   ),
      // );
    } else {
      print("stor not deleted");
    }
  }

  Future<void> _alerBox(msg) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(msg),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, "ok");
                },
                child: const Text("No"),
              ),
              OutlinedButton(
                onPressed: () {
                  deleteStore();
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        });
  }

  Future<Null> _onRefresh() {
    return Future.delayed(Duration(seconds: 2), () {
      our_product();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Refresh Completed...'),
        ),
      );
    });
  }

  FutureOr onGoBack(dynamic value) {
    _storedetail = store_detail();
    our_product();
    setState(() {});
  }

  void _launchCall(number) async => await canLaunch(number)
      ? await launch(number)
      : throw 'Could not launch $number';

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

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blue.shade50,
      // appBar: AppBar(
      //   backgroundColor: primaryColor,
      //   title: Text(
      //     "My Store",
      //     style: TextStyle(color: white),
      //   ),
      //   actions: [
      //     storename != null
      //         ? IconButton(
      //             icon: Icon(Icons.edit_outlined),
      //             onPressed: () {
      //               Navigator.of(context, rootNavigator: true).pushReplacement(
      //                   CupertinoPageRoute(
      //                       builder: (_) => EditStore(title: storename)));
      //             })
      //         : SizedBox(),
      //     storename != null
      //         ? IconButton(
      //             icon: Icon(Icons.delete_outlined),
      //             onPressed: () {
      //               _alerBox("Confirm to delete \n your store");
      //             })
      //         : SizedBox(),
      //   ],
      // ),
      body: _isLoading
          ? SafeArea(
              child: RefreshIndicator(
                key: refreshKey,
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      // elevation: 10,
                      backgroundColor: Colors.blue.shade50,
                      expandedHeight: 200.0,
                      excludeHeaderSemantics: true,
                      floating: false,
                      pinned: false,
                      actions: [
                        storename != null
                            ? IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(CupertinoPageRoute(
                                          builder: (_) =>
                                              EditStore(title: storename)))
                                      .then(onGoBack);
                                })
                            : SizedBox(),
                        storename != null
                            ? IconButton(
                                icon: Icon(Icons.delete_outlined),
                                onPressed: () {
                                  _alerBox("Confirm to delete \n your store");
                                })
                            : SizedBox(),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        // title: Text(storename,
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 16.0,
                        //     )),
                        background: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(storebanner),
                                  fit: BoxFit.fill),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              )),
                          // child: Image.network(
                          //   storebanner,
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        // CachedNetworkImage(
                        //   imageUrl: storebanner,
                        //   imageBuilder: (context, imageProvider) => Image.network(imageProvider),

                        // ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: FutureBuilder<MyStoreDetail>(
                          future: _storedetail, // async work
                          builder: (BuildContext context,
                              AsyncSnapshot<MyStoreDetail> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Container(
                                  height: 600,
                                  alignment: Alignment.bottomCenter,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            primaryColor),
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
                                    SizedBox(
                                      height: 0,
                                    ),
                                    // Stack(
                                    //   children: [
                                    //     CachedNetworkImage(
                                    //       imageUrl: snapshot.data.store_banner,
                                    //       imageBuilder:
                                    //           (context, imageProvider) =>
                                    //               Container(
                                    //         height: 230,
                                    //         decoration: BoxDecoration(
                                    //             color: Color(0xFFf8f8f8),
                                    //             image: DecorationImage(
                                    //               image: imageProvider,
                                    //               // fit: BoxFit.fill
                                    //             )),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        snapshot.data
                                                                    .store_name ==
                                                                null
                                                            ? ""
                                                            : snapshot.data
                                                                .store_name,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                                        .store_address ==
                                                                    null
                                                                ? ""
                                                                : snapshot.data
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
                                                      Text("OPEN : " +
                                                          "${snapshot.data.from_time == null ? "no data" : snapshot.data.from_time}"),
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
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                            .data.store_logo),
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
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.call,
                                                      color: Colors.blueGrey,
                                                    ),
                                                    Text(": " +
                                                        "${mobile == null ? "no contact" : mobile}")
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Share.share(snapshot
                                                            .data.store_link);
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        width: 50,
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .blue.shade50,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
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
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  "STORE",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: color2,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: LiteRollingSwitch(
                                                    value: store,
                                                    textSize: 12,
                                                    textOn: 'OPEN',
                                                    textOff: 'CLOSED',
                                                    colorOn: Colors.deepOrange,
                                                    colorOff: Colors.blueGrey,
                                                    iconOn:
                                                        Icons.lightbulb_outline,
                                                    iconOff: Icons
                                                        .power_settings_new,
                                                    onChanged: (bool state) {
                                                      storeTongle(
                                                          '${(state) ? '1' : '0'}');
                                                      print(
                                                          'Store ${(state) ? 'open' : 'close'}');
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 35,
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  "DELEVERY",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: color2,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: LiteRollingSwitch(
                                                    value: delivery,
                                                    textSize: 12,
                                                    textOn: 'ON',
                                                    textOff: 'OFF',
                                                    colorOn: Colors.deepOrange,
                                                    colorOff: Colors.blueGrey,
                                                    iconOn:
                                                        Icons.lightbulb_outline,
                                                    iconOff: Icons
                                                        .power_settings_new,
                                                    onChanged: (bool state) {
                                                      deleveryTongle(
                                                          '${(state) ? '1' : '0'}');
                                                      print(
                                                          'Delivery ${(state) ? 'on' : 'off'}');
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // divider(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
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
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Spacer(),
                                                InkWell(
                                                  child: Text(
                                                    "GET DIRECTIONS",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .blue.shade900,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
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
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    snapshot.data
                                                                .store_address !=
                                                            null
                                                        ? snapshot
                                                            .data.store_address
                                                        : "--",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal),
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
                                    // SizedBox(
                                    //   height: 5,
                                    // ),
                                    // Card(
                                    //   shape: RoundedRectangleBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(15.0),
                                    //   ),
                                    //   child: Padding(
                                    //     padding: EdgeInsets.symmetric(
                                    //         vertical: 12, horizontal: 15),
                                    //     child: Row(
                                    //       children: [
                                    //         Icon(
                                    //           Icons.info_outline,
                                    //           size: 20,
                                    //           color: color2,
                                    //         ),
                                    //         SizedBox(
                                    //           width: 15,
                                    //         ),
                                    //         Text(
                                    //           "Report",
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.w600),
                                    //         ),
                                    //         Spacer(),
                                    //         Icon(
                                    //           Icons.arrow_forward_ios,
                                    //           size: 16,
                                    //           color: color2,
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(
                                      height: 11,
                                    ),
                                    Center(
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.94,
                                          child: ElevatedBtn1(
                                              submitButton, "ADD PRODUCT")),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        "OUR PRODUCT",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                );
                            }
                          }),
                    ),
                    productList.length == 0
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Center(
                                child: Text("No Product Added."),
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 3,
                                    childAspectRatio:
                                        (orientation == Orientation.portrait)
                                            ? 0.78
                                            : 0.78,
                                    crossAxisCount: (orientation ==
                                            Orientation.portrait)
                                        ? 2
                                        : 4),
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return myProductWidget(productList, index);
                              },
                              childCount: productList.length,
                            ),
                          ),
                  ],
                ),
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

  void submitButton() {
    Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute(builder: (context) => AddProduct()));
  }

  Widget myProductWidget(List<Products> productList, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
            builder: (context) => ProductDetailPage(
                product_id: productList[index].id.toString())));
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            child: Container(
              width: 190,
              // color: appcolor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 130,
                    // width: 150,
                    decoration: BoxDecoration(
                      // color: appcolor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(13)),
                      // image: DecorationImage(
                      //     // image: NetworkImage(),
                      //     image: AssetImage("assets/audi.jpg"),
                      //     fit: BoxFit.fill),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: productList[index].product_image,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            productList[index].product_name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text("₹" + productList[index].product_price,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700)),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(CupertinoPageRoute(
                                          builder: (context) => EditProduct(
                                              product_id: productList[index]
                                                  .id
                                                  .toString(),
                                              category_id: productList[index]
                                                  .category_id
                                                  .toString())))
                                      .then(onGoBack);
                                },
                                child: Text(
                                  "Edit",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: color2,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              OutlinedButton(
                                onPressed: () {
                                  print("alert dialouge");
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Are You Sure?'),
                                          content: Text('Confirm to delete'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('NO'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                deleteProduct(productList[index]
                                                    .id
                                                    .toString());
                                                setState(() {
                                                  setState(() {
                                                    productList.removeAt(index);
                                                  });
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text('YES'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Text(
                                  "Delete",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: color2,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          )
                        ]),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> deleteProduct(pid) async {
    Map data = {
      'product_id': pid,
      'customer_id': prefs.getString("user_id"),
    };
    print(data);

    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/delete_product"), body: data);
    // print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Product Deleted'),
        ),
      );
      print("product  deleted");
    } else {
      print("product not deleted");
    }
  }

  @override
  bool get wantKeepAlive => true;
}
