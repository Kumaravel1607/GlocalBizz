import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Controller/location_controller.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as locationPackage;
import 'BottomTab.dart';

class RegisterPage extends StatefulWidget {
  final String mobilenumber;
  RegisterPage({Key key, this.mobilenumber}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController fname = new TextEditingController();
  final TextEditingController lname = new TextEditingController();
  final TextEditingController mobilenumber = new TextEditingController();
  final TextEditingController email = new TextEditingController();
  final TextEditingController password = new TextEditingController();
  final TextEditingController currentlocation = new TextEditingController();

  String _gender = '';
  String getCurrentAddress;

  String firebase_id;
  SharedPreferences sharedPreferences;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isLoading = false;
  SharedPreferences prefs;
  String cityID;

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
    mobilenumber.text = widget.mobilenumber;
  }

  void register(
    mobile,
    fname,
    lname,
    email,
    gender,
    pass,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'mobile_no': mobile,
      'first_name': fname,
      'last_name': lname,
      'email': email,
      'gender': gender,
      'app_id': firebase_id,
      'password': pass,
      'city': cityID,
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/register"), body: data);
    // print("------NK--------");
    // print(json.decode(response.body));

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse != null) {
        sharedPreferences.setString(
            "user_id", json.decode(response.body)['user_id'].toString());
        sharedPreferences.setString(
            "store_id", json.decode(response.body)['store_id'].toString());

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => BottomTab()),
            (Route<dynamic> route) => false);
        // _alerDialog(jsonResponse['message']);
      }
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

  Future<void> _alerBox() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Please fill Required field"),
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

  locationPackage.Location _locationService = new locationPackage.Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  locationPackage.LocationData _locationData;

  getLocation() async {
    _serviceEnabled = await _locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationService.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    if (_permissionGranted == PermissionStatus.denied) {
      setState(() {
        getCurrentAddress = "Enable Location";
      });
      _permissionGranted =
          (await _locationService.requestPermission()) as PermissionStatus;
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      getCurrentAddress = "Enable Location...";
    });
    _locationData = await _locationService.getLocation();
    print("-------------NK---------------");
    print(_locationData.latitude + _locationData.longitude);
    getAddress(_locationData.latitude, _locationData.longitude);
  }

  void getAddress(latitude, longitude) async {
    prefs = await SharedPreferences.getInstance();
    final coordinates = new Coordinates(latitude, longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    setState(() {
      currentlocation.text =
          first.subAdminArea.toString() + ', ' + first.adminArea.toString();
      getCityId(first.subAdminArea.toString());
    });
  }

  Future<void> getCityId(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'city_name': value,
    };
    print("My city id");
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/city_name"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        cityID = jsonResponse['id'].toString();
        print(cityID);
      });
      Navigator.pop(context);
    } else {
      _alerDialog("Your city is not found \n Please choose manully...");
      print("error");
      print(json.decode(response.body));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          "New Register",
          style: TextStyle(color: white),
        ),
        iconTheme: IconThemeData(color: white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 10, 25, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: fname,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration(
                          'First name',
                          'First Name *',
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: lname,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration(
                          'Last name',
                          'Last Name *',
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your Email';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: email,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: textDecoration(
                          'Email',
                          'E-mail *',
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your number';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: mobilenumber,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                        keyboardType: TextInputType.phone,
                        decoration: textDecoration(
                          'Mobile number',
                          'Mobile Number *',
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your Password';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: password,
                        obscureText: true,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration(
                          'Password',
                          'Password *',
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: textDecoration(
                          'Gender',
                          'Gender *',
                        ),
                        items: <String>[
                          'Male',
                          'Female',
                          'Others',
                        ]
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 16,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _gender = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select the Gender' : null,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: currentlocation,
                        onTap: _showLocation,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration(
                          'Current Location',
                          'Current Location *',
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 40),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: ElevatedBtn1(submitButton, "Submit")),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, color: black),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text('SignIn',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: primaryColor)),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
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
      register(
        mobilenumber.text,
        fname.text,
        lname.text,
        email.text,
        _gender,
        password.text,
      );
    }
  }

  void _showLocation() {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
            height: MediaQuery.of(context).size.height,
            color: white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Search Your Location",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: appcolor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  minVerticalPadding: 0,
                  leading: Icon(
                    Icons.my_location_outlined,
                    color: Colors.indigo[900],
                  ),
                  title: Text(
                    "Use Current Location",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    getCurrentAddress != null
                        ? getCurrentAddress
                        : "Enable Location...",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: color2,
                    ),
                  ),
                  onTap: getLocation,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 45,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200],
                      blurRadius: 5.0,
                      spreadRadius: 3.0,
                    ),
                  ]),
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        controller: currentlocation,
                        decoration: textDecoration2("Search Location")),
                    suggestionsCallback: (pattern) async {
                      print(pattern);
                      return await get_locationData(pattern);
                    },
                    itemBuilder: (context, item) {
                      return list(item);
                    },
                    onSuggestionSelected: (item) async {
                      setState(() {
                        currentlocation.text = item.city_name;
                        cityID = item.id;

                        print(item.id);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    print('modal closed');
    // Navigator.pop(context);
  }
}
