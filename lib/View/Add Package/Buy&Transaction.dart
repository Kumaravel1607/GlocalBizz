import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/Add%20Package/CategoryPackage.dart';

import 'TransactionList.dart';

class BuyAndTransaction extends StatefulWidget {
  const BuyAndTransaction({Key key}) : super(key: key);

  @override
  _BuyAndTransactionState createState() => _BuyAndTransactionState();
}

class _BuyAndTransactionState extends State<BuyAndTransaction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: white),
        title: Text(
          "Invoices & Billing",
          style: TextStyle(color: white, fontFamily: "Poppins"),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 25),
                title: Text(
                  "Buy Packages",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                      color: color2),
                ),
                subtitle: Text(
                  "Sell faster, more & at higher margins with packages",
                  style: TextStyle(fontSize: 11.5),
                ),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(CupertinoPageRoute(
                          builder: (_) => CategoryPackage(
                                title: "Choose Package",
                                pkg_type: "2",
                              )));
                },
              ),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 25),
                title: Text(
                  "My Orders",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                      color: color2),
                ),
                subtitle: Text(
                  "View my transaction history",
                  style: TextStyle(fontSize: 11.5),
                ),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(builder: (_) => TransactionList()));
                },
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
