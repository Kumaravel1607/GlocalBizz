import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/CartPage_model.dart';
import 'package:glocal_bizz/View/CreateStore/CheckOut.dart';
import 'package:glocal_bizz/View/CreateStore/Delivery_address.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:awesome_loader/awesome_loader.dart';
import 'TrackOrder.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;

  bool _isLoading = false;
  bool _addQty = false;
  String total_price;
  String delivery_charge;
  @override
  void initState() {
    super.initState();
    _getCartList();
  }

  Future<void> _getCartList() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "customer_id": prefs.getString("user_id"),
    };
    print(jsonEncode(data));
    var response =
        await http.post(Uri.parse(api_url + "/view_cart"), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print(result);

      setState(() {
        _isLoading = true;
        total_price = result['price_sys'];
        delivery_charge = result['delivery_fee'];
      });

      get_cartlist(result['cart']).then((value) {
        setState(() {
          cartList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<MyCartList> cartList = List<MyCartList>();

  Future<List<MyCartList>> get_cartlist(cartListsJson) async {
    var cartList = List<MyCartList>();
    for (var cartListsJson in cartListsJson) {
      cartList.add(MyCartList.fromJson(cartListsJson));
    }
    return cartList;
  }

  delete_cart(cartID) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      // 'store_id': prefs.getString("store_id"),
      'cart_id': cartID,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + '/delete_cart'), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Cart deleted.'),
        ),
      );
    } else {
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  void _addToCart(productID, qty) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      // 'store_id': prefs.getString("store_id"),
      'product_id': productID.toString(),
      'quantity': qty.toString(),
    };

    print(jsonEncode(data));
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/add_cart"), body: data);
    print(api_url + "/add_cart");
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _addQty = false;
        total_price = jsonResponse['total_amount'];
      });
      print("-----------------NK--------------");
      print(jsonResponse);
      // Future.delayed(Duration(seconds: 3));
      // _getCartList();
      // _scaffoldKey.currentState.showSnackBar(
      //   SnackBar(
      //     content: const Text('This Product added to your cart'),
      //   ),
      // );
    } else if (response.statusCode == 400) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              ErrorPage(data: response.body.toString())));
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              ErrorPage(data: response.body.toString())));
    } else if (response.statusCode == 500) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => ErrorPage(
              data: 'Error occured while communication with server' +
                  ' with status code : ${response.statusCode}')));
    } else {
      // jsonResponse = json.decode(response.body);
      print(response.body.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[200],
      key: _scaffoldKey,
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 5,
        iconTheme: new IconThemeData(
          color: white,
        ),
        title: Text("My Cart",
            style: TextStyle(
              color: white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              // size: 26,
              color: white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: _isLoading
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: cartList.isNotEmpty
                  ? Stack(children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: detailCart(),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                          )
                          // _removeBtn(),
                        ],
                      ),
                      _button(),
                    ])
                  : Container(
                      color: white,
                      padding: (EdgeInsets.all(20)),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Your cart is empty !!",
                            style: TextStyle(
                                color: color2,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              side: BorderSide(
                                color: primaryColor,
                              ),
                            ),
                            textColor: Colors.white,
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              bottom: 10.0,
                              left: 35.0,
                              right: 35.0,
                            ),
                            color: primaryColor,
                            child: Text(
                              "Shop now",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (BuildContext context) => Home()));
                            },
                            // ),
                          ),
                        ],
                      )),
            )
          : Loading(),
    );
  }

  Widget detailCart() {
    return Stack(
      children: [
        new ListView.builder(
            shrinkWrap: false,
            scrollDirection: Axis.vertical,
            itemCount: cartList.length,
            itemBuilder: (context, index) {
              // int quantity;
              // quantity = cartList[index].quantity;
              return Padding(
                padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
                child: Container(
                  decoration: BoxDecoration(
                    color: white,
                    // borderRadius: BorderRadius.only(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: new InkWell(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                height: 130,
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[200],
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          cartList[index].product_image),
                                      fit: BoxFit.fill),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(new PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (BuildContext context, _, __) {
                                      return new Material(
                                          color: Colors.black54,
                                          child: new Container(
                                            padding: const EdgeInsets.all(30.0),
                                            child: new InkWell(
                                              child: new Hero(
                                                child: new Image.network(
                                                  // 'images/${itm.icon}',
                                                  cartList[index].product_image,
                                                  width: 300.0,
                                                  height: 300.0,
                                                  alignment: Alignment.center,
                                                  fit: BoxFit.contain,
                                                ),
                                                tag: cartList[index]
                                                    .product_name,
                                                // tag:itm.id,
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ));
                                    }));
                              },
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(12, 0, 20, 0),
                                  height: 130.0,
                                  // color: white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(cartList[index].product_name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: color2,
                                            fontSize: 16.0,
                                            // height: 1.2,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      // SizedBox(
                                      //   height: 3,
                                      // ),
                                      // SizedBox(
                                      //   height: 5,
                                      // ),

                                      SizedBox(
                                        height: 0,
                                      ),
                                      Text(
                                        inr + cartList[index].price.toString(),
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.0,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        height: 30.0,
                                        width: 140.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.0),
                                          ),
                                          border:
                                              Border.all(color: Colors.black38),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.all(3),
                                              color: Colors.grey[200],
                                              onPressed: () {
                                                setState(() {
                                                  if (cartList[index]
                                                          .quantity !=
                                                      0) {
                                                    cartList[index].quantity--;
                                                    cartList[index].price =
                                                        cartList[index].price -
                                                            cartList[index]
                                                                .product_price;

                                                    _addToCart(
                                                      cartList[index]
                                                          .product_id,
                                                      cartList[index]
                                                          .quantity
                                                          .toString(),
                                                    );
                                                    _addQty = true;
                                                  }
                                                });
                                              },
                                              icon: Icon(Icons.remove,
                                                  size: 16,
                                                  color: Colors.black),
                                            ),
                                            // if (quantity != null)
                                            Text(
                                                cartList[index]
                                                    .quantity
                                                    .toString(),
                                                style: new TextStyle(
                                                    fontSize: 12.0,
                                                    color: color2)),
                                            new IconButton(
                                              padding: EdgeInsets.only(
                                                  right: 5.0, left: 5.0),
                                              color: Colors.grey,
                                              onPressed: () {
                                                setState(() {
                                                  cartList[index].quantity++;
                                                  _addQty = true;
                                                  cartList[index].price =
                                                      cartList[index].price +
                                                          cartList[index]
                                                              .product_price;
                                                });
                                                _addToCart(
                                                  cartList[index].product_id,
                                                  cartList[index]
                                                      .quantity
                                                      .toString(),
                                                );
                                                // quan_add(cartData[index].cart_id);
                                                /*  _addProduct();
                                                setState(() {
                                                  i = int.parse(
                                                      cartData[index].quantity);
                                                  i++;
                                                  print(i++);
                                                }); */
                                              },
                                              icon: Icon(
                                                Icons.add,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 3, right: 3),
                                    height: 130,
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      child: Icon(
                                        Icons.remove_circle,
                                        size: 24,
                                        color: Colors.red,
                                      ),
                                      onTap: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content:
                                                    Text("Confirm to delete"),
                                                //title: Text(),
                                                actions: <Widget>[
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, "ok");
                                                    },
                                                    child: const Text("NO"),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      delete_cart(
                                                          cartList[index]
                                                              .id
                                                              .toString());
                                                      setState(() {
                                                        cartList
                                                            .removeAt(index);
                                                      });
                                                      Navigator.pop(
                                                          context, "ok");
                                                    },
                                                    child:
                                                        const Text("Confirm"),
                                                  )
                                                ],
                                              );
                                            });
                                      },
                                    ))
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }),
        _addQty
            ? Container(
                alignment: Alignment.center,
                color: const Color(0xFF0E3311).withOpacity(0.23),
                child: Center(
                  child: AwesomeLoader(
                    loaderType: AwesomeLoader.AwesomeLoader3,
                    color: green,
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  // Widget _removeBtn() {
  //   return Padding(
  //     padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
  //     child: Row(
  //       children: [
  //         Expanded(
  //             flex: 2,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 // color: Colors.red,
  //                 borderRadius: BorderRadius.circular(0),
  //                 border: Border.all(color: Colors.grey, width: 0.2),
  //               ),
  //               height: 27,
  //               child: Center(
  //                 child: Text(
  //                   "REMOVE",
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Color(0xFF070120),
  //                   ),
  //                 ),
  //               ),
  //             )),
  //         Expanded(
  //             flex: 2,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 // color: Colors.blue,
  //                 borderRadius: BorderRadius.circular(0),
  //                 border: Border.all(color: Colors.grey, width: 0.2),
  //               ),
  //               height: 27,
  //               child: Center(
  //                 child: Text(
  //                   "MOVE TO WHISHLIST",
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Color(0xFF070120),
  //                   ),
  //                 ),
  //               ),
  //             )),
  //       ],
  //     ),
  //   );
  // }

  Widget _button() {
    return Container(
        alignment: Alignment.bottomCenter,
        // color: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 0),
        // child: ButtonTheme(
        // minWidth: 400,
        child: Container(
          padding: EdgeInsets.only(right: 20, left: 25),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0), topRight: Radius.circular(0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text(
                          "Delivery Charge : " + delivery_charge,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          total_price != null ? total_price : inr + "--",
                          style: TextStyle(
                            color: color2,
                            // height: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          "Total Price",
                          style: TextStyle(
                            color: color2,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                          ),
                        ),
                      ]))),
              // Spacer(),
              // SizedBox(
              //   width: 80,
              // ),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: Container(
                        child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DeliverAddressPage()));

                        // Navigator.of(context, rootNavigator: true).push(
                        //     MaterialPageRoute(
                        //         builder: (context) => TrackOrderPage()));
                      },
                      child: Text(
                        "Checkout",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          primary: primaryColor,
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    )),
                  )),
            ],
          ),
        ));
  }
}


