import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Controller/location_controller.dart';
import 'package:glocal_bizz/Model/Store_model.dart';
import 'package:glocal_bizz/View/CreateStore/Checked.dart';
import 'package:glocal_bizz/View/CreateStore/MyStoreDetail.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'Checked.dart';
import 'package:location/location.dart' as locationPackage;

class WorkingDays {
  const WorkingDays(this.name, this.workingValue);
  final String name;
  final String workingValue;
}

class CreateStore extends StatefulWidget {
  CreateStore({Key key}) : super(key: key);

  @override
  _CreateStoreState createState() => _CreateStoreState();
}

class _CreateStoreState extends State<CreateStore> {
  final TextEditingController shopname = new TextEditingController();
  final TextEditingController username = new TextEditingController();
  final TextEditingController shopAddress = new TextEditingController();
  final TextEditingController location = new TextEditingController();

  final TextEditingController ownerName = new TextEditingController();
  final TextEditingController contactNo = new TextEditingController();
  final TextEditingController email = new TextEditingController();
  final TextEditingController aboutShop = new TextEditingController();
  final TextEditingController pincode = new TextEditingController();
  final TextEditingController businessSince = new TextEditingController();
  final TextEditingController workFrom = new TextEditingController();
  final TextEditingController deliverFees = new TextEditingController();
  final TextEditingController workTo = new TextEditingController();
  final TextEditingController store_lat = new TextEditingController();
  final TextEditingController store_long = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  int doorStep = 0;
  String storeLogo;
  File storeLogoFile;
  String storeBanner;
  String cityID;
  bool _isLoading = false;
  bool _submitLoading = true;
  String lat_store;
  String long_store;

  final List<WorkingDays> _cast = <WorkingDays>[
    const WorkingDays('SUN', '1'),
    const WorkingDays('MON', '2'),
    const WorkingDays('TUE', '3'),
    const WorkingDays('WED', '4'),
    const WorkingDays('THU', '5'),
    const WorkingDays('FRI', '6'),
    const WorkingDays('SAT', '7'),
  ];
  List<String> _workingfilters = <String>[];

