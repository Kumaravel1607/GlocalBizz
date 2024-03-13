import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Controller/location_controller.dart';
import 'package:glocal_bizz/Model/profile_model.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController name = new TextEditingController();
  final TextEditingController lastname = new TextEditingController();
  final TextEditingController email = new TextEditingController();
  final TextEditingController mobile = new TextEditingController();
  final TextEditingController currentlocation = new TextEditingController();
  SharedPreferences prefs;

  String _gender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserDetail();
  }

  String image;
  String username;
  String cityID;

  Future<UserDetails> getUserDetail() async {
    prefs = await SharedPreferences.getInstance();
    // var jsonResponse = null;
    Map data = {
      'customer_id': prefs.getString("user_id"),
    };
    print(data);
    var response;
    response = await http.post(Uri.parse(api_url + "/customer"), body: data);
    print(response.body.toString());

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = true;
      });
      var userDetail = (json.decode(response.body));
      print(userDetail);

      setState(() {
        _gender = (userDetail['gender']);
        image = (userDetail['profile_image']);
      });

      name.text = (userDetail['first_name']);
      lastname.text = (userDetail['last_name']);
      // mobile.text = userDetail['mobile'] != null ? (userDetail['mobile']) : "";
      email.text = (userDetail['email']);
      cityID = (userDetail['city']);
      currentlocation.text = (userDetail['city_name']);
      if (userDetail['mobile'] != null || userDetail['mobile'] != "") {
        mobile.text = userDetail['mobile'];
      }

      return UserDetails.fromJson(userDetail);
    } else {
      setState(() {
        _isLoading = false;
      });
      // throw Exception('Failed to load post');
    }
  }

  Future<void> update_user(
    fname,
    lname,
    mnumber,
    gender,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': sharedPreferences.getString("user_id"),
      'first_name': fname,
      'last_name': lname,
      'mobile': mnumber,
      'gender': gender,
      'city': cityID,
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/update_customer"), body: data);

    if (response.statusCode == 200) {
      // setState(() {
      //   _isLoading = false;
      // });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Profile updated.'),
        ),
      );
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse != null) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _alerDialog(jsonResponse['message']);
    }
  }

  Future<void> upload_image(imgpath) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      'profile_image': imgpath,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/update_profile"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('profile pic updated'),
        ),
      );
      print("profile pic updated");
      getUserDetail();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final picker = ImagePicker();
  void open_gallery() async {
    // var image = await picker.getImage(source: ImageSource.gallery);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    var image = File(pickedFile.path);
    _cropImage(pickedFile.path);
    // setState(() {
    //   image.readAsBytesSync() != null
    //       ? upload_image(base64Encode(image.readAsBytesSync()))
    //       : '';
    // });
  }

  Future<Null> _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        compressQuality: 50,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                // CropAspectRatioPreset.ratio3x2,
                // CropAspectRatioPreset.original,
                // CropAspectRatioPreset.ratio4x3,
                // CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Profile Pic',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Profile Pic',
        ));
    if (croppedImage != null) {
      setState(() {
        upload_image(base64Encode(croppedImage.readAsBytesSync()));
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
                child: const Text("OK"),
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
              OutlinedButton(
                onPressed: () {
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
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        child: _isLoading
            ? Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Edit Your Profile",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: color2,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 52,
                                  backgroundColor: primaryColor,
                                  child: CircleAvatar(
                                    backgroundColor: white,
                                    radius: 49,
                                    backgroundImage: image != null
                                        ? NetworkImage(image)
                                        : AssetImage(
                                            'assets/profile.jpg',
                                          ),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 53,
                                  backgroundColor: Colors.black12,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 75, top: 55),
                                    child: GestureDetector(
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: primaryColor,
                                        child: Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: white,
                                        ),
                                      ),
                                      onTap: () {
                                        open_gallery();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter First Name';
                                }
                                return null;
                              },
                              cursorHeight: 18,
                              onSaved: (String value) {},
                              controller: name,
                              obscureText: false,
                              onTap: () {},
                              style: TextStyle(
                                fontSize: 14.0,
                                color: black,
                              ),
                              keyboardType: TextInputType.text,
                              decoration:
                                  textDecoration('First Name', 'First Name'),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter Last Name';
                                }
                                return null;
                              },
                              cursorHeight: 18,
                              onSaved: (String value) {},
                              controller: lastname,
                              obscureText: false,
                              onTap: () {},
                              style: TextStyle(
                                fontSize: 14.0,
                                color: black,
                              ),
                              keyboardType: TextInputType.text,
                              decoration:
                                  textDecoration('Last Name', 'Last Name'),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter Mobile number';
                                }
                                return null;
                              },
                              cursorHeight: 18,
                              onSaved: (String value) {},
                              controller: mobile,
                              obscureText: false,
                              onTap: () {},
                              style: TextStyle(
                                fontSize: 14.0,
                                color: black,
                              ),
                              keyboardType: TextInputType.text,
                              decoration: textDecoration(
                                  'Mobile Number', 'Mobile number'),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              // textInputAction: TextInputAction.none,
                              enabled: false,
                              // validator: (value) {
                              //   if (value.isEmpty) {
                              //     return 'Please enter Last Name';
                              //   }
                              //   return null;
                              // },
                              cursorHeight: 18,
                              onSaved: (String value) {},
                              controller: email,
                              obscureText: false,
                              onTap: () {},
                              style: TextStyle(
                                fontSize: 14.0,
                                color: black,
                              ),
                              keyboardType: TextInputType.text,
                              decoration: textDecoration('Email', 'Email'),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            DropdownButtonFormField<String>(
                              value: _gender,
                              decoration: textDecoration("Gender", "Gender"),
                              items: <String>[
                                'Male',
                                'Female',
                                'Others',
                              ]
                                  .map((String value) =>
                                      DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _gender = newValue;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Please select the Gender'
                                  : null,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please choose your location';
                                }
                                return null;
                              },
                              cursorHeight: 18,
                              onSaved: (String value) {},
                              controller: currentlocation,
                              obscureText: false,
                              onTap: _showLocation,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: black,
                              ),
                              keyboardType: TextInputType.text,
                              decoration: textDecoration(
                                  'Current Location', 'Current Location'),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: ElevatedBtn1(submitButton, "SAVE")),
                    ),
                  )
                ],
              )
            : Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  backgroundColor: primaryColor,
                  valueColor: new AlwaysStoppedAnimation<Color>(white),
                ),
              ),
      ),
    );
  }

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print("-------");
      update_user(
        name.text,
        lastname.text,
        mobile.text,
        _gender,
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
