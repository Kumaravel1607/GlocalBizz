import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:sms_autofill/sms_autofill.dart';

import '../OTP.dart';

class ForgetPass extends StatefulWidget {
  ForgetPass({
    Key key,
  }) : super(key: key);

  @override
  _ForgetPassState createState() => _ForgetPassState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController emailController = new TextEditingController();

class _ForgetPassState extends State<ForgetPass> {
  String _code;
  bool _isLoading = false;
  SharedPreferences sharedPreferences;

  @override
  void initState() {}

  void forget_pass(
    email,
  ) async {
    Map data = {
      'email': email,
    };

    var jsonResponse = null;
    var response =
        await http.post(Uri.parse(api_url + "/forget_password"), body: data);

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => OtpPage(
                phone: email,
                otp: jsonResponse['otp'],
                status: 1,
              )));

      print(jsonResponse);
    } else {
      jsonResponse = json.decode(response.body);
      _alerDialog(jsonResponse['message']);
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                child: const Text(
                  "OK",
                  style: TextStyle(color: color2),
                ),
              )
            ],
          );
        });
  }

  Future<void> _alerBox() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("please enter email"),
            //title: Text(),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, "ok");
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: color2),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: primaryColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                "assets/glocal_logo.png",
                height: 170,
                width: 170,
              ),
              // Text(
              //   "Forget Password",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //       fontSize: 24, fontWeight: FontWeight.bold, color: white),
              // ),
              SizedBox(
                height: 45,
              ),
              SizedBox(height: 5),
              TextFormField(
                onSaved: (String value) {},
                controller: emailController,
                obscureText: false,
                style: TextStyle(
                  fontSize: 16.0,
                  color: black,
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.mail,
                    color: primaryColor,
                  ),
                  fillColor: white,
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  hintText: ('Enter Your Email '),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: primaryColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedErrorBorder: new OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorBorder: new OutlineInputBorder(
                    borderSide: new BorderSide(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(
                height: 45,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: ElevatedBtn1(submitButton, "Recover password")),
              SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Back to Login",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitButton() async {
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (_) => OtpPage(phone: emailController.text)));
    final signcode = await SmsAutoFill().getAppSignature;
    if (emailController.text == '') {
      _alerBox();
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: primaryColor,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              width: 10,
            ),
            Text('Please Wait'),
          ],
        ),
      ));
      forget_pass(
        emailController.text,
      );
    }
  }
}
