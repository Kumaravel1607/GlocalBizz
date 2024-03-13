import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/Add%20Package/Packages.dart';
import 'package:glocal_bizz/View/BottomTab.dart';
import 'package:glocal_bizz/View/MyPosts.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';

import 'Add Package/CategoryPackage.dart';

class PostDone extends StatefulWidget {
  final String cat_id;
  final String ads_id;
  PostDone({Key key, this.cat_id, this.ads_id}) : super(key: key);
  @override
  _PostDoneState createState() => _PostDoneState();
}

class _PostDoneState extends State<PostDone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/checked.png",
              height: 50,
              width: 50,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "CONGRATULATIONS !",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryColor,
                fontSize: 22,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Your ad will go live shortly ",
              style: TextStyle(
                  fontSize: 16, color: color2, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 50,
            ),
            Image.asset(
              "assets/tag.png",
              height: 130,
              width: 130,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Reach more buyers and sell faster ",
              style: TextStyle(
                  fontSize: 15, color: color2, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Upgrade your Ad to top position",
              style: TextStyle(
                  fontSize: 13, color: color2, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pushReplacement(CupertinoPageRoute(
                          builder: (_) => SelectPackages(
                                title: "Feature Package",
                                pkg_type: "1",
                                category_id: widget.cat_id,
                                ads_id: widget.ads_id,
                              )));
                },
                child: Text(
                  "Sell Faster Now",
                  style: TextStyle(
                      fontSize: 16,
                      // fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    primary: color2,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: ElevatedBtn1(detailButton, "Preview Ad")),
            SizedBox(
              height: 15,
            ),
            Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: ElevatedBtn1(homeButton, "Go to Home")),
          ],
        ),
      ),
    );
  }

  void homeButton() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => BottomTab()),
        (Route<dynamic> route) => false);
  }

  void detailButton() {
    Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => MyPostPage()));
  }
}
