import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/Regiaster.dart';
import 'package:glocal_bizz/View/Authentication/SetNewPassword.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'BottomTab.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final int otp;
  final String userID;
  final int status;
  OtpPage({Key key, this.phone, this.otp, this.userID, this.status})
      : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController otpNumber = new TextEditingController();

  bool _isLoading = false;
  String _code;

  @override
  void initState() {
    _getData();
  }

  void _getData() async {
    await SmsAutoFill().listenForCode;
    // otpNumber.text = widget.otp.toString();
  }

  // check_otp(
  //   otp,
  // ) async {
  //   Map data = {
  //     'mobile_no': widget.phone,
  //   };

  //   var jsonResponse = null;
  //   var response =
  //       await http.post(Uri.parse(api_url + "/check_otp"), body: data);
  //   // jsonResponse = json.decode(response.body);

  //   if (response.statusCode == 200) {
  //     jsonResponse = json.decode(response.body);
  //     if (jsonResponse != null) {
  //       setState(() {
  //         _isLoading = true;
  //       });

  //       _alerDialog(jsonResponse['message']);

  //       Navigator.of(context).pushAndRemoveUntil(
  //           MaterialPageRoute(builder: (BuildContext context) => BottomTab()),
  //           (Route<dynamic> route) => false);
  //     }
  //   } else {
  //     jsonResponse = json.decode(response.body);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     _alerDialog(jsonResponse['message']);
  //   }
  // }

  Future<void> _alerDialog(message) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(message),
            //title: Text(),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, "ok");
                },
                child: const Text("OK"),
              )
            ],
          );
        });
  }

  void verifyButton() {
    if (widget.status == 1) {
      verifyForgetPass();
    } else {
      verifyMobile();
    }
  }

  void verifyMobile() {
    setState(() {
      _code = otpNumber.text;
    });
    if (otpNumber.text.isEmpty) {
      _alerDialog("Please enter OTP");
    } else if (otpNumber.text == widget.otp.toString()) {
      if (widget.userID == "") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    RegisterPage(mobilenumber: widget.phone)),
            (Route<dynamic> route) => false);
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //     builder: (BuildContext context) =>
        //         RegisterPage(mobilenumber: widget.phone)));
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => BottomTab()),
            (Route<dynamic> route) => false);
      }
    } else {
      _alerDialog("OTP is Not Match");
    }
  }

  void verifyForgetPass() {
    setState(() {
      _code = otpNumber.text;
    });
    if (otpNumber.text.isEmpty) {
      _alerDialog("Please enter OTP");
    } else if (otpNumber.text == widget.otp.toString()) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  SetNewPassword(email: widget.phone)),
          (Route<dynamic> route) => false);
    } else {
      _alerDialog("OTP is Not Match");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF7A11F),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    new Image.asset(
                      "assets/glocal_logo.png",
                      height: 170,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Glocal Bizz",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Verification Code",
                      style: TextStyle(
                          color: color2,
                          fontSize: 21,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please Enter the verification code \n send to: " +
                          widget.phone,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                // padding: EdgeInsets.only(left: 40, right: 40),
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Enter OTP",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: PinFieldAutoFill(
                            codeLength: 4,
                            decoration: BoxLooseDecoration(
                                strokeColorBuilder: FixedColorBuilder(
                                  Colors.black26,
                                ),
                                bgColorBuilder: FixedColorBuilder(Colors.white),
                                gapSpace: 30),
                            controller: otpNumber,
                            currentCode: _code,
                            onCodeSubmitted: (val) {
                              print(val);
                            },
                            onCodeChanged: (val) {
                              _code = val;
                              print(val);
                              if (val.length == 4) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              }
                            },
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: Padding(
                              padding: const EdgeInsets.all(35.0),
                              child: ElevatedBtn1(verifyButton, "Verify")
                              // ElevatedButton(
                              //   onPressed: () => Navigator.push(
                              //       context,
                              //       CupertinoPageRoute(
                              //           builder: (context) => BottomTab())),
                              //   child: Text(
                              //     "Verify",
                              //     style: TextStyle(
                              //         fontSize: 18, color: Colors.white),
                              //   ),
                              //   style: ElevatedButton.styleFrom(
                              //       elevation: 7,
                              //       shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(8)),
                              //       primary: color,
                              //       padding: EdgeInsets.symmetric(
                              //           horizontal: 15, vertical: 15),
                              //       textStyle: TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w500)),
                              // ),
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't get the code? ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "Resend",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: color,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
