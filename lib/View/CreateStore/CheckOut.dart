import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/Controller/constand.dart';

class CheckOutPage extends StatefulWidget {
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFFFFFFFF),
      //   elevation: 0,
      //   iconTheme: new IconThemeData(
      //     color: appcolor,
      //   ),
      //   leading: IconButton(
      //       icon: Icon(
      //         Icons.close,
      //         size: 26,
      //         color: appcolor,
      //       ),
      //       onPressed: () {
      //         Navigator.of(context).pushReplacement(
      //             MaterialPageRoute(builder: (BuildContext context) => Home()));
      //       }),
      // ),
      body: Container(
        color: Color(0xFFFFFFFF),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/done.png",
              width: 135,
              height: 135,
              color: primaryColor,
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              'Congratulations',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: color2,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Your Payment is Complete",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF6C6C77),
              ),
            ),
            Text(
              "Please Check the Delivery Status",
              style: TextStyle(
                fontSize: 14,
                color: appcolor,
              ),
            ),
            SizedBox(
              height: 70,
            ),
            ButtonTheme(
              minWidth: 400,
              child: RaisedButton(
                  color: primaryColor,
                  elevation: 5,
                  child: Text(
                    'CONTINUE SHOPPING',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(
                      color: primaryColor,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 13.0, 15.0, 13.0),
                  onPressed: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (BuildContext context) => Home()));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
