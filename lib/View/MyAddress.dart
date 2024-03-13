import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/addressList_model.dart';
import 'package:glocal_bizz/Model/profile_model.dart';
import 'package:glocal_bizz/View/Add%20Package/PaymentCheckout.dart';
import 'package:glocal_bizz/View/CreateStore/Add_address.dart';
import 'package:glocal_bizz/View/CreateStore/EditAddress.dart';
import 'package:glocal_bizz/View/CreateStore/OrderSuccess.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class MyAddressPage extends StatefulWidget {
  //  final String name;
  // MyAddressPage({Key key, this.name}) : super(key: key);
  @override
  MyAddressPageState createState() => new MyAddressPageState();
}

class MyAddressPageState extends State<MyAddressPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  bool selectAddress = false;
  bool _isLoading = false;
  int selectedAddress;
  int payOption;

  String userName;
  String userEmail;
  String userMobile;

  // Timer _timer;
  @override
  void initState() {
    super.initState();
    _getAddressList();
    getUserDetail();
  }

  void select_address() {
    Future.delayed(Duration(seconds: 1), () {
      // Navigator.of(context).push(
      //     MaterialPageRoute(builder: (BuildContext context) => ShippingPage()));
    });
  }

  Future<void> _getAddressList() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "customer_id": prefs.getString("user_id"),
    };
    print(jsonEncode(data));
    var response =
        await http.post(Uri.parse(api_url + "/customer_address"), body: data);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      setState(() {
        _isLoading = true;
      });

      get_addresslist(result).then((value) {
        setState(() {
          addressList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
  }

  List<AddressModel> addressList = List<AddressModel>();

  Future<List<AddressModel>> get_addresslist(addressLisJson) async {
    var addressList = List<AddressModel>();
    for (var addressListsJson in addressLisJson) {
      addressList.add(AddressModel.fromJson(addressListsJson));
    }
    return addressList;
  }

  delete_address(addressID) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      'address_id': addressID,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + '/delete_address'), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Address deleted.'),
        ),
      );
    } else {
      // setState(() {
      //   _isLoading = false;
      // });
    }
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

  make_order() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      'address_id': selectedAddress.toString(),
      'payment_method': payOption.toString(),
    };
    print(data);
    var result;
    var response =
        await http.post(Uri.parse(api_url + '/store_order'), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      result = json.decode(response.body);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Processing...'),
        ),
      );
      if (payOption == 1) {
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => OrderSuccess()),
        );
      } else {
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
              builder: (BuildContext context) => CheckOut(
                    orderId: result['order_id'].toString(),
                    amount: result['total_amount'],
                    name: userName,
                    mobile: userMobile,
                    email: userEmail,
                    description: "Purchasing products in store.",
                    storeOrder: 1,
                  )),
        );
      }
    } else {
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  FutureOr onGoBack(dynamic value) {
    _getAddressList();
    print("Back loading");
    setState(() {});
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
    return new Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          backgroundColor: primaryColor,
          // elevation: 0,
          iconTheme: new IconThemeData(
            color: white,
          ),
          title: Text("My Address",
              style: TextStyle(
                color: white,
              )),
          centerTitle: true,
        ),
        body: _isLoading
            ? Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Add_AddressPage()),
                            ).then(onGoBack);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: green,
                                // border: Border.all(color: color2, width: 1.5),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "ADD ADDRESS",
                                  style: TextStyle(
                                      color: white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Container(
                            child: address_list(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Loading());
  }

  Widget address_list() {
    return new ListView.builder(
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        itemCount: addressList.length,
        itemBuilder: (context, index) {
          // int quantity;
          int addressCount = index + 1;
          // quantity = cartList[index].quantity;
          return Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: 30,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "MY CURRENT ADDRESS",
                            style: TextStyle(
                                color: white,
                                fontFamily: "Poppins",
                                // fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          PopupMenuButton(
                              icon: Icon(
                                Icons.more_horiz,
                                color: white,
                              ),
                              onSelected: (value) async {
                                print("---------NK-----------");
                                switch (value) {
                                  case 1:
                                    Route route = MaterialPageRoute(
                                        builder: (context) => Edit_AddressPage(
                                            addressID: addressList[index]
                                                .id
                                                .toString()));
                                    Navigator.push(context, route)
                                        .then(onGoBack);
                                    break;
                                  case 2:
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Text(
                                                "Confirm to Delete Address"),
                                            //title: Text(),
                                            actions: <Widget>[
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "No",
                                                  style:
                                                      TextStyle(color: color2),
                                                ),
                                              ),
                                              OutlinedButton(
                                                onPressed: () {
                                                  print("delete");
                                                  delete_address(
                                                      addressList[index]
                                                          .id
                                                          .toString());
                                                  setState(() {
                                                    addressList.removeAt(index);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Confirm",
                                                  style:
                                                      TextStyle(color: color2),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                    break;
                                  default:
                                }
                              },
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Text("EDIT"),
                                      value: 1,
                                    ),
                                    PopupMenuItem(
                                      child: Text("DELETE"),
                                      value: 2,
                                    ),
                                  ]),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 8, 15, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                // color: color2,
                                alignment: Alignment.topCenter,
                                // child: Icon(Icons.radio_button_unchecked),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    // border: Border.all(width: 2),
                                    shape: BoxShape.circle,
                                    color: green,
                                  ),
                                  child: Center(
                                      child: Text(
                                    addressCount.toString(),
                                    style: TextStyle(
                                        color: white,
                                        fontSize: 12.3,
                                        fontWeight: FontWeight.w600),
                                  )),
                                ),
                                // Radio(
                                //   value: addressList[index].id,
                                //   groupValue: selectedAddress,
                                //   activeColor: primaryColor,
                                //   onChanged: (value) {
                                //     setState(() {
                                //       selectedAddress = value;
                                //       print(selectedAddress);
                                //     });
                                //   },
                                // ),
                              )),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                              flex: 8,
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      addressList[index].addressType == 1
                                          ? "Home Address"
                                          : "Office Address",
                                      style: TextStyle(
                                          color: color2,
                                          fontFamily: "Poppins",
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      addressList[index].firstName +
                                          " " +
                                          addressList[index].lastName,
                                      style: TextStyle(
                                        color: color2,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                    Text(
                                      addressList[index].address1,
                                      style: TextStyle(color: color2),
                                    ),
                                    Text(
                                      addressList[index].city,
                                      style: TextStyle(
                                        color: color2,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                    Text(
                                      addressList[index].pincode,
                                      style: TextStyle(
                                        color: color2,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}
