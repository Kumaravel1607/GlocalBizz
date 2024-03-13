import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/ElevatedButton.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'Authentication/ForgetPassword.dart';
import 'BottomTab.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Regiaster.dart';

class EmailLoginPage extends StatefulWidget {
  EmailLoginPage({Key key}) : super(key: key);

  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController emailmobileNumber = new TextEditingController();
final TextEditingController password = new TextEditingController();

class _EmailLoginPageState extends State<EmailLoginPage> {
  bool _isLoading = false;
  String firebase_id;
  SharedPreferences sharedPreferences;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    getMessage();
  }

  void getMessage() {
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        firebase_id = token;
      });
    });
  }

  void login(
    emailmobilenumber,
    pass,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'email': emailmobilenumber,
      'password': pass,
      'app_id': firebase_id,
    };

    print(data);

    var jsonResponse;
    var response = await http.post(Uri.parse(api_url + "/login"), body: data);
    jsonResponse = json.decode(response.body);
    print(jsonResponse);

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString(
            "user_id", jsonResponse['user_id'].toString());
        sharedPreferences.setString("user_name", jsonResponse['first_name']);
        sharedPreferences.setString("user_email", jsonResponse['email']);
        sharedPreferences.setString(
            "store_id", jsonResponse['store_id'].toString());

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => BottomTab()),
            (Route<dynamic> route) => false);
        emailmobileNumber.clear();
        password.clear();
      }
    } else {
      jsonResponse = json.decode(response.body);
      _alerDialog(jsonResponse['message']);
      emailmobileNumber.clear();
      password.clear();
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
              OutlinedButton(
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
            content: Text("Please Enter Mobile Number"),
            //title: Text(),
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(primary: primaryColor),
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
          decoration: BoxDecoration(
            color: primaryColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  children: [
                    new Image.asset(
                      "assets/glocal_logo.png",
                      height: 170,
                      width: 170,
                    ),
                    Text(
                      "Glocal Bizz",
                      style: TextStyle(
                          fontSize: 24,
                          color: color2,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "E-mail / Mobile Login",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: white),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                alignment: Alignment.bottomCenter,
                // height: 420,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Email / Mobile",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16,
                              color: black,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter Email / Mobile';
                            }
                            return null;
                          },
                          onSaved: (String value) {},
                          controller: emailmobileNumber,
                          obscureText: false,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: black,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.send_to_mobile,
                              color: primaryColor,
                            ),
                            fillColor: white,
                            filled: true,
                            contentPadding:
                                EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            hintText: ('Enter Email / Mobile'),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: new OutlineInputBorder(
                              borderSide: new BorderSide(
                                  color: primaryColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedErrorBorder: new OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorBorder: new OutlineInputBorder(
                              borderSide: new BorderSide(
                                  color: primaryColor, width: 1.5),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Password",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16,
                              color: black,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          onSaved: (String value) {},
                          controller: password,
                          obscureText: true,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: black,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: primaryColor,
                            ),
                            fillColor: white,
                            filled: true,
                            contentPadding:
                                EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            hintText: ('Enter Password'),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            border: new OutlineInputBorder(
                              borderSide: new BorderSide(
                                  color: primaryColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedErrorBorder: new OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorBorder: new OutlineInputBorder(
                              borderSide: new BorderSide(
                                  color: primaryColor, width: 1.5),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: ElevatedBtn1(submitButton, "LOGIN")),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: ElevatedButton(
                            onPressed: registerButton,
                            child: Text(
                              "REGISTER",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                primary: Colors.grey[600],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ForgetPass()));
                            },
                            child: Text(
                              "Forget Password ?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: black,
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
      login(emailmobileNumber.text, password.text);
    }
  }

  void registerButton() {
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => RegisterPage()));
  }
}