// import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'package:flutter/widgets.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:glocal_bizz/Controller/api.dart';
// import 'package:glocal_bizz/Controller/constand.dart';
// import 'package:glocal_bizz/Model/CartPage_model.dart';
// import 'package:glocal_bizz/View/CreateStore/CheckOut.dart';
// import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
// import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'dart:convert';

// import 'TrackOrder.dart';

// class CartPage extends StatefulWidget {
//   @override
//   _CartPageState createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   SharedPreferences prefs;

//   bool _isLoading = false;
//   String total_price;
//   @override
//   void initState() {
//     super.initState();
//     // _getCartList();
//     _future = _getProducts();
//   }

//   Future<void> _getCartList() async {
//     prefs = await SharedPreferences.getInstance();
//     Map data = {
//       "customer_id": prefs.getString("user_id"),
//     };
//     print(jsonEncode(data));
//     var response =
//         await http.post(Uri.parse(api_url + "/view_cart"), body: data);

//     if (response.statusCode == 200) {
//       var result = json.decode(response.body);

//       setState(() {
//         _isLoading = true;
//       });

//       get_cartlist(result).then((value) {
//         setState(() {
//           cartList = value;
//         });
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   List<MyCartList> cartList = List<MyCartList>();

//   Future<List<MyCartList>> get_cartlist(cartListsJson) async {
//     var cartList = List<MyCartList>();
//     for (var cartListsJson in cartListsJson) {
//       cartList.add(MyCartList.fromJson(cartListsJson));
//     }
//     return cartList;
//   }

