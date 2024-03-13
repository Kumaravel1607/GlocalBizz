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

class OrderHistory extends StatefulWidget {
  OrderHistory({Key key}) : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  var _listItems = <Widget>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  bool _isLoading = false;
  bool _bottomSheetLoading = false;
  String productOrderID;
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
      "store_id": prefs.getString("store_id"),
    };
    print(prefs.getString("store_id"));
    print(jsonEncode(data));
    var response = await http.post(Uri.parse(api_url + "/store_order_history"),
        body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print(result);

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

  Future<void> details(orderID) async {
    Map data = {
      "order_id": orderID,
    };
    print(jsonEncode(data));
    final response =
        await http.post(Uri.parse(api_url + "/store_order_detail"), body: data);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print("---------NK---------------");
      print(jsonResponse);
      get_productlist(jsonResponse['products']).then((value) {
        setState(() {
          productList = value;
        });
      });
      setState(() {
        productOrderID = orderID;
        orderDetails = fetchOrderDetail(jsonResponse);
        addressDetails = fetchAddressDetail(jsonResponse);
        _bottomSheetLoading = false;
      });
      _orderDetails();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<OrdersDetailModel> fetchOrderDetail(jsonResponse) async {
    return OrdersDetailModel.fromJson(jsonResponse['order']);
  }

  Future<DeliveryAddressModel> fetchAddressDetail(jsonResponse) async {
    return DeliveryAddressModel.fromJson(jsonResponse['address']);
  }

  List<OrderedProductModel> productList = List<OrderedProductModel>();

  Future<List<OrderedProductModel>> get_productlist(productListsJson) async {
    var productList = List<OrderedProductModel>();
    for (var productListsJson in productListsJson) {
      productList.add(OrderedProductModel.fromJson(productListsJson));
    }
    return productList;
  }

  Future<void> _updateOrder(orderID, deliveryStatus) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "order_id": orderID,
      "delivery_status": deliveryStatus,
      "customer_id": prefs.getString("user_id"),
    };
    print(jsonEncode(data));
    var response =
        await http.post(Uri.parse(api_url + "/store_order_status"), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print(result);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blue.shade50,
      // appBar: AppBar(
      //   backgroundColor: primaryColor,
      //   title: Text("Order History"),
      //   centerTitle: true,
      // ),
      body: _isLoading
          ? Stack(
              children: [
                orderList.isNotEmpty
                    ? Container(
                        child:
                            // Column(
                            //   children: [
                            //     _orderList(),
                            //   ],
                            // ),
                            AnimatedList(
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
                    : Container(
                        child: Center(
                          child: Text(
                            "No Orders Found !!",
                            style: TextStyle(
                                color: color2, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                _bottomSheetLoading
                    ? Container(
                        alignment: Alignment.center,
                        color: const Color(0xFF0E3311).withOpacity(0.23),
                        child: Center(
                            child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(color2),
                        )),
                      )
                    : SizedBox(),
              ],
            )
          : Loading(),
    );
  }

  // void _unloadItems() {
  //   var future = Future(() {});
  //   for (var i = _listItems.length - 1; i >= 0; i--) {
  //     future = future.then((_) {
  //       return Future.delayed(Duration(milliseconds: 100), () {
  //         final deletedItem = _listItems.removeAt(i);
  //         _listKey.currentState.removeItem(i,
  //             (BuildContext context, Animation<double> animation) {
  //           return SlideTransition(
  //             position: CurvedAnimation(
  //               curve: Curves.easeOut,
  //               parent: animation,
  //             ).drive((Tween<Offset>(
  //               begin: Offset(1, 0),
  //               end: Offset(0, 0),
  //             ))),
  //             child: deletedItem,
  //           );
  //         });
  //       });
  //     });
  //   }
  // }

  void _loadItems() {
    // fetching data from web api, local db...
    final fetchedList = [
      // _orderList(),
      // _orderList(),
      // _orderList(),
      // _orderList()
    ];

    var future = Future(() {});
    for (var i = 0; i < fetchedList.length; i++) {
      future = future.then((_) {
        return Future.delayed(Duration(milliseconds: 100), () {
          _listItems.add(fetchedList[i]);
          _listKey.currentState.insertItem(i);
        });
      });
    }
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
                          print("---------NK-----------");
                          switch (value) {
                            case 1:
                              _updateOrder(orderList[index].id.toString(),
                                  value.toString());
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: const Text('Order Accepted'),
                                ),
                              );
                              break;
                            case 2:
                              _updateOrder(orderList[index].id.toString(),
                                  value.toString());
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: const Text('Order Packed'),
                                ),
                              );
                              break;
                            case 3:
                              _updateOrder(orderList[index].id.toString(),
                                  value.toString());
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: const Text('Out For Delivery'),
                                ),
                              );
                              break;
                            case 4:
                              _updateOrder(orderList[index].id.toString(),
                                  value.toString());
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: const Text('Delivered'),
                                ),
                              );
                              break;
                            case 5:
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => TrackOrderPage(
                                          orderid:
                                              orderList[index].id.toString(),
                                          orderNO: orderList[index]
                                              .orderNo
                                              .toString())));
                              // _scaffoldKey.currentState.showSnackBar(
                              //   SnackBar(
                              //     content: const Text('Track Order'),
                              //   ),
                              // );
                              break;
                            case 6:
                              setState(() {
                                _bottomSheetLoading = true;
                                details(orderList[index].id.toString());
                              });
                              // _orderDetails();
                              break;
                            default:
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text("Accept"),
                                value: 1,
                              ),
                              PopupMenuItem(
                                child: Text("Packed"),
                                value: 2,
                              ),
                              PopupMenuItem(
                                child: Text("Out For Delivery"),
                                value: 3,
                              ),
                              PopupMenuItem(
                                child: Text("Delivered"),
                                value: 4,
                              ),
                              PopupMenuItem(
                                child: Text("Track Order"),
                                value: 5,
                              ),
                              PopupMenuItem(
                                child: Text("View Detail"),
                                value: 6,
                              ),
                            ]),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _bottomSheetLoading = true;
                    details(orderList[index].id.toString());
                  });
                  // _orderDetails();
                },
                child: Padding(
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
              ),
            ],
          )),
    );
  }

  void _orderDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(35.0),
                topRight: const Radius.circular(35.0)),
          ),
          context: context,
          builder: (builder) {
            return StatefulBuilder(builder: (BuildContext context,
                StateSetter setState /*You can rename this!*/) {
              return SafeArea(
                child: new Container(
                  // height: 400.0,
                  decoration: new BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          topRight: const Radius.circular(30.0))),
                  child: new Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          FutureBuilder<OrdersDetailModel>(
                            future: orderDetails,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order Details :",
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
                                      "Order ID : " + snapshot.data.orderNo,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      // "Payment mode : " +
                                      snapshot.data.paymentMethod == 1
                                          ? "Payment mode : Cash On Delivery"
                                          : "Online Payment",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "Total Amount : " + snapshot.data.amount,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "Order at : " +
                                          snapshot.data.createdAt
                                              .substring(1, 10),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                );
                              }

                              // By default, show a loading spinner.
                              return CircularProgressIndicator();
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          FutureBuilder<DeliveryAddressModel>(
                            future: addressDetails,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Address Details :",
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
                                      "Name : " +
                                          snapshot.data.firstName +
                                          " " +
                                          snapshot.data.lastName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "Address : " + snapshot.data.address1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "Landmark : " + snapshot.data.landmark,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "City : " + snapshot.data.city,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "Contact No : " + snapshot.data.mobileNo,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                );
                              }

                              // By default, show a loading spinner.
                              return Text(
                                "Loading ...",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    // color: color2,
                                    fontSize: 16,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Product List :",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                // color: color2,
                                fontSize: 16,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600),
                          ),
                          Expanded(
                            child: Container(
                              child: tableBody(
                                context,
                              ),

                              // ListView.builder(
                              //   itemCount: productList.length,
                              //   itemBuilder: (context, index) =>
                              //   Container(
                              //       margin: EdgeInsets.all(2),
                              //       child: Table(
                              //           columnWidths: {
                              //             0: FractionColumnWidth(.4),
                              //             1: FractionColumnWidth(.1),
                              //             2: FractionColumnWidth(.2)
                              //           },
                              //           border: TableBorder.all(
                              //               color: color2,
                              //               style: BorderStyle.solid,
                              //               width: 1),
                              //           children: [
                              //             TableRow(children: [
                              //               Text(productList[index].productName,
                              //                   style:
                              //                       TextStyle(fontSize: 14.0)),
                              //               Text(
                              //                   productList[index]
                              //                       .productQuantity
                              //                       .toString(),
                              //                   style:
                              //                       TextStyle(fontSize: 14.0)),
                              //               Text(
                              //                   productList[index]
                              //                       .productPrice
                              //                       .toString(),
                              //                   style:
                              //                       TextStyle(fontSize: 14.0)),
                              //             ]),
                              //           ])),
                              // ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.80,
                              child: ElevatedButton(
                                onPressed: () {
                                  _updateOrder(productOrderID, "1");
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Accept Order",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    elevation: 7,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    primary: primaryColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 15),
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              )),
                        ],
                      )),
                ),
              );
            });
          });
    });
  }

  SingleChildScrollView tableBody(BuildContext ctx) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        // dataRowHeight: 50,
        dividerThickness: 1,
        columns: [
          DataColumn(
            label: Text(
              "Product Name",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.deepOrange,
              ),
            ),
            numeric: false,
            tooltip: "This is product Name",
          ),
          DataColumn(
            label: Text(
              "Amount",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.deepOrange,
              ),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              "Quantity",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.deepOrange,
              ),
            ),
            numeric: false,
            tooltip: "This is product quantity",
          ),
        ],
        rows: productList
            .map(
              (product) => DataRow(cells: [
                DataCell(
                  Text(product.productName),
                ),
                DataCell(
                  Text(product.productPrice.toString()),
                ),
                DataCell(
                  Text(product.productQuantity.toString()),
                ),
              ]),
            )
            .toList(),
      ),
    );
  }
}
