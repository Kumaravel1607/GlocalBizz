import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/payment_model.dart';
import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentHistory extends StatefulWidget {
  PaymentHistory({Key key}) : super(key: key);

  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  var _listItems = <Widget>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  SharedPreferences prefs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getpaymentList();
    // _loadItems();
  }

  Future<void> _getpaymentList() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "store_id": prefs.getString("store_id"),
    };
    print(jsonEncode(data));
    var response =
        await http.post(Uri.parse(api_url + "/store_payments"), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      setState(() {
        _isLoading = true;
      });

      get_paymentlist(result).then((value) {
        setState(() {
          paymentList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<PaymentsModel> paymentList = List<PaymentsModel>();

  Future<List<PaymentsModel>> get_paymentlist(paymentListsJson) async {
    var paymentList = List<PaymentsModel>();
    for (var paymentListsJson in paymentListsJson) {
      paymentList.add(PaymentsModel.fromJson(paymentListsJson));
    }
    return paymentList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        title: Text("Payment History"),
        centerTitle: true,
      ),
      body: _isLoading
          ? SafeArea(
              child: paymentList.isNotEmpty
                  ? Stack(
                      children: [
                        Container(
                          color: black,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              // borderRadius: new BorderRadius.all(Radius.elliptical(100, 50)),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.elliptical(200, 60),
                                topRight: Radius.elliptical(200, 60),
                              ),
                            ),
                          ),
                        ),
                        AnimatedList(
                          key: _listKey,
                          padding: EdgeInsets.only(top: 10),
                          initialItemCount: paymentList.length,
                          itemBuilder: (context, index, animation) {
                            return SlideTransition(
                              position: CurvedAnimation(
                                curve: Curves.easeOut,
                                parent: animation,
                              ).drive((Tween<Offset>(
                                begin: Offset(1, 0),
                                end: Offset(0, 0),
                              ))),
                              // child: _listItems[index],
                              child: _paymentList(paymentList, index),
                            );
                          },
                        ),
                      ],
                    )
                  : Container(
                      child: Center(
                        child: Text(
                          "No Payment Details Found !!",
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            )
          : Loading(),
    );
  }

  void _loadItems() {
    // fetching data from web api, local db...
    final fetchedList = [
      // _paymentList(),
      // _paymentList(),
      // _paymentList(),
      // _paymentList(),
      // _paymentList(),
      // _paymentList()
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

  Widget _paymentList(List<PaymentsModel> paymentList, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey[350], width: 0.8)),
        child: ListTile(
          contentPadding:
              EdgeInsets.only(right: 7, left: 13, bottom: 8, top: 5),
          leading: Container(
            height: 40,
            width: 40,
            child: Icon(
              Icons.local_grocery_store,
              color: white,
            ),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          title: Text(
            paymentList[index].paymentStatus == 0
                ? "Pending"
                : paymentList[index].paymentStatus == 1
                    ? "Paid"
                    : "Failed",
            style: TextStyle(
                color: color2, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "( From: " +
                    paymentList[index].fromDate +
                    " - " +
                    "To: " +
                    paymentList[index].toDate +
                    " )",
                style: TextStyle(fontSize: 8),
              ),
              Text(
                "Paided at: " + paymentList[index].paidDate ?? "--",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: Container(
            alignment: Alignment.centerRight,
            // height: 50,
            width: 93,
            // color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  paymentList[index].paidAmount.toString(),
                  style: TextStyle(
                      color: color2, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  width: 2,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