//   Future<List<ItemData>> _future;

//   Future<List<ItemData>> _getProducts() async {
//     prefs = await SharedPreferences.getInstance();
//     Map data = {
//       "customer_id": prefs.getString("user_id"),
//     };
//     print(jsonEncode(data));
//     var response =
//         await http.post(Uri.parse(api_url + "/view_cart"), body: data);

//     if (response.statusCode == 200) {
//       setState(() {
//         _isLoading = true;
//       });
//       var jsonData = json.decode(response.body);

//       List<ItemData> details = [];
//       for (var p in jsonData) {
//         ItemData detail = ItemData(
//             id: p['id'],
//             customer_id: p['customer_id'],
//             store_id: p['store_id'],
//             product_id: p['product_id'],
//             quantity: p['quantity'],
//             price: p['price'],
//             product_image: p['product_image'],
//             product_name: p['product_name']);
//         details.add(detail);
//       }
//       return details;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.grey[200],
//       backgroundColor: Colors.blue.shade50,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 5,
//         iconTheme: new IconThemeData(
//           color: white,
//         ),
//         title: Text("My Cart",
//             style: TextStyle(
//               color: white,
//               fontSize: 18.0,
//               fontWeight: FontWeight.bold,
//             )),
//         centerTitle: true,
//         leading: IconButton(
//             icon: Icon(
//               Icons.arrow_back,
//               // size: 26,
//               color: white,
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             }),
//       ),
//       body: _isLoading
//           ? Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child: 3 != 0
//                   ? Stack(children: [
//                       Column(
//                         // mainAxisAlignment: MainAxisAlignment.center,
//                         // crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           Expanded(
//                             child: Container(
//                               child: detailCart(),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 60,
//                           )
//                           // _removeBtn(),
//                         ],
//                       ),
//                       _button(),
//                     ])
//                   : Container(
//                       color: white,
//                       padding: (EdgeInsets.all(20)),
//                       alignment: Alignment.center,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Your cart is empty!",
//                             style: TextStyle(
//                                 color: color2,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           SizedBox(
//                             height: 25,
//                           ),
//                           RaisedButton(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: new BorderRadius.circular(5.0),
//                               side: BorderSide(
//                                 color: primaryColor,
//                               ),
//                             ),
//                             textColor: Colors.white,
//                             padding: const EdgeInsets.only(
//                               top: 10.0,
//                               bottom: 10.0,
//                               left: 35.0,
//                               right: 35.0,
//                             ),
//                             color: primaryColor,
//                             child: Text(
//                               "Shop now",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14.0,
//                               ),
//                             ),
//                             onPressed: () {
//                               // Navigator.of(context).push(MaterialPageRoute(
//                               //     builder: (BuildContext context) => Home()));
//                             },
//                             // ),
//                           ),
//                         ],
//                       )),
//             )
//           : Loading(),
//     );
//   }

