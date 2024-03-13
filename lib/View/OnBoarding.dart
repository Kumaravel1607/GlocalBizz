import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'Login.dart';
import 'SpalshScreen.dart';

class IntroScreen extends StatefulWidget {
  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        backgroundColor: primaryColor,
        styleTitle: TextStyle(color: color2),
        widgetTitle: Container(
          padding: EdgeInsets.fromLTRB(2, 30, 10, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome To Glocal Bizz",
                style: TextStyle(
                    color: white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins"),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                height: 300,
                width: 350,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: new AssetImage(
                          "assets/boarding-1.png",
                        ),
                        fit: BoxFit.fill)),
              ),
              SizedBox(
                height: 50,
              ),
              new Text(
                "India’s No 1 Vocal for Local Marketplace App (Global + Local = Glocal)",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.white, fontFamily: "Poppins"),
              ),
            ],
          ),
        ),
      ),
    );
    slides.add(
      new Slide(
        backgroundColor: primaryColor,
        widgetTitle: Container(
          padding: EdgeInsets.fromLTRB(2, 30, 10, 2),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              Container(
                height: 300,
                width: 350,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: new AssetImage(
                          "assets/boarding-2.png",
                        ),
                        fit: BoxFit.fill)),
              ),
              SizedBox(
                height: 50,
              ),
              new Text(
                "Buy | Sell | Create Online Store",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              new Text(
                "Find Local Customer In Global Market",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: "Poppins",
                ),
              ),
              new Text(
                "Made in India App For an Aatma Nirbhar Bhaarat",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.white, fontFamily: "Poppins"),
              ),
            ],
          ),
        ),
      ),
    );
    slides.add(
      new Slide(
        backgroundColor: primaryColor,
        widgetTitle: Container(
          padding: EdgeInsets.fromLTRB(2, 20, 10, 2),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Text(
                    "Looking for something ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: "Poppins"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new Text(
                        "you",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontFamily: "Poppins"),
                      ),
                      new Text(
                        " need?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: "Poppins"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                height: 300,
                width: 350,
                // color: appcolor,
                decoration: BoxDecoration(
                    // color: appcolor,
                    image: DecorationImage(
                        image: new AssetImage(
                          "assets/boarding-3.png",
                        ),
                        fit: BoxFit.fill)),
              ),
              SizedBox(
                height: 50,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Text(
                    "Product New or Old, *Everything* is",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: "Poppins"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new Text(
                        " available",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: "Poppins"),
                      ),
                      new Text(
                        " here!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onDonePress() {
    print("Done");
    // Do what you want
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      colorDot: Color.fromRGBO(52, 196, 124, 0.5),
      colorActiveDot: white,
      // typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,
      // colorSkipBtn: Colors.amber,
      // styleNameSkipBtn: TextStyle(color: appcolor),
      // styleNameDoneBtn: TextStyle(color: appcolor),
      onDonePress: this.onDonePress,
      onSkipPress: this.onDonePress,
      slides: this.slides,
    );
  }
}
