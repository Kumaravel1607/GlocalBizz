import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Google%20ADs/AdMob_Helper.dart';
import 'package:glocal_bizz/Model/detail_model.dart';
import 'package:glocal_bizz/View/AdsUserPage.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevatedButton.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Chatting/NewChatScreen.dart';

class AdsDetailPage extends StatefulWidget {
  final String ads_id;
  AdsDetailPage({Key key, this.ads_id}) : super(key: key);

  @override
  _AdsDetailPageState createState() => _AdsDetailPageState();
}

class _AdsDetailPageState extends State<AdsDetailPage> {
  List wordsL = [];
  List<String> savedwords = List<String>();
  bool _isLoading = true;

  String adsID;
  String receiverId;
  String user_ID;
  String poster_Id;
  int _current = 0;
  String userId;
  String userName;

  //  PageController _pageController = PageController(initialPage: 1);
  PageController _pageController;
  final TextEditingController commend = new TextEditingController();
  SharedPreferences prefs;
  Future<AdsDetail> _adsdetail;
  // Future<ExtraDetails> _extradetail;
  String phone;
  String brandName;
  String modelName;
  String year;

  @override
  void initState() {
    super.initState();
    // _extradetail = extra_details();
    _adsdetail = ads_detail();
    image_api();
  }

  void refresh() {
    setState(() {
      _pageController = PageController(initialPage: _current);
    });
  }