//   // Widget hh() {
//   //   return FutureBuilder(
//   //       future: _future,
//   //       builder: (BuildContext context, AsyncSnapshot snapshot) =>
//   //         Text("vh"),

//   //       );
//   // }

//   Widget detailCart() {
//     return FutureBuilder(
//       future: _future,
//       builder: (BuildContext context, AsyncSnapshot snapshot) => new ListView
//               .builder(
//           shrinkWrap: false,
//           scrollDirection: Axis.vertical,
//           itemCount: snapshot.data.length,
//           itemBuilder: (context, index) {
//             // int quantity = 0;
//             // quantity = cartList[index].quantity;
//             return Padding(
//               padding: EdgeInsets.fromLTRB(13, 7, 13, 7),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: white,
//                   // borderRadius: BorderRadius.only(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 5,
//                           child: new InkWell(
//                             child: Container(
//                               padding: EdgeInsets.all(5),
//                               height: 130,
//                               decoration: BoxDecoration(
//                                 color: white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey[200],
//                                     offset: Offset(0.0, 1.0), //(x,y)
//                                     blurRadius: 6.0,
//                                   ),
//                                 ],
//                                 image: DecorationImage(
//                                     image: NetworkImage(
//                                         snapshot.data[index].product_image),
//                                     fit: BoxFit.fill),
//                               ),
//                             ),
//                             onTap: () {
//                               Navigator.of(context).push(new PageRouteBuilder(
//                                   opaque: false,
//                                   pageBuilder: (BuildContext context, _, __) {
//                                     return new Material(
//                                         color: Colors.black54,
//                                         child: new Container(
//                                           padding: const EdgeInsets.all(30.0),
//                                           child: new InkWell(
//                                             child: new Hero(
//                                               child: new Image.network(
//                                                 // 'images/${itm.icon}',
//                                                 snapshot
//                                                     .data[index].product_image,
//                                                 width: 300.0,
//                                                 height: 300.0,
//                                                 alignment: Alignment.center,
//                                                 fit: BoxFit.contain,
//                                               ),
//                                               tag: snapshot
//                                                   .data[index].product_name,
//                                               // tag:itm.id,
//                                             ),
//                                             onTap: () {
//                                               Navigator.pop(context);
//                                             },
//                                           ),
//                                         ));
//                                   }));
//                             },
//                           ),
//                         ),
//                         Expanded(
//                           flex: 8,
//                           child: Stack(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.fromLTRB(12, 0, 20, 0),
//                                 height: 130.0,
//                                 // color: white,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     Text(snapshot.data[index].product_name,
//                                         overflow: TextOverflow.ellipsis,
//                                         maxLines: 2,
//                                         style: TextStyle(
//                                           color: color2,
//                                           fontSize: 16.0,
//                                           // height: 1.2,
//                                           fontWeight: FontWeight.w600,
//                                         )),
//                                     // SizedBox(
//                                     //   height: 3,
//                                     // ),
//                                     // SizedBox(
//                                     //   height: 5,
//                                     // ),

