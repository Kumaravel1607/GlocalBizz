import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Model/detail_model.dart';
import 'package:glocal_bizz/Model/product_detail_model.dart';
import 'package:glocal_bizz/View/CreateStore/Cart.dart';
import 'package:glocal_bizz/Widgets/OurProduct_widget.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final String product_id;
  ProductDetailPage({Key key, this.product_id}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  PageController _pageController;

  String adsID;
  String receiverId;
  String user_ID;
  String poster_Id;
  int _current = 0;
  String userId;
  SharedPreferences prefs;
  Future<ProductDetail> _productdetail;
  String phone = "";
  int quantity = 1;
  bool _submitLoad = true;
  int cartCount;

  @override
  void initState() {
    super.initState();
    _productdetail = product_detail();
    image_api();
    getCartCount();
  }

  void refresh() {
    setState(() {
      _pageController = PageController(initialPage: _current);
    });
  }

  FutureOr onGoBack(dynamic value) {
    getCartCount();
    setState(() {});
  }

  getCartCount() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "customer_id": prefs.getString("user_id"),
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/cart_count"), body: data);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      setState(() {
        cartCount = result['cart_count'];
      });
    } else {
      print("error");
    }
  }

  Future<ProductDetail> product_detail() async {
    Map data = {
      'id': widget.product_id,
    };
    print(data);

    var response =
        await http.post(Uri.parse(api_url + "/product_details"), body: data);
    print(response.body.toString());
    var jsonResponse;
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = true;
      });
      jsonResponse = json.decode(response.body);
      print("--------------NK-----------");
      print(jsonResponse);
      // poster_Id = jsonResponse['customer_id'].toString();
      // adsID = jsonResponse['id'].toString();
      // // setState(() {
      // receiverId = jsonResponse['customer_id'].toString();
      // userId = prefs.getString("user_id");

      return ProductDetail.fromJson(jsonResponse);
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
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load post');
    }
  }

  Future<void> image_api() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'id': widget.product_id,
      'customer_id': prefs.getString("user_id"),
    };
    var response =
        await http.post(Uri.parse(api_url + "/product_details"), body: data);

    if (response.statusCode == 200) {
      get_imageList(json.decode(response.body)['productimages']).then((value) {
        setState(() {
          imageList = value;
        });
      });
    }
  }

  List<AllProductImage> imageList = List<AllProductImage>();

  Future<List<AllProductImage>> get_imageList(imageListsJson) async {
    var imageLists = List<AllProductImage>();
    for (var imageListJson in imageListsJson) {
      imageLists.add(AllProductImage.fromJson(imageListJson));
    }
    return imageLists;
  }

  void _addToCart() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      // 'store_id': storeID,
      'product_id': widget.product_id,
      'quantity': quantity.toString(),
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/add_cart"), body: data);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = true;
        _submitLoad = true;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('This Product added to your cart'),
        ),
      );
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
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          "Product Detail",
          style: TextStyle(color: white, fontFamily: "Poppins"),
        ),
        actions: [
          InkWell(
            child: cartCount != null
                ? Badge(
                    badgeContent: Text(
                      '$cartCount',
                      style: TextStyle(color: white),
                    ),
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.shopping_cart_sharp, color: white))
                : Icon(Icons.shopping_cart_sharp, color: white),
            onTap: () {
              // _checkVersion();
              Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (context) => CartPage()))
                  .then(onGoBack);
            },
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: _isLoading
          ? SafeArea(
              child: FutureBuilder<ProductDetail>(
                future: _productdetail, // async work
                builder: (BuildContext context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container(
                        child: Center(
                            child: CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(primaryColor),
                        )),
                      );
                    default:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else {
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
                                              autoPlayInterval:
                                                  Duration(seconds: 3),
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
                                          itemBuilder:
                                              (context, index, int name) {
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
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        // height: MediaQuery.of(context).size.height,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    0.5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                imageList[index]
                                                                    .product_image),
                                                            fit: BoxFit.contain,
                                                          ),
                                                          shape: BoxShape
                                                              .rectangle,
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 250,
                                                        color: const Color(
                                                                0xBD0E3311)
                                                            .withOpacity(0.1),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }),
                                    ),
                                    // Container(
                                    //   height: 250,
                                    //   padding: EdgeInsets.all(0),
                                    //   width: MediaQuery.of(context).size.width,
                                    //   // height: MediaQuery.of(context).size.height,
                                    //   margin:
                                    //       EdgeInsets.symmetric(horizontal: 0.5),
                                    //   decoration: BoxDecoration(
                                    //     color: white,
                                    //     borderRadius: BorderRadius.circular(2),
                                    //     image: DecorationImage(
                                    //       image: NetworkImage(
                                    //           snapshot.data.product_image),
                                    //       fit: BoxFit.contain,
                                    //     ),
                                    //     shape: BoxShape.rectangle,
                                    //   ),
                                    // ),
                                    Container(
                                        height: 250,
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 10, 20, 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Spacer(),
                                            imageList.length != 1
                                                ? Center(
                                                    child: new DotsIndicator(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      dotsCount:
                                                          imageList.isNotEmpty
                                                              ? imageList.length
                                                              : 1,
                                                      position:
                                                          _current.toDouble(),
                                                      decorator: DotsDecorator(
                                                        color: Colors.grey[
                                                            200], // Inactive color
                                                        activeColor:
                                                            primaryColor,
                                                        size: const Size.square(
                                                            7.0),
                                                        activeSize: const Size(
                                                            10.0, 8.0),
                                                        activeShape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
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
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data.product_name,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Poppins",
                                            color: color2,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            snapshot.data.product_price ?? "--",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "Poppins",
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            snapshot.data.product_mrp ?? "--",
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "(Inclusive of all texes)",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 10,
                                          color: Color(0xFF8D87AD),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Row(
                                        children: [
                                          Text(
                                            "Quantity",
                                            style: TextStyle(
                                              // fontSize: 15,
                                              fontFamily: "Poppins",
                                              color: color2,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            height: 30.0,
                                            width: 140.0,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12.0),
                                              ),
                                              border: Border.all(
                                                  color: Colors.black38),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  splashRadius: 0.1,
                                                  padding: EdgeInsets.all(3),
                                                  color: Colors.grey[200],
                                                  onPressed: () {
                                                    setState(() {
                                                      quantity != 0
                                                          ? quantity--
                                                          : null;
                                                    });
                                                    // quan_minus(cartData[index].cart_id);
                                                    /*   setState(() {
                                                  i = int.parse(
                                                      cartData[index].quantity);
                                                  if (i != 0) i--;
                                                  print(i--);
                                                }); */
                                                  },
                                                  icon: Icon(Icons.remove,
                                                      size: 16,
                                                      color: Colors.black),
                                                ),
                                                Text('$quantity',
                                                    style: new TextStyle(
                                                        fontSize: 12.0,
                                                        color: color2)),
                                                new IconButton(
                                                  splashRadius: 0.1,
                                                  padding: EdgeInsets.only(
                                                      right: 5.0, left: 5.0),
                                                  color: Colors.grey,
                                                  onPressed: () {
                                                    setState(() {
                                                      quantity++;
                                                    });
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
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(40.0),
                                        topRight: Radius.circular(40.0)),
                                  ),
                                  padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // trendingList(snapshot.data),
                                      Divider(),
                                      Text(
                                        "Product Details",
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 4,
                                              child: Container(
                                                height: 100,
                                                // color: green,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Product Code",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: Colors.grey[600],
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Availablity",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: Colors.grey[600],
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Quantity",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: Colors.grey[600],
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                height: 100,
                                                // color: appcolor,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: appcolor,
                                                      ),
                                                    ),
                                                    Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: appcolor,
                                                      ),
                                                    ),
                                                    Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: appcolor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                          Expanded(
                                              flex: 6,
                                              child: Container(
                                                height: 100,
                                                // color: green,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      snapshot.data.product_code
                                                              .isNotEmpty
                                                          ? snapshot
                                                              .data.product_code
                                                          : "--",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: color2,
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      snapshot.data
                                                                  .product_status ==
                                                              "1"
                                                          ? "Available"
                                                          : "Not Available",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: color2,
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      snapshot
                                                              .data
                                                              .product_count
                                                              .isNotEmpty
                                                          ? snapshot.data
                                                              .product_count
                                                          : "--",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 2,
                                                        color: color2,
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                      Divider(),
                                      Text(
                                        "Description",
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        snapshot.data.product_description,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      // Text(
                                      //   "Related Products",
                                      //   style: TextStyle(
                                      //       fontFamily: "Poppins",
                                      //       color: primaryColor,
                                      //       fontWeight: FontWeight.w600,
                                      //       fontSize: 16),
                                      // ),
                                      // Container(
                                      //     // color: primaryColor,
                                      //     height: 210,
                                      //     child: ListView(
                                      //       scrollDirection: Axis.horizontal,
                                      //       children: [
                                      //         RelatedProduct(),
                                      //         RelatedProduct(),
                                      //         RelatedProduct(),
                                      //         RelatedProduct(),
                                      //       ],
                                      //     )),

                                      SizedBox(
                                        height: 60,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[600],
                                  blurRadius: 5.0,
                                ),
                              ]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      child: Container(
                                          color: white,
                                          child: Center(
                                              child: Text(
                                            "ADD TO CART",
                                            style: TextStyle(
                                                color: color2,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w600),
                                          ))),
                                      onTap: () {
                                        print("Add to Cart");
                                        _addToCart();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        child: Container(
                                            color: primaryColor,
                                            child: Center(
                                                child: Text(
                                              "VIEW CART",
                                              style: TextStyle(
                                                  color: white,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w600),
                                            ))),
                                        onTap: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      CartPage()))
                                              .then(onGoBack);
                                        },
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ]);
                      }
                  }
                },
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

  Widget photoView() => Container(
        child: Stack(children: [
          PhotoViewGallery.builder(
            itemCount: imageList.length,
            pageController: _pageController,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageList[index].product_image),
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
}