  Iterable<Widget> get workingWidgets sync* {
    for (final WorkingDays working in _cast) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
          // avatar: CircleAvatar(child: Text(actor.workingValue)),
          label: Text(working.name),
          selected: _workingfilters.contains(working.workingValue),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _workingfilters.add(working.workingValue);
              } else {
                _workingfilters.removeWhere((String workingValue) {
                  return workingValue == working.workingValue;
                });
              }
            });
          },
        ),
      );
    }
  }

  final picker = ImagePicker();
  void open_gallery() async {
    // var image = await picker.getImage(source: ImageSource.gallery);
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 70);
    var imagepath = File(pickedFile.path);
    setState(() {
      storeLogoFile = imagepath;
      print("==============NK==========");
      print(storeLogoFile);
      storeLogo = base64Encode(imagepath.readAsBytesSync());
    });
    print(storeLogo);
  }

  File bannerimage;

  void open_banner() async {
    // var image = await picker.getImage(source: ImageSource.gallery);
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 70);
    var imagepath = File(pickedFile.path);
    setState(() {
      bannerimage = File(pickedFile.path);
      storeBanner = base64Encode(imagepath.readAsBytesSync());
    });
  }

  void _createStore(
    store_name,
    deliver,
    address,
    location,
    ownername,
    stor_email,
    contactNo,
    aboutus,
    since,
    postalcode,
    workdays,
    f_time,
    t_time,
    deliveryfees,
    lat,
    long,
  ) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      'store_name': store_name,
      'store_logo': storeLogo,
      'store_banner': storeBanner,
      'delivery_option': deliver,
      'store_address': address,
      'shop_city_id': location,
      'owner_name': ownername,
      'store_email': stor_email,
      'store_contact': contactNo,
      'about_us': aboutus,
      'business_since': since,
      'pincode': postalcode,
      'working_days': workdays,
      'from_time': f_time,
      'to_time': t_time,
      'delivery_fee': deliveryfees,
      'latitude': lat ?? "",
      'longitude': long ?? "",
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/create_store"), body: data);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = true;
        _submitLoading = true;
      });
      print(jsonResponse);
      prefs.setString("store_id", jsonResponse['store_id'].toString());
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('New Store Created'),
        ),
      );

      Navigator.of(context, rootNavigator: true).pushReplacement(
          CupertinoPageRoute(
              builder: (_) => Checked(
                  storeName: store_name,
                  image: storeLogoFile,
                  address: address)));
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
                    _isLoading = true;
                  });
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

  TimeOfDay _timeFrom = TimeOfDay(hour: 9, minute: 00);

  void _selectTimeFrom() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _timeFrom,
    );
    // print("-----NK-------");
    // print(newTime);
    if (newTime != null) {
      setState(() {
        _timeFrom = newTime;
        workFrom.text = '${_timeFrom.format(context)}';
      });
      // print(newTime);
    }
  }

  TimeOfDay _timeTo = TimeOfDay(hour: 6, minute: 00);

  void _selectTimeTo() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _timeTo,
    );
    if (newTime != null) {
      setState(() {
        _timeTo = newTime;
        workTo.text = '${_timeTo.format(context)}';
        print(workTo.text);
      });
    }
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
      _permissionGranted =
          (await _locationService.requestPermission()) as PermissionStatus;
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await _locationService.getLocation();
    print("-------------NK---------------");
    print(_locationData.latitude + _locationData.longitude);
    setState(() {
      lat_store = _locationData.latitude.toString();
      long_store = _locationData.longitude.toString();
    });
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: const Text('Your Store Location Fetched!!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: primaryColor,
            iconTheme: IconThemeData(color: white),
            title: Text(
              "ADD YOUR BUSINESS DETAILS",
              style: TextStyle(color: white),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            print("object");
                            open_gallery();
                          },
                          child: storeLogoFile == null
                              ? Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: EdgeInsets.all(5),
                                  height: 110,
                                  width: 110,
                                  decoration: BoxDecoration(
                                      // image: DecorationImage(
                                      //     image: AssetImage("assets/camera.png"),
                                      //     fit: BoxFit.cover),
                                      border: Border.all(color: primaryColor),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/camera.png",
                                        width: 70,
                                        height: 70,
                                      ),
                                      Text(
                                        "+ ADD LOGO",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: EdgeInsets.all(5),
                                  height: 120,
                                  width: 110,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: primaryColor),
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                          image: FileImage(storeLogoFile),
                                          fit: BoxFit.cover)),
                                ),
                        ),
                        SizedBox(
                          width: 45,
                        ),
                        InkWell(
                          onTap: () {
                            print("object");
                            open_banner();
                          },
                          child: bannerimage == null
                              ? Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: EdgeInsets.all(5),
                                  height: 110,
                                  width: 160,
                                  decoration: BoxDecoration(
                                      // image: DecorationImage(
                                      //     image: AssetImage("assets/camera.png"),
                                      //     fit: BoxFit.cover),
                                      border: Border.all(color: primaryColor),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/camera.png",
                                        width: 70,
                                        height: 70,
                                      ),
                                      Text(
                                        "+ ADD BANNER",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: EdgeInsets.all(5),
                                  height: 120,
                                  width: 160,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: primaryColor),
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                          image: FileImage(bannerimage),
                                          fit: BoxFit.cover)),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter store name';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: shopname,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration:
                          textDecoration('Shop Name', 'Enter your shop name *'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter owner name';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: ownerName,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: textDecoration('Owner Name', 'Owner Name *'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: email,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: textDecoration('Email', 'Email *'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter contact no';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: contactNo,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: textDecoration('Mobile No', 'Mobile No *'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter about us';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: aboutShop,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: textDecoration('About us', 'About us *'),
                    ),

                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter business since';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: businessSince,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration:
                          textDecoration('Business Since', 'Business Since *'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter shop address';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: shopAddress,
                      onTap: () {},
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: textDecoration(
                          'Address', 'Enter Your Shop Address *'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter pincode';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: pincode,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: textDecoration('Pincode', 'Pincode *'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Working Days *",
                      style: TextStyle(color: color2, fontSize: 14),
                    ),
                    Wrap(
                      children: workingWidgets.toList(),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Working Hours *",
                      style: TextStyle(color: color2, fontSize: 14),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'select working hours';
                                }
                                return null;
                              },
                              focusNode: AlwaysDisabledFocusNode(),
                              controller: workFrom,
                              decoration: textDecoration(
                                'From :',
                                'From :',
                              ),
                              onTap: () {
                                _selectTimeFrom();
                                // setState(() {
                                //   workFrom.text = '${_time.format(context)}';
                                // });
                              }),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'select working hours';
                                }
                                return null;
                              },
                              focusNode: AlwaysDisabledFocusNode(),
                              controller: workTo,
                              decoration: textDecoration('To :', "To :"),
                              onTap: () {
                                _selectTimeTo();
                                // setState(() {
                                //   workTo.text = '${_time.format(context)}';
                                // });
                              }),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter Delivery Charge';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: deliverFees,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      decoration:
                          textDecoration('Delivery Charge', 'Delivery Charge'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please choose location';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: location,
                      onTap: _showLocation,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: textDecoration('Location', 'Choose Loaction'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Door Step Services",
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio(
                          value: 1,
                          groupValue: doorStep,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              doorStep = value;
                              print(doorStep);
                            });
                          },
                        ),
                        Text(
                          "Yes",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: black,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Radio(
                          value: 0,
                          groupValue: doorStep,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              doorStep = value;
                              print(doorStep);
                            });
                          },
                        ),
                        Text(
                          "NO",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: black,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     open_banner();
                    //     print("NK");
                    //   },
                    //   child: Container(
                    //     alignment: Alignment.center,
                    //     width: double.infinity,
                    //     height: 50,
                    //     padding: EdgeInsets.all(5),
                    //     decoration: BoxDecoration(
                    //         border: Border.all(color: primaryColor, width: 1.5),
                    //         borderRadius: BorderRadius.circular(10)),
                    //     child: Text(
                    //       "Add Shop Banner",
                    //       style: TextStyle(
                    //           color: primaryColor, fontWeight: FontWeight.w600),
                    //     ),
                    //   ),
                    // ),
                    // bannerimage != null
                    //     ? Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: SizedBox(
                    //             height: 50,
                    //             width: 50,
                    //             child: Image.file(bannerimage)),
                    //       )
                    //     : SizedBox(),
                    SizedBox(
                      height: 45,
                    ),
                    Center(
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          child:
                              ElevatedBtn1(getLocation, "Get Store Location")),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: ElevatedBtn1(submitButton, "Submit")),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        _submitLoading ? SizedBox() : FullScreenLoading(),
      ],
    );
  }

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (storeLogo != null && storeBanner != null) {
        setState(() {
          _submitLoading = false;
        });
        _createStore(
          shopname.text,
          "$doorStep",
          shopAddress.text,
          cityID,
          ownerName.text,
          email.text,
          contactNo.text,
          aboutShop.text,
          businessSince.text,
          pincode.text,
          "${_workingfilters.join(',')}",
          workFrom.text,
          workTo.text,
          deliverFees.text,
          lat_store,
          long_store,
        );
      } else {
        _alerDialog("Please check logo and banner.");
      }
    }
  }

  void _closeModal(void value) {
    print('modal closed');
    // Navigator.pop(context);
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
            child: SingleChildScrollView(
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
                  // ListTile(
                  //   contentPadding: EdgeInsets.all(0),
                  //   minVerticalPadding: 0,
                  //   leading: Icon(
                  //     Icons.my_location_outlined,
                  //     color: Colors.indigo[900],
                  //   ),
                  //   title: Text(
                  //     "Use Current Location",
                  //     style: TextStyle(
                  //       fontSize: 15.0,
                  //       color: Colors.indigo[900],
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  //   subtitle: Text("Enable Location...",
                  //     style: TextStyle(
                  //       fontSize: 12.0,
                  //       color: color2,
                  //     ),
                  //   ),
                  //   onTap: getLocation,
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
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
                          controller: location,
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
                          cityID = item.id;
                          location.text = item.city_name;
                          print(item.city_name);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