//                                     SizedBox(
//                                       height: 0,
//                                     ),
//                                     Text(
//                                       snapshot.data[index].price.toString(),
//                                       style: TextStyle(
//                                         color: primaryColor,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 15.0,
//                                         // fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
// /*                                   Row(
//                                     children: <Widget>[
//                                       Text(
//                                         '$cartList[index].price',
//                                         style: TextStyle(
//                                           color: primaryColor,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 15.0,
//                                           // fontWeight: FontWeight.bold,
//                                         ),
//                                       ), Text(
//                                         '$cartList[index].price',
//                                         style: TextStyle(
//                                           color: primaryColor,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 15.0,
//                                           // fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       // new RichText(
//                                       //   text: new TextSpan(
//                                       //     children: <TextSpan>[
//                                       //       new TextSpan(
//                                       //         text: "\$49,000",
//                                       //         style: new TextStyle(
//                                       //           color: Colors.grey,
//                                       //           fontSize: 11,
//                                       //           decoration:
//                                       //               TextDecoration.lineThrough,
//                                       //         ),
//                                       //       ),
//                                       //     ],
//                                       //   ),
//                                       // ),
//                                       SizedBox(
//                                         width: 8,
//                                       ),
//                                       // Text(
//                                       //   "25% OFF",
//                                       //   style: TextStyle(
//                                       //       fontSize: 12.0, color: green),
//                                       // ),
//                                     ],
//                                   ),
//                                   // SizedBox(
//                                   //   height: 7,
//                                   // ), */
//                                     Container(
//                                       height: 30.0,
//                                       width: 140.0,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.all(
//                                           Radius.circular(12.0),
//                                         ),
//                                         border:
//                                             Border.all(color: Colors.black38),
//                                       ),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceEvenly,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           IconButton(
//                                             padding: EdgeInsets.all(3),
//                                             color: Colors.grey[200],
//                                             onPressed: () {
//                                               setState(() {
//                                                 // if (quantity != 0) quantity--;
//                                                 // quantity = quantity;
//                                                 // print(quantity);
//                                                 if (snapshot
//                                                         .data[index].quantity >
//                                                     0) {
//                                                   snapshot
//                                                       .data[index].quantity--;
//                                                 }
//                                               });
//                                               // quan_minus(cartData[index].cart_id);
//                                               /*   setState(() {
//                                               i = int.parse(
//                                                   cartData[index].quantity);
//                                               if (i != 0) i--;
//                                               print(i--);
//                                             }); */
//                                             },
//                                             icon: Icon(Icons.remove,
//                                                 size: 16, color: Colors.black),
//                                           ),
//                                           // if (quantity != null)
//                                           Text(
//                                               snapshot.data[index].quantity
//                                                   .toString(),
//                                               style: new TextStyle(
//                                                   fontSize: 12.0,
//                                                   color: color2)),
//                                           new IconButton(
//                                             padding: EdgeInsets.only(
//                                                 right: 5.0, left: 5.0),
//                                             color: Colors.grey,
//                                             onPressed: () {
//                                               setState(() {
//                                                 snapshot.data[index].quantity++;
//                                                 print(snapshot
//                                                     .data[index].quantity);
//                                                 // quantity++;
//                                                 // quantity = quantity;
//                                                 // print(quantity);
//                                               });
//                                               // quan_add(cartData[index].cart_id);
//                                               /*  _addProduct();
//                                             setState(() {
//                                               i = int.parse(
//                                                   cartData[index].quantity);
//                                               i++;
//                                               print(i++);
//                                             }); */
//                                             },
//                                             icon: Icon(
//                                               Icons.add,
//                                               size: 16,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                   padding: EdgeInsets.only(top: 3, right: 3),
//                                   height: 130,
//                                   alignment: Alignment.topRight,
//                                   child: GestureDetector(
//                                     child: Icon(
//                                       Icons.remove_circle,
//                                       size: 22,
//                                       color: Colors.red,
//                                     ),
//                                     onTap: () {
//                                       print("removed");
//                                       // remove_cart(cartData[index].cart_id);
//                                       // setState(() {
//                                       //   cartData.removeAt(index);
//                                       // });
//                                     },
//                                   ))
//                             ],
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             );
//           }),
//     );
//   }

