import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/View/CreateStore/TrackOrder.dart';

import 'package:intl/intl.dart';
import 'package:awesome_loader/awesome_loader.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/StoreOrderDetail_model.dart';
import 'package:glocal_bizz/Model/Store_order_model.dart';
import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyOrdersPage extends StatefulWidget {
  MyOrdersPage({Key key}) : super(key: key);

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  var _listItems = <Widget>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  bool _isLoading = false;

  Future<OrdersDetailModel> orderDetails;
  Future<DeliveryAddressModel> addressDetails;

  @override
  void initState() {
    super.initState();
    _getorderList();
    // _loadItems();
  }

  Future<void> _getorderList() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "customer_id": prefs.getString("user_id"),
    };
    print(jsonEncode(data));
    var response =
        await http.post(Uri.parse(api_url + "/user_order_history"), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      setState(() {
        _isLoading = true;
      });

      get_orderlist(result).then((value) {
        setState(() {
          orderList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<StoreOrderModel> orderList = List<StoreOrderModel>();

  Future<List<StoreOrderModel>> get_orderlist(orderListsJson) async {
    var orderList = List<StoreOrderModel>();
    for (var orderListsJson in orderListsJson) {
      orderList.add(StoreOrderModel.fromJson(orderListsJson));
    }
    return orderList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFf8f8f8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("My Orders"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Container(
              child:
                  // Column(
                  //   children: [
                  //     _orderList(),
                  //   ],
                  // ),
                  AnimatedList(
                physics: BouncingScrollPhysics(),
                key: _listKey,
                padding: EdgeInsets.only(top: 10),
                initialItemCount: orderList.length,
                itemBuilder: (context, index, animation) {
                  return SlideTransition(
                      position: CurvedAnimation(
                        curve: Curves.decelerate,
                        parent: animation,
                      ).drive((Tween<Offset>(
                        begin: Offset(1, 0),
                        end: Offset(0, 0),
                      ))),
                      child: _orderList(orderList, index));
                },
              ),
            )
          : Loading(),
    );
  }

  Widget _orderList(List<StoreOrderModel> orderList, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 7, right: 7, top: 5),
      child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey[350], width: 0.8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: Row(
                  children: [
                    Text(
                      "Orderd at : " +
                          orderList[index].createdAt.substring(0, 10),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton(
                        icon: Icon(Icons.more_horiz),
                        onSelected: (value) {
                          switch (value) {
                            case 1:
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: const Text('Order Removed'),
                                ),
                              );
                              break;
                            case 2:
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => TrackOrderPage(
                                          orderid:
                                              orderList[index].id.toString(),
                                          orderNO: orderList[index]
                                              .orderNo
                                              .toString())));
                              break;

                            default:
                          }
                        },
                        itemBuilder: (context) => [
                              // PopupMenuItem(
                              //   child: GestureDetector(child: Text("Remove"),onTap: (){
                              //      setState(() {
                              //                               Ad.removeAt(index);
                              //                             });
                              //   },),
                              //   value: 1,
                              // ),
                              PopupMenuItem(
                                child: Text("Track Order"),
                                value: 2,
                              ),
                            ]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order ID",
                              style: TextStyle(
                                  color: color2,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                            Text(
                              "Payment Mode",
                              style: TextStyle(
                                  color: color2,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                            Text(
                              "Total Amount",
                              style: TextStyle(
                                  color: color2,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                            Text(
                              "Date",
                              style: TextStyle(
                                  color: color2,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                          ],
                        )),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ":",
                            style: TextStyle(
                                color: color2,
                                fontWeight: FontWeight.w500,
                                height: 1.5),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: color2,
                                fontWeight: FontWeight.w500,
                                height: 1.5),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: color2,
                                fontWeight: FontWeight.w500,
                                height: 1.5),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: color2,
                                fontWeight: FontWeight.w500,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderList[index].orderNo,
                              style: TextStyle(
                                  color: color2,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                            Text(
                              orderList[index].payment_method == 1
                                  ? "Cash On Delivery"
                                  : "Online Payment",
                              style: TextStyle(
                                  color: color2,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                            Text(
                              orderList[index].totalAmount.toString(),
                              style: TextStyle(
                                  color: color2,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                            Text(
                              orderList[index].createdAt.substring(0, 10),
                              style: TextStyle(
                                  color: color2,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                          ],
                        )),
                    // Expanded(child: SizedBox())
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
