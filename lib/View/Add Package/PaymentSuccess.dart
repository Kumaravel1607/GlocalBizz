import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/BottomTab.dart';

class PaymenSuccesss extends StatefulWidget {
  PaymenSuccesss({Key key}) : super(key: key);

  @override
  PaymenSuccesssState createState() => PaymenSuccesssState();
}

class PaymenSuccesssState extends State<PaymenSuccesss> {
  bool btn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Image.asset(
                "assets/tick_icon@3x.png",
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                "Payment Success !!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26,
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              RaisedButton(
                color: primaryColor,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => BottomTab()),
                      (Route<dynamic> route) => false);
                },
                child: Text(
                  "Go To Home",
                  style: TextStyle(color: white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