//   Widget _removeBtn() {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
//       child: Row(
//         children: [
//           Expanded(
//               flex: 2,
//               child: Container(
//                 decoration: BoxDecoration(
//                   // color: Colors.red,
//                   borderRadius: BorderRadius.circular(0),
//                   border: Border.all(color: Colors.grey, width: 0.2),
//                 ),
//                 height: 27,
//                 child: Center(
//                   child: Text(
//                     "REMOVE",
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF070120),
//                     ),
//                   ),
//                 ),
//               )),
//           Expanded(
//               flex: 2,
//               child: Container(
//                 decoration: BoxDecoration(
//                   // color: Colors.blue,
//                   borderRadius: BorderRadius.circular(0),
//                   border: Border.all(color: Colors.grey, width: 0.2),
//                 ),
//                 height: 27,
//                 child: Center(
//                   child: Text(
//                     "MOVE TO WHISHLIST",
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF070120),
//                     ),
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _button() {
//     return Container(
//         alignment: Alignment.bottomCenter,
//         // color: Colors.red,
//         padding: const EdgeInsets.symmetric(vertical: 0),
//         // child: ButtonTheme(
//         // minWidth: 400,
//         child: Container(
//           padding: EdgeInsets.only(right: 20, left: 25),
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(0), topRight: Radius.circular(0)),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                   flex: 1,
//                   child: Container(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                         Text(
//                           total_price ?? "\$230",
//                           style: TextStyle(
//                             color: color2,
//                             // height: 2,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16.0,
//                           ),
//                         ),
//                         Text(
//                           "Total Price",
//                           style: TextStyle(
//                             color: color2,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14.0,
//                           ),
//                         ),
//                       ]))),
//               // Spacer(),
//               // SizedBox(
//               //   width: 80,
//               // ),
//               Expanded(
//                   flex: 1,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 13.0),
//                     child: Container(
//                         child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context, rootNavigator: true).push(
//                             MaterialPageRoute(
//                                 builder: (context) => TrackOrderPage()));
//                       },
//                       child: Text(
//                         "Checkout",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                           elevation: 7,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           primary: primaryColor,
//                           textStyle: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.w500)),
//                     )),
//                   )),
//             ],
//           ),
//         ));
//   }
// }
