import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';

import 'AddProduct.dart';
import 'MyStoreDetail.dart';
import 'StoreDetail.dart';

class Checked extends StatefulWidget {
  final String storeName;
  final File image;
  final String address;
  Checked({Key key, this.storeName, this.image, this.address})
      : super(key: key);

  @override
  _CheckedState createState() => _CheckedState();
}

class _CheckedState extends State<Checked> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/checked.png",
                  height: 70,
                  width: 70,
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "Congratulations!",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  "Your Store is Created",
                  style: TextStyle(
                      fontSize: 22, color: color2, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(20),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Image.file(
                            widget.image,
                            height: 150,
                            width: 150,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            widget.storeName,
                            style: TextStyle(
                                fontSize: 20,
                                color: color2,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: color2,
                            ),
                          ),
                          // Text(
                          //   "Your store URL here:",
                          //   style: TextStyle(
                          //       color: Colors.blue[700], fontSize: 12),
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(CupertinoPageRoute(
                                      builder: (_) => MyStoreDetails()));
                            },
                            child: Text("Preview"),
                            style: ElevatedButton.styleFrom(primary: color2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: ElevatedBtn1(submitButton, "Finish")),
            ),
          )
        ],
      ),
    );
  }

  void submitButton() {
    Navigator.of(context).pop('ok');
    // Navigator.of(context, rootNavigator: true)
    //     .push(CupertinoPageRoute(builder: (_) => AddProduct()));
  }
}
