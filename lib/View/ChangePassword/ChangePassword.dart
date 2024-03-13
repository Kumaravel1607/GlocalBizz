import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ChangeNewPassword extends StatefulWidget {
  ChangeNewPassword({Key key}) : super(key: key);

  @override
  _ChangeNewPasswordState createState() => _ChangeNewPasswordState();
}

class _ChangeNewPasswordState extends State<ChangeNewPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newPassword = new TextEditingController();
  final TextEditingController oldPassword = new TextEditingController();
  final TextEditingController confirmPassword = new TextEditingController();

  SharedPreferences sharedPreferences;
  bool _isLoading = false;

  void change_pass(
    oldpass,
    newpass,
    confirmpass,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': sharedPreferences.getString("user_id"),
      'old_password': oldpass,
      'new_password': newpass,
      'confirm_password': confirmpass,
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/change_password"), body: data);
    if (response.statusCode == 200) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Password updated.'),
        ),
      );
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
      });
      jsonResponse = json.decode(response.body);
      _alerDialog(jsonResponse['message']);
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

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Set New Password",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "OLD Password",
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
                              return 'Please enter old password';
                            }
                            return null;
                          },
                          onSaved: (String value) {},
                          controller: oldPassword,
                          obscureText: false,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: black,
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            // prefixIcon: Icon(
                            //   Icons.lock_outlined,
                            //   color: primaryColor,
                            // ),
                            fillColor: white,
                            filled: true,
                            contentPadding:
                                EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            hintText: ('Old Password'),
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
                        SizedBox(height: 15),
                        Text(
                          "New Password",
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
                              return 'Please enter new password';
                            }
                            return null;
                          },
                          onSaved: (String value) {},
                          controller: newPassword,
                          obscureText: false,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: black,
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            // prefixIcon: Icon(
                            //   Icons.lock_outlined,
                            //   color: primaryColor,
                            // ),
                            fillColor: white,
                            filled: true,
                            contentPadding:
                                EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            hintText: ('New Password'),
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
                        SizedBox(height: 15),
                        Text(
                          "Confirm Password",
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
                              return 'Please enter confirm password';
                            }
                            return null;
                          },
                          onSaved: (String value) {},
                          controller: confirmPassword,
                          obscureText: true,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: black,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            // prefixIcon: Icon(
                            //   Icons.lock_outlined,
                            //   color: primaryColor,
                            // ),
                            fillColor: white,
                            filled: true,
                            contentPadding:
                                EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            hintText: ('Enter Confirm Password'),
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
                        SizedBox(height: 70),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: ElevatedBtn1(submitButton, "SUBMIT")),
                        SizedBox(
                          height: 15,
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

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (newPassword.text == confirmPassword.text) {
        change_pass(oldPassword.text, newPassword.text, confirmPassword.text);
      } else {
        _alerDialog("Password and confirm password not match");
      }
    }
  }
}
