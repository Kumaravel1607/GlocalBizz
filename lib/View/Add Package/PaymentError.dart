import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/BottomTab.dart';

class PaymenError extends StatefulWidget {
  PaymenError({Key key}) : super(key: key);

  @override
  PaymenErrorState createState() => PaymenErrorState();
}

class PaymenErrorState extends State<PaymenError> {
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
                "assets/remove.png",
                height: 80,
                width: 80,
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                "Transaction Failed !!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26, color: black, fontWeight: FontWeight.bold),
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
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: RaisedButton(
              //     color: green,
              //     onPressed: (){},
              //     child: Text("Go To Home", style: TextStyle(color: white),),),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
