import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/package_model.dart';
import 'package:glocal_bizz/Model/profile_model.dart';
import 'package:glocal_bizz/View/Add%20Package/CartPage.dart';
import 'package:glocal_bizz/View/Add%20Package/PaymentCheckout.dart';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelectPackages extends StatefulWidget {
  final String pkg_type;
  final String title;
  final String category_id;
  final String ads_id;
  SelectPackages(
      {Key key, this.pkg_type, this.title, this.category_id, this.ads_id})
      : super(key: key);

  @override
  _SelectPackagesState createState() => _SelectPackagesState();
}

class _SelectPackagesState extends State<SelectPackages> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _payLoading = false;

  String userName;
  String userEmail;
  String userMobile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    package_list();
    getUserDetail();
  }

  Future<UserDetails> getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
    };
    print(data);
    var response;
    response = await http.post(Uri.parse(api_url + "/customer"), body: data);
    print(response.body.toString());

    if (response.statusCode == 200) {
      var userDetail = (json.decode(response.body));
      print(userDetail);
      userName = (userDetail['first_name']);
      userEmail = (userDetail['email']);
      if (userDetail['mobile'] != null || userDetail['mobile'] != "") {
        userMobile = userDetail['mobile'];
      } else {
        userMobile = "";
      }

      return UserDetails.fromJson(userDetail);
    } else {
      throw Exception('Failed to load post');
    }
  }

  void package_list() async {
    Map data = {
      'category_id': widget.category_id,
      'package_type': widget.pkg_type,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/get_package"), body: data);
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print("-----NK-----");
      print(result);
      setState(() {
        _isLoading = true;
      });

      get_packageList(result).then((value) {
        setState(() {
          packageList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("error");
    }
  }

  List<GetPackages> packageList = List<GetPackages>();

  Future<List<GetPackages>> get_packageList(packagesJson) async {
    var packages = List<GetPackages>();
    for (var packageJson in packagesJson) {
      packages.add(GetPackages.fromJson(packageJson));
    }
    return packages;
  }

  void payment_create(
      String id, String amount, String discount, String total_amount) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'package_id': id,
      'package_type': widget.pkg_type,
      'category_id': widget.category_id,
      'customer_id': sharedPreferences.getString("user_id"),
      'amount': amount,
      'discount': discount,
      'total_amount': total_amount,
      if (widget.pkg_type == "1") 'ads_id': widget.ads_id,
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/make_order"), body: data);

    if (response.statusCode == 200) {
      setState(() {
        _payLoading = false;
      });
      var result = (json.decode(response.body));
      print(result);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Processing...'),
        ),
      );

      Navigator.of(context, rootNavigator: true)
          .pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => CheckOut(
                    orderId: result['order_id'].toString(),
                    amount: result['total_amount'],
                    name: userName,
                    mobile: userMobile,
                    email: userEmail,
                    description: "ADs Purchasing.",
                  )));

      print("SUCCESS CREATE PAYMENT");
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Failed!  Try again..'),
        ),
      );
      setState(() {
        _payLoading = false;
      });
      print("ERROR CREATE PAYMENT");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: primaryColor,
        title: Text(widget.title, style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _isLoading
              ? Container(
                  child: new ListView.builder(
                      shrinkWrap: false,
                      scrollDirection: Axis.vertical,
                      itemCount: packageList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: listOfPackages(packageList, index),
                        );
                      }),
                )
              : Center(
                  child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
                )),
          _payLoading ? FullScreenLoading() : SizedBox(),
        ],
      ),
    );
  }

  Widget listOfPackages(List<GetPackages> packageList, int index) {
    return InkWell(
      onTap: () {
        print("NK");
      },
      child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 100,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[350], width: 0.6),
              borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            Expanded(
              flex: 2,
              child: Text(
                "₹" + packageList[index].package_amount.toString(),
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600),
              ),
            ),
            VerticalDivider(
              color: Colors.grey[350],
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    packageList[index].package_name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: color2,
                        fontSize: 13,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.pkg_type == "2"
                        ? "Ads " + packageList[index].package_count.toString()
                        : "Validity " +
                            packageList[index].package_days.toString() +
                            " Days",
                    // : "Reach up to 10 times more buyesrs",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 9,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 7,
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  _showMessage(
                    packageList[index].id.toString(),
                    packageList[index].package_amount.toString(),
                    "0",
                    packageList[index].package_amount.toString(),
                    packageList[index].package_name.toString(),
                    packageList[index].package_count.toString(),
                    packageList[index].package_days.toString(),
                  );
                },
                child: Text(
                  "Buy",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    primary: primaryColor,
                    // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ])),
    );
  }

  // Widget button() {
  //   return ElevatedButton(
  //     onPressed: () {
  //       _showMessage();
  //       payment_create();
  //     },
  //     child: Text(
  //       "Buy",
  //       style: TextStyle(
  //           fontSize: 16,
  //           fontFamily: "Poppins",
  //           fontWeight: FontWeight.w600,
  //           color: Colors.white),
  //     ),
  //     style: ElevatedButton.styleFrom(
  //         elevation: 7,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         primary: primaryColor,
  //         // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
  //         textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  //   ); //Container
  // }

  void _showMessage(
      _id, _amount, _discount, _totalamount, pkg_name, pkg_count, pkg_days) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(35.0),
                topRight: const Radius.circular(35.0)),
          ),
          context: context,
          builder: (builder) {
            return new Container(
              height: 230.0,
              decoration: new BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0))),
              child: new Container(
                  padding: EdgeInsets.all(15),
                  // decoration: new BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: new BorderRadius.only(
                  //         topLeft: const Radius.circular(25.0),
                  //         topRight: const Radius.circular(25.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pkg_name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            // color: color2,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "Ads " + pkg_count,
                        // "Reach up to 10 times more buyers",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 10,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _payLoading = true;
                              });
                              payment_create(
                                  _id, _amount, _discount, _totalamount);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Pay  ₹ " + _amount,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                primary: color2,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          )),
                    ],
                  )),
            );
          });
    });
  }
}
