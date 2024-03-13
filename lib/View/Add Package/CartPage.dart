import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/Add%20Package/FeaturePackage.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController promoCode = new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController name = new TextEditingController();
  final TextEditingController email = new TextEditingController();
  final TextEditingController mobileNumber = new TextEditingController();

  bool enableBtn = true;
  double total_amount = 0.0;
  double initial_total_amount = 0.0;
  bool _isLoading = true;

  String cartID;
  int user;

  List<dynamic> pkgIDs = [];
  String promoDiscount = "0";

  String userName;
  String userMobile;
  String userEmail;
  String userDescription;

  @override
  void initState() {
    super.initState();
    // cart_list();
  }

  //  void cart_list() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  //   var jsonResponse;
  //    var response = await http.get(app_api + '/get-cart/', headers: {
  //       'content-type': 'application/json',
  //       'Authorization': 'Token ' + sharedPreferences.getString("token"),
  //     });

  //   if (response.statusCode == 200) {
  //    var result = (json.decode(response.body)['data']);
  //     setState(() {
  //       _isLoading = false;
  //       user = result['user'];
  //       total_amount = result['total_amount'];
  //       initial_total_amount = result['total_amount'];
  //       cartID = result['id'].toString();
  //     });

  //     print(result['package']);

  //     setState(() {
  //       pkgIDs = result['pkg_id'];
  //     });

  //     get_cartList(result['package']).then((value) {
  //       setState(() {
  //         cartList = value;
  //       });
  //     });

  //     print('---------------NK-----------');
  //     print(json.decode(response.body));
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // List<PackageModel> cartList = List<PackageModel>();

  // Future<List<PackageModel>> get_cartList(packagesJson) async {
  //   var cartList = List<PackageModel>();
  //   for (var packageeJson in packagesJson) {
  //     cartList.add(PackageModel.fromJson(packageeJson));
  //   }
  //   return cartList;
  // }

  // void delete_cart(deleteValue) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  //   pkgIDs.removeAt(int.parse(deleteValue));
  //   Map data = {
  //     'package': pkgIDs,
  //   };
  //   print(data);
  //    var response = await http.patch(app_api + '/cart/'+ cartID +'/', headers: {
  //       'content-type': 'application/json',
  //       'Authorization': 'Token ' + sharedPreferences.getString("token"),
  //       },
  //       body: json.encode(data));

  //        if (response.statusCode == 200) {
  //         var result = (json.decode(response.body)['data']);

  //       print(result);
  //         print("SUCCESS delete CART");
  //       } else {
  //         print("ERROR delete CART");
  //       }
  // }
  // }

  // void allDelete_cart() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  //   var response = await http.delete(app_api + '/cart/'+ cartID +'/', headers: {
  //       'content-type': 'application/json',
  //       'Authorization': 'Token ' + sharedPreferences.getString("token"),
  //       },);

  //        if (response.statusCode == 200) {
  //         var result = (json.decode(response.body));
  //         setState(() {
  //             cart_list();
  //           });
  //       print(result);
  //         print("SUCCESS delete all CART");
  //       } else {
  //         print("ERROR delete all CART");
  //       }
  // }

  // void get_promocode(code, cartid, amount) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  //   var jsonResponse;
  //   var url = php_api + '/promo.php?promo_code='+ code+'&cart_id='+cartid+'&billable_amount='+amount+'&user_id='+sharedPreferences.getString("user_id");
  //    var response = await http.get(url,
  //     headers: {
  //       'content-type': 'application/json',
  //       'Authorization': 'Token ' + sharedPreferences.getString("token"),
  //     });

  //     print('url-------');
  //     print(url);

  //   if (response.statusCode == 200) {
  //    var result = (json.decode(response.body));

  //    setState(() {
  //             promoDiscount = result['discount_percent'];
  //             var percent = total_amount - (total_amount * (int.parse(result['discount_percent']) / 100));
  //             total_amount = percent;
  //           });

  //           print("total_amount");
  //           print(total_amount.toStringAsFixed(2));

  //     setState(() {
  //       _isLoading = false;
  //     });

  //     print(result);
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // void payment_create(amount) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  //   Map data = {
  //     'amount': amount,
  //   };
  //   print(data);
  //    var response = await http.post(app_api + '/create-razorpay-order/', headers: {
  //       'content-type': 'application/json',
  //       'Authorization': 'Token ' + sharedPreferences.getString("token"),
  //       },
  //       body: json.encode(data));

  //        if (response.statusCode == 200) {
  //         var result = (json.decode(response.body)['data']);
  //         print(result);

  //         Navigator.of(context, rootNavigator: true).pushReplacement(
  //         MaterialPageRoute(
  //         builder: (BuildContext context) =>
  //         CheckOut(
  //           amount: result['amount'],
  //           name: userName,
  //           mobile: userMobile,
  //           email: userEmail,
  //           description: userDescription,
  //           )));

  //         print("SUCCESS CREATE PAYMENT");
  //       } else {
  //         print("ERROR CREATE PAYMENT");
  //       }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: primaryColor,
        title: Text("Cart", style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: user == null
          ? Stack(
              children: [
                Container(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: list(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: list(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: list(),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 140,
                    padding: EdgeInsets.all(8),
                    color: white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              "PRICE DETAILS",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  color: color2),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              "Price - ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              "₹1000",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              "Discount - ",
                              style: TextStyle(fontSize: 13),
                            ),
                            Text(
                              promoDiscount + "%",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Amount",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    promoCode.text.isEmpty
                                        ? "₹ " + "$initial_total_amount"
                                        : "₹ " +
                                            total_amount.toStringAsFixed(2),
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: ElevatedBtn1(() {
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FeaturePackages()));
                              }, "Checkout"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(
              alignment: Alignment.center,
              child: Image.asset("assets/empty-cart.png"),
            ),
    );
  }

  Widget list() {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 130,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      decoration: BoxDecoration(
          color: white,
          border: Border.all(color: Colors.grey[350], width: 0.6),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Home applience - Power listing - 5 ads - 30 days - 8 days boost",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color2,
                fontFamily: "Poppins"),
          ),
          SizedBox(
            height: 7,
          ),
          Text(
            "Applicable for Home applience in all over India",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                "₹ 1990",
                maxLines: 1,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(
                Icons.delete,
                color: Colors.green[800],
              )
            ],
          ),
        ],
      ),
    );
  }
}
