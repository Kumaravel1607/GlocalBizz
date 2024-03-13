import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Add_AddressPage extends StatefulWidget {
  @override
  _Add_AddressPageState createState() => _Add_AddressPageState();
}

class _Add_AddressPageState extends State<Add_AddressPage> {
  bool passwordVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _password;

  final TextEditingController nameController = new TextEditingController();
  final TextEditingController lastnameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController mobileController = new TextEditingController();
  final TextEditingController addressController = new TextEditingController();
  final TextEditingController addressController2 = new TextEditingController();
  final TextEditingController cityController = new TextEditingController();
  final TextEditingController landmarkController = new TextEditingController();
  final TextEditingController postalController = new TextEditingController();

  SharedPreferences prefs;
  bool _isLoading = false;
  bool _submitLoad = true;
  int addressType = 1;

  @override
  void initState() {
    super.initState();
  }

  void _createAddress(
      fname, lname, mNo, mail, add1, add2, city, postCode, landmark) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "customer_id": prefs.getString("user_id"),
      'first_name': fname,
      'last_name': lname,
      'mobile_no': mNo,
      'email': mail,
      'address1': add1,
      'address2': add2,
      'city': city,
      'pincode': postCode,
      'landmark': landmark,
      'address_type': addressType.toString(),
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/create_address"), body: data);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = true;
        _submitLoad = true;
      });
      Navigator.pop(context);

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Your address created'),
        ),
      );
    } else if (response.statusCode == 400) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              ErrorPage(data: response.body.toString())));
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              ErrorPage(data: response.body.toString())));
    } else if (response.statusCode == 500) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => ErrorPage(
              data: 'Error occured while communication with server' +
                  ' with status code : ${response.statusCode}')));
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
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _submitLoad = true;
                  });
                  Navigator.pop(context, "ok");
                },
                child: const Text("OK"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: new IconThemeData(
          color: white,
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              // size: 26,
              color: white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("Add Address",
            style: TextStyle(
              color: white,
              // fontSize: 22.0,
              // fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              // color: primaryColor,
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.fromLTRB(30, 10, 30, 25),
              child: Form(
                key: _formKey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Create New Delivery Address',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: color2),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please fill the required field';
                        }
                        return null;
                      },
                      controller: nameController,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'First Name',
                        labelText: 'First Name',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    //),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please fill the required field';
                        }
                        return null;
                      },
                      controller: lastnameController,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'Last Name',
                        labelText: 'Last Name',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    //),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please fill the required field';
                        }
                        return null;
                      },
                      controller: mobileController,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'Mobile Number',
                        labelText: 'Mobile Number',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    //),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      controller: emailController,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'E-mail',
                        labelText: 'Email',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    //),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please fill the required field';
                        }
                        return null;
                      },
                      controller: addressController,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      // maxLines: 2,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        // labelText: 'Address',
                        // labelStyle: TextStyle(
                        //   color: Color(0xFF1A1236),
                        //   fontSize: 14,
                        // ),
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'Address*',
                        labelText: 'Address',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      // validator: (value) {
                      //   if (value.isEmpty) {
                      //     return 'Please fill the required field';
                      //   }
                      //   return null;
                      // },
                      controller: addressController2,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      // maxLines: 2,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        // labelText: 'Address',
                        // labelStyle: TextStyle(
                        //   color: Color(0xFF1A1236),
                        //   fontSize: 14,
                        // ),
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'Address 2',
                        labelText: 'Address 2',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    //),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please fill the required field';
                        }
                        return null;
                      },
                      controller: cityController,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        // labelText: 'City',
                        // labelStyle: TextStyle(
                        //   color: Color(0xFF1A1236),
                        //   fontSize: 14,
                        // ),
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'City / District / Town',
                        labelText: 'City',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please fill the required field';
                        }
                        return null;
                      },
                      controller: landmarkController,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        // labelText: 'State',
                        // labelStyle: TextStyle(
                        //   color: Color(0xFF1A1236),
                        //   fontSize: 14,
                        // ),
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'Landmark',
                        labelText: 'Landmark',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please fill the required field';
                        }
                        return null;
                      },
                      controller: postalController,
                      cursorColor: color2,
                      strutStyle: StrutStyle(leading: 0),
                      obscureText: false,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        // labelText: 'Postal Code',
                        // labelStyle: TextStyle(
                        //   color: Color(0xFF1A1236),
                        //   fontSize: 14,
                        // ),
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        hintText: 'Postal Code',
                        labelText: 'Pincode',
                        hintStyle: TextStyle(
                          color: color2,
                        ),
                        border: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderSide:
                              new BorderSide(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio(
                          value: 1,
                          groupValue: addressType,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              addressType = value;
                              print(addressType);
                            });
                          },
                        ),
                        Text(
                          "Home",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: black,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Radio(
                          value: 2,
                          groupValue: addressType,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              addressType = value;
                              print(addressType);
                            });
                          },
                        ),
                        Text(
                          "Office",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: black,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 50,
                    ),
                    Container(
                        width: double.infinity,
                        child: ElevatedBtn1(submit, "Submit")),

                    SizedBox(height: 15.0),
                  ],
                ),
              ),
            ),
          ),
          _submitLoad ? SizedBox() : FullScreenLoading(),
        ],
      ),
    );
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _submitLoad = false;
      });
      _createAddress(
          nameController.text,
          lastnameController.text,
          mobileController.text,
          emailController.text,
          addressController.text,
          addressController2.text.isNotEmpty ? addressController2.text : "",
          cityController.text,
          postalController.text,
          landmarkController.text);
    }
  }
}
