import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/Model/transaction_model.dart';
import 'package:glocal_bizz/View/Add%20Package/Packages.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionList extends StatefulWidget {
  TransactionList({Key key}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transaction_list();
  }

  void transaction_list() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
    };
    print(data);
    var response;
    response =
        await http.post(Uri.parse(api_url + "/order_history"), body: data);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print("-----NK-----");
      print(result);
      setState(() {
        _isLoading = true;
      });

      get_transactionsList(result).then((value) {
        setState(() {
          transactionsList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("error");
    }
  }

  List<TransactionModel> transactionsList = List<TransactionModel>();

  Future<List<TransactionModel>> get_transactionsList(transactionssJson) async {
    var transactionss = List<TransactionModel>();
    for (var transactionsJson in transactionssJson) {
      transactionss.add(TransactionModel.fromJson(transactionsJson));
    }
    return transactionss;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f8f8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: white),
        title: Text(
          "My Order List",
          style: TextStyle(color: white, fontFamily: "Poppins"),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? new ListView.builder(
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              itemCount: transactionsList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    title: Text(
                      transactionsList[index].package_name != null
                          ? transactionsList[index].package_name
                          : "Order Name",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                          color: color2),
                    ),
                    subtitle: Text(
                      transactionsList[index].order_no != null
                          ? "Order No: " + transactionsList[index].order_no
                          : "",
                      style: TextStyle(fontSize: 11.5),
                    ),
                    // trailing: Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () {
                      _showMessage(
                        transactionsList[index].package_name != null
                            ? transactionsList[index].package_name
                            : "Order Name",
                        transactionsList[index].order_no != null
                            ? transactionsList[index].order_no
                            : "--",
                        transactionsList[index].total_amount != null
                            ? double.parse(
                                transactionsList[index].total_amount.toString())
                            : "--",
                        transactionsList[index].transcation_id != null
                            ? transactionsList[index].transcation_id.toString()
                            : "--",
                      );
                    },
                  ),
                );
              })
          : Center(
              child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
            )),
    );
  }

  void _showMessage(pkgname, orderno, totalamount, transactionid) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(30.0),
                topRight: const Radius.circular(30.0)),
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
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TRANSACTION DETAILS",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            // color: color2,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 13,
                      ),
                      Text(
                        "PACKAGE NAME: " + pkgname,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "ORDER NO: " + orderno,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "TOTAL AMOUNT: " + totalamount,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "TRANSACTION ID: " + transactionid,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  )),
            );
          });
    });
  }
}
