import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/Add%20Package/PaymentError.dart';
import 'package:glocal_bizz/View/Add%20Package/PaymentSuccess.dart';
import 'package:glocal_bizz/View/BottomTab.dart';
import 'package:glocal_bizz/View/CreateStore/StorePaymentDone.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckOut extends StatefulWidget {
  final String orderId;
  final int amount;
  final String name;
  final String description;
  final String mobile;
  final String email;
  final int storeOrder;
  CheckOut(
      {Key key,
      this.orderId,
      this.amount,
      this.name,
      this.description,
      this.mobile,
      this.email,
      this.storeOrder})
      : super(key: key);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  static const platform = const MethodChannel("razorpay_flutter");

  Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    // print("Checkout details");
    // print(widget.name);
    // print(widget.description);
    // print(widget.amount);
    // print(widget.email);
    // print(widget.mobile);

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    openCheckout();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      // 'key': 'rzp_test_1DP5mmOlF5G5ag',
      'key': 'rzp_live_qtWCKtGdQDfp3M',
      'amount': widget.amount,
      'name': widget.name,
      'description': widget.description,
      'prefill': {'contact': widget.mobile, 'email': widget.email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void payment_success(transaction_id, pay_response) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'order_id': widget.orderId,
      'transcation_id': transaction_id,
      'payment_status': "1",
      'payment_response': pay_response,
    };
    print(data);
    var response;
    if (widget.storeOrder == 1) {
      response = await http.post(Uri.parse(api_url + "/store_update_order"),
          body: data);
    } else {
      response =
          await http.post(Uri.parse(api_url + "/update_order"), body: data);
    }

    print('json.decode(response.body)');
    print(json.decode(response.body));

    if (response.statusCode == 200) {
      var result = (json.decode(response.body));
      // print("pay success api done");
      // print(result);

      if (widget.storeOrder == 1) {
        Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(
                builder: (BuildContext context) => StorePayDone()));
      } else {
        Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(
                builder: (BuildContext context) => PaymenSuccesss()));
      }
    } else {
      print("pay success api error");
    }
  }

  void payment_failed(transaction_id, pay_response) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'order_id': widget.orderId,
      'transcation_id': transaction_id,
      'payment_status': "2",
      'payment_response': pay_response,
    };
    // print("---------------NK------------------");
    // print(data);
    var response;
    if (widget.storeOrder == 1) {
      response = await http.post(Uri.parse(api_url + "/store_update_order"),
          body: data);
    } else {
      response =
          await http.post(Uri.parse(api_url + "/update_order"), body: data);
    }

    if (response.statusCode == 200) {
      // var result = (json.decode(response.body));
      // print("pay  api failed");
      // print(result);

      Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => PaymenError()));
    } else {
      print("pay  api failed error");
      // print("ID ERROR");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Fluttertoast.showToast(
    //     msg: "SUCCESS: " + response.paymentId);
    print("payment successs");
    print(response.signature);
    print(response.orderId);

    payment_success(response.paymentId, response.orderId.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //     msg: "ERROR: " + response.code.toString() + " - " + response.message
    //    );
    print("payment error");
    print(response.message);
    payment_failed(response.code.toString(), response.message);
    // Navigator.of(context, rootNavigator: true).pushReplacement(
    //     MaterialPageRoute(builder: (BuildContext context) => PaymenError()));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName);
    print("EXTERNAL_WALLET: " + response.walletName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            alignment: Alignment.center,
            color: Color(0xFFf8f8f8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Processing...",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color2),
                ),
              ],
            )
            // child: RaisedButton(
            //   color: primaryColor,
            //   onPressed: () {
            //     Navigator.of(context).pushAndRemoveUntil(
            //         MaterialPageRoute(
            //             builder: (BuildContext context) => BottomTab()),
            //         (Route<dynamic> route) => false);
            //   },
            //   child: Text(
            //     "Go To Home",
            //     style: TextStyle(color: white),
            //   ),
            // ),
            ),
      ),
    );
  }
}