  Future<AdsDetail> ads_detail() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'id': widget.ads_id,
      'customer_id': prefs.getString("user_id"),
    };
    print(data);

    var response =
        await http.post(Uri.parse(api_url + "/ads_detail"), body: data);
    // print(json.decode(response.body));
    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print("--------------NK-----------");
      print(jsonResponse);
      // poster_Id = jsonResponse['customer_id'].toString();
      adsID = jsonResponse['id'].toString();
      // // setState(() {
      receiverId = jsonResponse['customer_id'].toString();
      userId = prefs.getString("user_id");
      userName = jsonResponse['first_name'];
      setState(() {
        brandName = (jsonResponse['brand_name']);
        modelName = (jsonResponse['model']);
        year = (jsonResponse['registration_date']);
        // phone = (jsonResponse['contact_mobile']);
      });
      if (jsonResponse['contact_mobile'] != null ||
          jsonResponse['contact_mobile'] != "") {
        phone = jsonResponse['contact_mobile'];
      }

      return AdsDetail.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load post');
    }
  }

  // Future<ExtraDetails> extra_details() async {
  //   prefs = await SharedPreferences.getInstance();
  //   Map data = {
  //     'id': widget.ads_id,
  //     'customer_id': prefs.getString("user_id"),
  //   };
  //   print(data);

  //   var response =
  //       await http.post(Uri.parse(api_url + "/ads_detail"), body: data);
  //   // print(json.decode(response.body));
  //   var jsonResponse;
  //   if (response.statusCode == 200) {
  //     jsonResponse = (json.decode(response.body)['extra']);
  //     // print("--------------NK-----------");
  //     setState(() {
  //       brandName = (jsonResponse['brand_name']);
  //       modelName = (jsonResponse['model']);
  //       year = (jsonResponse['registration_date']);
  //     });
  //     return ExtraDetails.fromJson(jsonResponse);
  //   } else {
  //     throw Exception('Failed to load post');
  //   }
  // }

  Future<void> image_api() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'id': widget.ads_id,
      'customer_id': prefs.getString("user_id"),
    };
    var response =
        await http.post(Uri.parse(api_url + "/ads_detail"), body: data);

    if (response.statusCode == 200) {
      get_imageList(json.decode(response.body)['images']).then((value) {
        setState(() {
          imageList = value;
        });
      });
    }
  }

  List<AllImage> imageList = List<AllImage>();

  Future<List<AllImage>> get_imageList(imageListsJson) async {
    var imageLists = List<AllImage>();
    for (var imageListJson in imageListsJson) {
      imageLists.add(AllImage.fromJson(imageListJson));
    }
    return imageLists;
  }

  void reportAD(adsID, issue, cmnd) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "reported_by": prefs.getString("user_id"),
      "ads_id": adsID,
      "issuses_type": issue,
      "comments": cmnd,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/report_ads"), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      Navigator.of(context).pop();
      commend.clear();
      print(jsonResponse);
    } else {
      print("error");
    }
  }

  Widget extraDetails(value, AdsDetail data) {
    switch (value) {
      case "bike":
        return extraBikeDetail(data);
        break;

      case "cars":
        return extraCarDetail(data);
        break;

      case "sale-property":
      case "rent-property":
        return extraPropertyDetail(data);
        break;

      case "rent-shop":
      case "sale-shop":
        return extraShopDetail(data);
        break;

      case "lands-plots":
        return extraLandDetail(data);
        break;

      case "pg":
        return extraPGDetail(data);
        break;

      case "jobs":
        return jobsDetail(data);
        break;

      default:
        return SizedBox(
            // child: Text("Getting Result..."),
            );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<AdsDetail>(
          future: _adsdetail, // async work
          builder: (BuildContext context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Container(
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
                  )),
                );
              default:
                if (snapshot.hasError)
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Check internet Connection :('),
                      ElevatedButton(
                          onPressed: () {
                            _adsdetail = ads_detail();
                            image_api();
                          },
                          child: Text("Refresh")),
                    ],
                  ));
                else
                  phone = snapshot.data.contact_mobile != null
                      ? snapshot.data.contact_mobile
                      : "";
                return Stack(children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            new Container(
                              child: CarouselSlider.builder(
                                  options: CarouselOptions(
                                      height: 250,
                                      viewportFraction: 1.0,
                                      // aspectRatio: 1.0,
                                      autoPlay: false,
                                      enableInfiniteScroll: false,
                                      autoPlayInterval: Duration(seconds: 3),
                                      autoPlayCurve: Curves.easeInCubic,
                                      enlargeCenterPage: false,
                                      reverse: false,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _current = index;
                                          print("${_current}");
                                        });
                                      }),
                                  itemCount: imageList.length,
                                  itemBuilder: (context, index, int name) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              refresh();
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        photoView()));
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 250,
                                                padding: EdgeInsets.all(0),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                // height: MediaQuery.of(context).size.height,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 0.5),
                                                decoration: BoxDecoration(
                                                  color: white,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        imageList[index]
                                                            .image_name),
                                                    // fit: BoxFit.contain,
                                                  ),
                                                  shape: BoxShape.rectangle,
                                                ),
                                              ),
                                              Container(
                                                height: 250,
                                                color: const Color(0xBD0E3311)
                                                    .withOpacity(0.2),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }),
                            ),
                            Container(
                                // alignment: Alignment.topRight,
                                // width: MediaQuery.of(context).size.width,
                                // color: const Color(0xFF0E3311).withOpacity(0.5),
                                height: 250,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FloatingActionButton(
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
                                    Spacer(),
                                    imageList.length != 1
                                        ? Center(
                                            child: new DotsIndicator(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              dotsCount: imageList.length,
                                              position: _current.toDouble(),
                                              decorator: DotsDecorator(
                                                color: Colors.grey[
                                                    200], // Inactive color
                                                activeColor: primaryColor,
                                                size: const Size.square(7.0),
                                                activeSize:
                                                    const Size(10.0, 8.0),
                                                activeShape:
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0)),
                                              ),
                                              // decorator: DotsDecorator(
                                              //   color: Colors.grey[300], // Inactive color
                                              //   activeColor: appcolor,
                                              // ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                )),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              adDetails(snapshot.data),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  receiverId == userId
                      ? SizedBox()
                      : Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: button(),
                        ),
                ]);
            }
          },
        ),
      ),
    );
  }

  Widget adDetails(AdsDetail data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          data.ads_name,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 3,
        ),
        brandName != null || brandName != ""
            ? Row(
                children: [
                  Text(
                    brandName != null ? "Brand: " : "",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 15,
                        color: color2,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    brandName != null ? brandName : "",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500),
                  ),
                  Flexible(
                    child: Text(
                      modelName != null
                          ? "  ( " + modelName + " " + year + " )"
                          : "",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: 7,
        ),
        Row(
          children: [
            data.salary_from == null
                ? Text(
                    data.ads_price,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 20,
                        color: primaryColor,
                        fontWeight: FontWeight.w600),
                  )
                : Text(
                    data.salary_from + " to " + data.salary_to,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 20,
                        color: primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
            Spacer(),
            data.price_type == null
                ? SizedBox()
                : Text(
                    data.price_type == "1" ? "Negotiable" : "Fixed",
                    textAlign: TextAlign.start,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 20,
            ),
            Text(
              data.city_name,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            Spacer(),
            Text(
              data.posted_at,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        data.service_type == null
            ? SizedBox()
            : Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  data.service_type == "1"
                      ? "NEW"
                      : data.service_type == "2"
                          ? "OLD"
                          : "SERVICES",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
              ),
        Divider(
          color: Colors.grey,
          thickness: .5,
        ),
        SizedBox(
          height: 10,
        ),
        Container(child: extraDetails(data.ads_type, data)),
        // SizedBox(
        //   height: 10,
        // ),
        Text(
          "Description",
          style: TextStyle(color: primaryColor, fontSize: 16),
        ),
        SizedBox(
          height: 8,
        ),
        data.ads_description != null ? Text(data.ads_description) : SizedBox(),
        SizedBox(
          height: 15,
        ),
        Divider(
          color: Colors.grey,
          thickness: .5,
          height: 0.5,
        ),

        // SizedBox(
        //   height: 15,
        // ),
        // Row(
        //   children: [
        //     Text(
        //       "Door Step services: ",
        //       style: TextStyle(
        //           fontSize: 16,
        //           fontWeight: FontWeight.w500),
        //     ),
        //     Text(
        //       snapshot.data.door_step == "0"
        //           ? "NO"
        //           : "YES",
        //       style: TextStyle(
        //           color: Colors.grey, fontSize: 14),
        //     ),
        //   ],
        // ),
        // SizedBox(
        //   height: 15,
        // ),
        // Divider(
        //   color: Colors.grey,
        //   thickness: .5,
        //   height: 0.5,
        // ),
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Text(
              "AD ID: ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              data.ids.toString(),
              style: TextStyle(color: primaryColor, fontSize: 14),
            ),
            Spacer(),
            GestureDetector(
              child: Text(
                "REPORT THIS AD",
                style: TextStyle(color: primaryColor, fontSize: 14),
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
                        TimeValue(2, "Duplicate ad"),
                        TimeValue(3, "Product already sold"),
                        TimeValue(4, "Other"),
                      ];
                      return AlertDialog(
                        content: Container(
                          width: 400,
                          child: Stack(overflow: Overflow.visible, children: <
                              Widget>[
                            Positioned(
                              right: -40.0,
                              top: -40.0,
                              child: InkResponse(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: CircleAvatar(
                                  child: Icon(Icons.close),
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Item report"),
                                    Container(
                                      child: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: _buttonOptions
                                              .map((timeValue) => RadioListTile(
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                    groupValue: selectedRadio,
                                                    title:
                                                        Text(timeValue._value),
                                                    value: timeValue._key,
                                                    // value: timeValue._key,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        debugPrint(
                                                            'VAL = $val');
                                                        selectedRadio = val;
                                                        commendType =
                                                            timeValue._value;
                                                        debugPrint(
                                                            timeValue._value);
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
                                      onSaved: (String value) {},
                                      controller: commend,
                                      obscureText: false,
                                      onTap: () {},
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: black,
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      decoration: textDecoration(
                                          'Commend', 'Write your command'),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        TextButton(
                                          child: Text('Send'),
                                          onPressed: () {
                                            reportAD(data.ids.toString(),
                                                commendType, commend.text);
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
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          color: Colors.grey,
          thickness: .5,
        ),
        // Align(
        //   alignment: Alignment.topCenter,
        //   child: Container(
        //     width: AdmobHelper.getBannerAd().size.width.toDouble(),
        //     height: AdmobHelper.getBannerAd().size.height.toDouble(),
        //     child: AdWidget(ad: AdmobHelper.getBannerAd()..load()),
        //   ),
        // ),
        profile(data),
        divider(),
        SizedBox(
          height: 70,
        ),
      ],
    );
  }

  Widget profile(AdsDetail data) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Posted By",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    height: 70,
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      radius: 29,
                      // foregroundColor: appcolor,
                      backgroundColor: Colors.grey[200],
                      // backgroundImage: AssetImage('assets/user.png'),
                      backgroundImage: data.profile_image != null
                          ? NetworkImage(data.profile_image)
                          : AssetImage('assets/user.png'),
                    ),
                  )),
              Expanded(
                  flex: 6,
                  child: Container(
                      height: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.first_name,
                            style: TextStyle(
                                color: black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Member Since " + data.join_year,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          InkWell(
                            child: Text(
                              "See Profile",
                              style:
                                  TextStyle(color: primaryColor, fontSize: 14),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (BuildContext context) =>
                                          AdsUserProfilePage(
                                            aduserID: data.customer_id,
                                            aduserImage: data.profile_image,
                                            aduserName: data.first_name,
                                            aduserJoin: data.join_year,
                                          )));
                            },
                          )
                        ],
                      ))),
            ],
          ),
        ],
      ),
    );
  }

  Widget button() {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 10),
        height: 60,
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedBtn(
                chatBtn,
                "Chat",
                Icon(
                  Icons.chat,
                )),
            Spacer(),
            phone != null
                ? ElevatedBtn(
                    _makePhoneCall,
                    "Make Call",
                    Icon(
                      Icons.call,
                    ))
                : SizedBox(),
          ],
        ));
  }

  void selectBtn() {
    // Navigator.push(context, MaterialPageRoute(builder: (_) => OtpPage()));
  }

  void chatBtn() {
    // _showMessage();
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (BuildContext context) => ChatScreen(
              adsId: adsID,
              user_name: userName,
              sendID: userId,
              receiveID: receiverId,
            )));
  }

  Future<void> _makePhoneCall() async {
    // const url = 'tel:9876543210';
    if (await canLaunch('tel:' + phone)) {
      await launch('tel:' + phone);
    } else {
      throw 'Could not launch $phone';
    }
  }

  Widget photoView() => Container(
        child: Stack(children: [
          PhotoViewGallery.builder(
            itemCount: imageList.length,
            pageController: _pageController,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageList[index].image_name),
                // imageProvider: AssetImage("assets/audi.jpg"),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            onPageChanged: (int index) {
              setState(() {
                _current = index;
                print(_current);
              });
            },
            backgroundDecoration: BoxDecoration(
              color: black,
            ),
          ),
          Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 100, right: 25),
              child: FloatingActionButton(
                elevation: 10,
                mini: true,
                foregroundColor: black,
                backgroundColor: white,
                child: Icon(
                  Icons.close,
                  color: black,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
        ]),
      );

  Widget extraBikeDetail(AdsDetail data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Details",
          style: TextStyle(
              color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("BRAND"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("MODEL"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("ENGINE SIZE"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("KM DRIVEN"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("REGISTER YEAR"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("NO OF OWNER"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("SELLER BY"),
                    ),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.brand_name),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.model),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.engine_size),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.km_driven),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.registration_date),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.no_of_owner),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.seller_by),
                    ),
                  ],
                )),
          ],
        ),
        Divider(
          color: Colors.grey,
          thickness: .5,
        ),
      ],
    );
  }

  Widget extraCarDetail(AdsDetail data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.ev_station_outlined,
                        size: 20,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Flexible(child: Text(data.fuel_type)),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 20,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Flexible(child: Text(data.km_driven)),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.grain_outlined,
                        size: 20,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Flexible(
                          child: Text(data.transmission != null
                              ? data.transmission
                              : "Manual")),
                    ],
                  )),
            ],
          ),
          Divider(
            color: Colors.grey,
            thickness: .5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 18,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Flexible(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Owner",
                                style: TextStyle(
                                  fontSize: 11,
                                )),
                            Text(
                              data.no_of_owner,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        )),
                      ],
                    )),
                Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          size: 18,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Flexible(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SELLER BY",
                                style: TextStyle(
                                  fontSize: 11,
                                )),
                            Text(
                              data.seller_by,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        )),
                      ],
                    )),
                Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 18,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Flexible(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ENGINE SIZE",
                                style: TextStyle(
                                  fontSize: 11,
                                )),
                            Text(
                              data.engine_size,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        )),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget extraPropertyDetail(AdsDetail data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Details",
          style: TextStyle(
              color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("TYPE"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("BEDROOMS"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("FLOOR"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("FURNISHING"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("CONSTRUCTION STATUS"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("LISTED BY"),
                    ),
                    // data.rent_monthly != null
                    //     ? Padding(
                    //         padding:
                    //             const EdgeInsets.symmetric(vertical: 5),
                    //         child: Text("MONTHLY RENT"),
                    //       )
                    //     : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("CAR PARKING"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("SUPER BUILDUP AREA Sq Ft"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("CARPET AREA Sq Ft"),
                    ),
                    data.form_whom != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text("FOR WHOM"),
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("FACING"),
                    ),
                  ],
                )),
            SizedBox(
              width: 15,
            ),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.type_of_property),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.bedrooms_type),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.floor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.furnished),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.construction_status),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.listed_by),
                    ),
                    // data.rent_monthly != null
                    //     ? Padding(
                    //         padding:
                    //             const EdgeInsets.symmetric(vertical: 7),
                    //         child: Text(data.rent_monthly),
                    //       )
                    //     : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.car_parking_space),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.super_buildup_area_sq_ft),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.carpet_area_sq_ft),
                    ),
                    data.form_whom != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Text(data.form_whom),
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.facing),
                    ),
                  ],
                )),
          ],
        ),
        Divider(
          color: Colors.grey,
          thickness: .5,
        ),
      ],
    );
  }

  Widget extraShopDetail([AdsDetail data]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Details",
          style: TextStyle(
              color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("FURNISHED"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("LISTED BY"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("SUPER BUILDUP AREA (FT)"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("CARPET AREA (FT)"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("WASHROOMS"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("CAR PARKING"),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 5),
                    //   child: Text("RENT MONTHLY"),
                    // ),
                    data.construction_status != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text("CONTRUCTION STATUS"),
                          )
                        : SizedBox(),
                  ],
                )),
            SizedBox(
              width: 13,
            ),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.furnished),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.listed_by),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.super_buildup_area_sq_ft),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.carpet_area_sq_ft),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.washrooms),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(data.car_parking_space),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 7),
                    //   child: Text(data.rent_monthly != null
                    //       ? data.rent_monthly
                    //       : "-"),
                    // ),
                    data.construction_status != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Text(data.construction_status != null
                                ? data.construction_status
                                : "-"),
                          )
                        : SizedBox(),
                  ],
                )),
          ],
        ),
        Divider(
          color: Colors.grey,
          thickness: .5,
        ),
      ],
    );
  }

  Widget extraLandDetail(AdsDetail data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Details",
          style: TextStyle(
              color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("TYPE"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("LISTED BY"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("PLOT AREA"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("LENGTH"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("BREADTH"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("FACING"),
                    ),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.property_type),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.listed_by),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.plot_area),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.length),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.breadth),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.facing),
                    ),
                  ],
                )),
          ],
        ),
        Divider(
          color: Colors.grey,
          thickness: .5,
        ),
      ],
    );
  }

  Widget extraPGDetail(AdsDetail data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Details",
          style: TextStyle(
              color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("SUBTYPE"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("LISTED BY"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("FURNISHED"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("CAR PARKING"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("MEALS INCLUDED"),
                    ),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.pg_sub_type),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.listed_by),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.furnished),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.car_parking_space),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.meal_included),
                    ),
                  ],
                )),
          ],
        ),
        Divider(
          color: Colors.grey,
          thickness: .5,
        ),
      ],
    );
  }

  Widget jobsDetail(AdsDetail data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Details",
          style: TextStyle(
              color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    data.company_name != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text("COMPANY NAME"),
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("POSITION TYPE"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("QUALIFICATION"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("SALARY PERIOD"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("SALARY FROM"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("SALARY TO"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("ENGLISH REQUIRED"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("EXPERIENCE"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("GENDER"),
                    ),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    data.company_name != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(data.company_name),
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.job_type),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.qualification),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(data.salary_period),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        data.salary_from,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        data.salary_to,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        data.english,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        data.experience != null ? data.experience : "-",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        data.gender,
                      ),
                    ),
                  ],
                )),
          ],
        ),
        Divider(
          color: Colors.grey,
          thickness: .5,
        ),
      ],
    );
  }
}

class TimeValue {
  final int _key;
  final String _value;
  TimeValue(this._key, this._value);
}
