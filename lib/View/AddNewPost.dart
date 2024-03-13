import 'dart:convert';
import 'dart:io';

// import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Controller/location_controller.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
// import 'package:glocal_bizz/Model/currency_model.dart';
import 'package:glocal_bizz/Model/profile_model.dart';
import 'package:glocal_bizz/View/PostDonePage.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';

import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as locationPackage;

class AddNewPost extends StatefulWidget {
  final String cat_id;
  final String subcat_id;
  final Map mapdata;
  final String productType;
  AddNewPost(
      {Key key, this.cat_id, this.subcat_id, this.mapdata, this.productType})
      : super(key: key);

  @override
  _AddNewPostState createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController title = new TextEditingController();
  final TextEditingController description = new TextEditingController();
  final TextEditingController street = new TextEditingController();
  final TextEditingController price = new TextEditingController();
  final TextEditingController location = new TextEditingController();
  final TextEditingController locationName = new TextEditingController();
  final TextEditingController contactName = new TextEditingController();
  final TextEditingController contactNumber = new TextEditingController();
  final TextEditingController contactEmail = new TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  int doorStep = 0;
  String cityID;
  bool _isLoading = false;
  bool _isSubmitLoading = true;

  String price_type = "";
  String product_type = "";
  String currency_type = "1";
  String _imagefileName;
  String getCurrentAddress;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currency_list();
    getUserDetail();
  }

  Position position;

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

  // String featureName;
  String addressLine;
  // String pincode;
  // String areaname;

  void getAddress(latitude, longitude) async {
    prefs = await SharedPreferences.getInstance();
    final coordinates = new Coordinates(latitude, longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    // print(first);
    // print(first.addressLine.toString());
    // print(first.adminArea.toString());
    // print(first.subAdminArea.toString());
    // print(first.locality.toString());
    setState(() {
      addressLine = first.addressLine.toString();
      location.text =
          first.subAdminArea.toString() + ', ' + first.adminArea.toString();
      locationName.text =
          first.subAdminArea.toString() + ', ' + first.adminArea.toString();
      getCityId(first.subAdminArea.toString());
    });
    await prefs.setString('userAddress', addressLine);
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

  Future<UserDetails> getUserDetail() async {
    prefs = await SharedPreferences.getInstance();
    // var jsonResponse = null;
    Map data = {
      'customer_id': prefs.getString("user_id"),
    };
    print(data);
    var response;
    response = await http.post(Uri.parse(api_url + "/customer"), body: data);

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = true;
      });
      var userDetail = (json.decode(response.body));
      contactName.text = (userDetail['first_name']);
      contactNumber.text = (userDetail['mobile']);
      contactEmail.text = (userDetail['email']);
      return UserDetails.fromJson(userDetail);
    } else {
      setState(() {
        _isLoading = false;
      });
      // throw Exception('Failed to load post');
    }
  }

  // List selectedimages = [];

  // Future addNewPost(
  //   serviceType,
  //   adname,
  //   adDescription,
  //   city,
  //   street,
  //   price,
  //   dstep,
  //   currency,
  //   priceType,
  //   cname,
  //   cmobile,
  //   cemail,
  // ) async {
  //   prefs = await SharedPreferences.getInstance();
  //   var uri = Uri.parse(api_url + "/post_ads");
  //   http.MultipartRequest request = new http.MultipartRequest('POST', uri);
  //   request.fields['customer_id'] = prefs.getString("user_id");
  //   request.fields['category_id'] = widget.cat_id;
  //   request.fields['sub_category_id'] = widget.subcat_id;
  //   request.fields['service_type'] = serviceType;
  //   request.fields['ads_name'] = adname;
  //   request.fields['ads_description'] = adDescription;
  //   request.fields['door_step'] = dstep;
  //   request.fields['city_id'] = city;
  //   request.fields['street_id'] = street;
  //   request.fields['ads_price'] = widget.productType == "jobs" ? "" : price;
  //   request.fields['currency_type_id'] = currency;
  //   request.fields['price_type'] =
  //       widget.productType == "jobs" ? "" : priceType;
  //   request.fields['contact_name'] = cname;
  //   request.fields['contact_mobile'] = cmobile;
  //   request.fields['contact_email'] = cemail;
  //   // request.fields['ads_image_name'] = "new image";

  //   List<MultipartFile> newList = new List<MultipartFile>();
  //   for (int i = 0; i < selectedimages.length; i++) {
  //     File imageFile = File(selectedimages[i].toString());
  //     print(selectedimages[i].toString());
  //     var stream =
  //         new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
  //     var length = await imageFile.length();
  //     var multipartFile = new http.MultipartFile("files[]", stream, length,
  //         filename: imageFile.path.split('/').last);
  //     newList.add(multipartFile);
  //   }
  //   request.files.addAll(newList);
  //   var response = await request.send();
  //   if (response.statusCode == 200) {
  //     // print(response.stream.toList());
  //     response.stream.transform(utf8.decoder).listen((value) {
  //       print(jsonDecode(value));
  //       var jsonResponse = jsonDecode(value);
  //       print("NandhuKrish");
  //       _scaffoldKey.currentState.showSnackBar(
  //         SnackBar(
  //           content: const Text('New Post Created.'),
  //         ),
  //       );
  //       setState(() {
  //         _isLoading = true;
  //         _isSubmitLoading = true;
  //       });
  //       Navigator.of(context, rootNavigator: true).pushReplacement(
  //           MaterialPageRoute(
  //               builder: (BuildContext context) => PostDone(
  //                   ads_id: jsonResponse['message']['ads_id'].toString(),
  //                   cat_id:
  //                       jsonResponse['message']['category_id'].toString())));
  //     });
  //     print("Image Uploaded");
  //   } else {
  //     print("Upload Failed");
  //     // setState(() {
  //     //   _isLoading = true;
  //     //   _isSubmitLoading = true;
  //     // });
  //   }
  //   response.stream.transform(utf8.decoder).listen((value) {
  //     print(value);
  //   });
  // }

  addNewPost(
    serviceType,
    adname,
    adDescription,
    city,
    street,
    price,
    dstep,
    currency,
    priceType,
    cname,
    cmobile,
    cemail,
  ) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': prefs.getString("user_id"),
      'category_id': widget.cat_id,
      'sub_category_id': widget.subcat_id,
      'service_type': serviceType,
      'ads_name': adname,
      'ads_description': adDescription,
      'door_step': dstep,
      'city_id': city,
      'street_id': street,
      'ads_price': widget.productType == "jobs" ? "" : price,
      'currency_type_id': currency,
      'price_type': widget.productType == "jobs" ? "" : priceType,
      'contact_name': cname,
      'contact_mobile': cmobile,
      'contact_email': cemail,
      'ads_image': files.isNotEmpty ? files.join(", ") : "",
      'ads_image_name': imageName.isNotEmpty ? imageName.join(", ") : "",
    };

    print(data);
    print(imageName);
    var jsonResponse;
    var response;
    if (widget.mapdata != null) {
      data.addAll(widget.mapdata);
      response = await http.post(Uri.parse(api_url + "/post_ads"), body: data);

      // print("--------------NK-------------");
      // print(data);
    } else {
      response = await http.post(Uri.parse(api_url + "/post_ads"), body: data);
    }
    print(response.body.toString());
    print("object");
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      // print(jsonResponse['message']['category_id']);
      print("NK Krish");
      if (jsonResponse != null) {
        print("NandhuKrish");
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: const Text('New Post Created.'),
          ),
        );
        setState(() {
          _isLoading = true;
          _isSubmitLoading = true;
        });
        Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(
                builder: (BuildContext context) => PostDone(
                    ads_id: jsonResponse['message']['ads_id'].toString(),
                    cat_id:
                        jsonResponse['message']['category_id'].toString())));
      }
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
    } else if (response.statusCode == 422) {
      setState(() {
        _isLoading = true;
        _isSubmitLoading = true;
      });
      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     builder: (BuildContext context) => ErrorPage(data: "iiii")));
      // print(jsonResponse);
      // print(jsonResponse['message']);
      _alerDialog("Please buy a ads.");
    }
  }

  List currencydata = List();
  void currency_list() async {
    var jsonResponse;
    var response = await http.get(Uri.parse(api_url + "/currency"));

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = true;
        currencydata = json.decode(response.body);
      });
    } else {
      print("error");
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

  List<Asset> images = List<Asset>();

  List files = [];

  List<Asset> resultList;

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 25,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "NKS",
          allViewTitle: "All Photos",
          useDetailsView: true,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      // _error = error;
    });
    _submit();
  }

  getImageFileFromAsset(String path) async {
    var file = File(path);
    File compressedFile;

    print("-------------NASA-----------");
    final bytes = (await file.readAsBytesSync()).lengthInBytes;
    final kb = bytes / 1024;
    // final mb = kb / 1024;
    final imgSize = kb.round();
    // print(imgSize);
    final hw = await decodeImageFromList(file.readAsBytesSync());
    print(hw.height / 2);
    print(hw.width / 2);

    if (imgSize < 500) {
      compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: 90,
        // targetWidth: (hw.width / 2).round(),
        // targetHeight: (hw.height / 2).round(),
      );
      print("image less 500kb");
    } else if (imgSize >= 501 && imgSize <= 3000) {
      compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: 40,
        // targetWidth: (hw.width / 2).round(),
        // targetHeight: (hw.height / 2).round(),
      );
      print("image less 501 to 3000kb");
    } else if (imgSize >= 3001 && imgSize <= 5000) {
      compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: 25,
        // targetWidth: (hw.width / 2).round(),
        // targetHeight: (hw.height / 2).round(),
      );
      print("image less 3001 to 5000kb");
    } else if (imgSize >= 5001 && imgSize <= 10000) {
      compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: 8,
        // targetWidth: (hw.width / 2).round(),
        // targetHeight: (hw.height / 2).round(),
      );
      print("image less 5001 to 10000kb");
    } else {
      compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: 6,
        // targetWidth: (hw.width / 2).round(),
        // targetHeight: (hw.height / 2).round(),
      );
    }
    // print("-------------NASA-----------");
    // print(compressedFile);
    return compressedFile;
  }

  List fileImg = [];
  List imageName = [];

  _submit() async {
    for (int i = 0; i < images.length; i++) {
      // print("==============NK==========");

      var path2 =
          await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      var file = await getImageFileFromAsset(path2);

      var base64Image = base64Encode(file.readAsBytesSync());
      setState(() {
        // selectedimages.add(file.path);
        fileImg.add(File(path2));
        files.add(base64Image);
        imageName.add(path2.split('/').last);
        // print(path2.split('/').last);
      });

      // setState(() {
      //   _imagefileName = files.join(", ");
      // });
    }
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
              "ADD NEW POST",
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
                    widget.productType != null
                        ? SizedBox()
                        : DropdownButtonFormField<String>(
                            decoration: textDecoration(
                                'Product Type', "Select Product Type"),
                            style: TextStyle(fontSize: 14),
                            items: <String>[
                              'NEW',
                              'OLD',
                              'SERVICES',
                            ]
                                .map((String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: color2,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              if (newValue == "NEW") {
                                newValue = "1";
                              } else if (newValue == "OLD") {
                                newValue = "2";
                              } else {
                                newValue = "3";
                              }
                              setState(() {
                                product_type = newValue;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Select product type ' : null,
                          ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: title,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: textDecoration(
                        'Enter post title',
                        'Title *',
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      maxLines: 3,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: description,
                      onTap: () {},
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: textDecoration(
                        'write description',
                        'Description *',
                      ),
                    ),
                    widget.productType == "jobs"
                        ? SizedBox()
                        : SizedBox(
                            height: 15,
                          ),
                    widget.productType == "jobs"
                        ? SizedBox()
                        : Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(hintText: "₹"),
                                  style: TextStyle(fontSize: 14),
                                  items: currencydata
                                      .map((item) => DropdownMenuItem(
                                            value: item['id'].toString(),
                                            child: Text(
                                              item['currency_symbol'],
                                              style: TextStyle(
                                                color: color2,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      currency_type = newValue;
                                    });
                                  },
                                  // validator: (value) =>
                                  //     value == null ? 'Select currency type ' : null,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter price';
                                    }
                                    return null;
                                  },
                                  onSaved: (String value) {},
                                  controller: price,
                                  onTap: () {},
                                  minLines: 1,
                                  maxLines: 4,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: black,
                                  ),
                                  keyboardType: TextInputType.text,
                                  decoration: textDecoration(
                                    'Enter price',
                                    'Price',
                                  ),
                                ),
                              ),
                            ],
                          ),
                    widget.productType == "jobs"
                        ? SizedBox()
                        : SizedBox(
                            height: 15,
                          ),
                    widget.productType == "jobs"
                        ? SizedBox()
                        : DropdownButtonFormField<String>(
                            decoration: textDecoration(
                                'Price Type', "Select Price Type"),
                            style: TextStyle(fontSize: 14),
                            items: <String>[
                              'Negotiable',
                              'Fixed',
                            ]
                                .map((String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: color2,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              if (newValue == "Negotiable") {
                                newValue = "1";
                              } else {
                                newValue = "2";
                              }
                              setState(() {
                                price_type = newValue;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Select price type ' : null,
                          ),
                    widget.productType == "jobs"
                        ? SizedBox()
                        : SizedBox(
                            height: 15,
                          ),
                    widget.productType == "jobs"
                        ? SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Doorstep Services",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: color2,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: 10,
                              ),
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
                                    fontWeight: FontWeight.w400),
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
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter street address';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: street,
                      onTap: () {},
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: textDecoration(
                        'Enter Your Area',
                        'Area',
                      ),
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
                      controller: locationName,
                      onTap: _showLocation,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: color2,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: textDecoration('Location', 'Choose Loaction'),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    InkWell(
                      onTap: () {
                        print("NK");
                        loadAssets();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 50,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: primaryColor, width: 1.5),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "Browse Image",
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    fileImg.length != 0
                        ? Container(
                            height: 60,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: fileImg.length,
                                itemBuilder: (context, index) {
                                  // print("------------NK----------");
                                  // print(fileImg[index]);
                                  return Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 58,
                                          width: 55,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              image: DecorationImage(
                                                  image:
                                                      FileImage(fileImg[index]),
                                                  fit: BoxFit.fill)),
                                        ),
                                        Container(
                                          height: 60,
                                          width: 55,
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  fileImg.removeAt(index);
                                                  files.removeAt(index);
                                                  imageName.removeAt(index);
                                                });
                                              },
                                              child: Card(
                                                elevation: 4,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 13,
                    ),
                    Text(
                      "Contact Details",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter contact name';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: contactName,
                      onTap: () {},
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: textDecoration(
                        'Enter contact name',
                        'Contact Name',
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: contactNumber,
                      onTap: () {},
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.phone,
                      decoration: textDecoration(
                        'Enter Phone number',
                        'Contact Number',
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter valid email';
                        }
                        return null;
                      },
                      onSaved: (String value) {},
                      controller: contactEmail,
                      onTap: () {},
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: black,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      decoration: textDecoration(
                        'Enter Your email',
                        'Email',
                      ),
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
        _isSubmitLoading ? SizedBox() : FullScreenLoading(),
      ],
    );
  }

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (files.isNotEmpty) {
        setState(() {
          _isSubmitLoading = false;
        });
        addNewPost(
          product_type,
          title.text,
          description.text,
          cityID,
          street.text,
          price.text,
          "$doorStep",
          currency_type,
          price_type,
          contactName.text,
          contactNumber.text,
          contactEmail.text,
        );
      } else {
        _alerDialog("add image");
      }
    }
    // Navigator.of(context, rootNavigator: true)
    //     .push(CupertinoPageRoute(builder: (_) => Checked()));
  }

  void _showLocation() {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final orientation = MediaQuery.of(context).orientation;
        return SafeArea(
          child: Container(
            padding: (orientation == Orientation.portrait)
                ? EdgeInsets.fromLTRB(20, 100, 20, 20)
                : EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                          controller: location,
                          decoration: textDecoration2("Search Location")),
                      suggestionsCallback: (pattern) async {
                        // print(pattern);
                        return await get_locationData(pattern);
                      },
                      itemBuilder: (context, item) {
                        return list(item);
                      },
                      onSuggestionSelected: (item) async {
                        setState(() {
                          locationName.text = item.city_name;
                          cityID = item.id;
                          location.text = item.city_name;

                          // print(item.city_name);
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

  void _closeModal(void value) {
    print('modal closed');
    location.clear();
    // Navigator.pop(context);
  }
}
