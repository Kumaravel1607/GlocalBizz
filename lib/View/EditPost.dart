import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Controller/location_controller.dart';
import 'package:glocal_bizz/Model/currency_model.dart';
import 'package:glocal_bizz/Model/detail_model.dart';
import 'package:glocal_bizz/View/MyPosts.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:http/http.dart' as http;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class EditPost extends StatefulWidget {
  final String ads_id;
  EditPost({Key key, this.ads_id}) : super(key: key);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
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
  Future<AdsDetail> _adsdetail;
  SharedPreferences prefs;
  int doorStep = 0;
  String cityID;
  String cat_id;
  String subcat_id;
  bool _submitLoad = true;
  bool _isLoading = false;

  String price_type = "";
  String product_type;
  String currency_type = "1";
  String _imagefileName;
  String cityName;
  String adsType;

  @override
  void initState() {
    super.initState();
    _adsdetail = ads_detail();
    image_api();
    currency_list();
  }

  Future<AdsDetail> ads_detail() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'id': widget.ads_id,
      'customer_id': prefs.getString("user_id"),
    };
    print(data);

    var response =
        await http.post(Uri.parse(api_url + "/ads_detail"), body: data);
    print(json.decode(response.body));
    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      setState(() {
        _isLoading = true;
      });
      adsType = jsonResponse['ads_type'];
      product_type = jsonResponse['service_type'].toString();
      title.text = jsonResponse['ads_name'].toString();
      description.text = jsonResponse['ads_description'].toString();
      currency_type = jsonResponse['currency_type_id'].toString();
      price.text = jsonResponse['ads_price_int'].toString();
      price_type = jsonResponse['price_type'].toString();
      doorStep = int.parse(jsonResponse['door_step']);
      street.text = jsonResponse['street_id'].toString();
      location.text = jsonResponse['city_name'].toString();
      cityID = jsonResponse['city_id'].toString();
      contactName.text = jsonResponse['contact_name'].toString();
      contactEmail.text = jsonResponse['contact_email'].toString();
      contactNumber.text = jsonResponse['contact_mobile'].toString();
      cat_id = jsonResponse['category_id'].toString();
      subcat_id = jsonResponse['sub_category_id'].toString();
      locationName.text = jsonResponse['city_name'].toString();

      get_dropdownValues();

      return AdsDetail.fromJson(jsonResponse);
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load post');
    }
  }

  Future<void> image_api() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'id': widget.ads_id,
      'customer_id': prefs.getString("user_id"),
    };
    var response =
        await http.post(Uri.parse(api_url + "/ads_detail"), body: data);

    if (response.statusCode == 200) {
      get_imageList(json.decode(response.body)['images']).then((value) {
        setState(() {
          imageList = value;
        });
      });
    }
  }

  List<AllImage> imageList = List<AllImage>();

  Future<List<AllImage>> get_imageList(imageListsJson) async {
    var imageLists = List<AllImage>();
    for (var imageListJson in imageListsJson) {
      imageLists.add(AllImage.fromJson(imageListJson));
    }
    return imageLists;
  }

  delete_image(imgID) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'ads_id': widget.ads_id,
      'image_id': imgID,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/delete_image"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      // Navigator.pop(context);
      print("Image Deleted");
    } else {
      print("Error for Image Delete");
      setState(() {
        _isLoading = false;
      });
    }
  }

  _updataPost(
    serviceType,
    adname,
    adDescription,
    city,
    street,
    newprice,
    dstep,
    currency,
    priceType,
    cname,
    cmobile,
    cemail,
  ) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'id': widget.ads_id,
      'customer_id': prefs.getString("user_id"),
      'category_id': cat_id,
      'sub_category_id': subcat_id,
      'service_type': serviceType,
      'ads_name': adname,
      'ads_description': adDescription,
      'city_id': city,
      'street_id': street,
      'ads_price': newprice,
      'door_step': dstep,
      'currency_type_id': currency,
      'price_type': priceType,
      'contact_name': cname,
      'contact_mobile': cmobile,
      'contact_email': cemail,
      'ads_image': files.isNotEmpty ? files.join(", ") : "",
      'ads_image_name': imageName.isNotEmpty ? imageName.join(", ") : "",
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/edit_ads"), body: data);
    // print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse != null) {
        setState(() {
          // _isLoading = true;
          _submitLoad = true;
        });
        print("NandhuKrish");
        Navigator.of(context).pop();
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: const Text('Successfully editted.'),
          ),
        );

        // Navigator.of(context, rootNavigator: true).pushReplacement(
        //     MaterialPageRoute(builder: (BuildContext context) => MyPostPage()));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _alerDialog(jsonResponse['message']);
    }
  }

  List currencydata = List();
  void currency_list() async {
    var jsonResponse;
    var response = await http.get(Uri.parse(api_url + "/currency"));

    if (response.statusCode == 200) {
      setState(() {
        // _isLoading = true;
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

  List fileImg = [];
  List imageName = [];

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
          actionBarTitle: "Dev by NK",
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
    final bytes = (await file.readAsBytesSync()).lengthInBytes;
    final kb = bytes / 1024;
    final imgSize = kb.round();
    final hw = await decodeImageFromList(file.readAsBytesSync());

    if (imgSize < 500) {
      compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: 80,
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
    return compressedFile;
  }

  _submit() async {
    for (int i = 0; i < images.length; i++) {
      var path2 =
          await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      File file = await getImageFileFromAsset(path2);
      var base64Image = base64Encode(file.readAsBytesSync());
      setState(() {
        // selectedimages.add(file.path);
        files.add(base64Image);
        fileImg.add(File(path2));
        imageName.add(path2.split('/').last);
        _imagefileName = files.join(", ");
      });
    }
  }

  String product_type_string;
  String price_type_string;

  void get_dropdownValues() {
    setState(() {
      if (product_type == "1") {
        product_type_string = "NEW";
      } else if (product_type == "2") {
        product_type_string = "OLD";
      } else {
        product_type_string = "SERVICES";
      }

      if (price_type == "1") {
        price_type_string = "Negotiable";
      } else {
        price_type_string = "Fixed";
      }
    });
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
              "EDIT POST",
              style: TextStyle(color: white),
            ),
          ),
          body: _isLoading
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          adsType == "jobs"
                              ? SizedBox()
                              : DropdownButtonFormField<String>(
                                  hint: Text(product_type_string != null
                                      ? product_type_string
                                      : "Select product type"),
                                  decoration:
                                      textDecoration('Product Type', ""),
                                  style: TextStyle(fontSize: 14),
                                  items: <String>[
                                    'NEW',
                                    'OLD',
                                    'SERVICES',
                                  ]
                                      .map((String value) =>
                                          DropdownMenuItem<String>(
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
                                  // validator: (value) =>
                                  //     value == null ? 'Select product type ' : null,
                                ),
                          adsType == "jobs"
                              ? SizedBox()
                              : SizedBox(
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
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter description';
                              }
                              return null;
                            },
                            onSaved: (String value) {},
                            maxLines: 6,
                            minLines: 2,
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
                          SizedBox(
                            height: 15,
                          ),
                          adsType == "jobs"
                              ? SizedBox()
                              : Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: DropdownButtonFormField(
                                        decoration:
                                            InputDecoration(hintText: "₹"),
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
                                        // minLines: 1,
                                        // maxLines: 4,
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
                          adsType == "jobs"
                              ? SizedBox()
                              : SizedBox(
                                  height: 15,
                                ),
                          adsType == "jobs"
                              ? SizedBox()
                              : DropdownButtonFormField<String>(
                                  hint: Text(price_type_string != null
                                      ? price_type_string
                                      : "Select Price Type"),
                                  decoration: textDecoration('Price Type', ""),
                                  style: TextStyle(fontSize: 14),
                                  items: <String>[
                                    'Negotiable',
                                    'Fixed',
                                  ]
                                      .map((String value) =>
                                          DropdownMenuItem<String>(
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
                                  // validator: (value) =>
                                  //     value == null ? 'Select price type ' : null,
                                ),
                          adsType == "jobs"
                              ? SizedBox()
                              : SizedBox(
                                  height: 15,
                                ),
                          adsType == "jobs"
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
                          adsType == "jobs"
                              ? SizedBox()
                              : SizedBox(
                                  height: 15,
                                ),
                          TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter Area address';
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
                            // validator: (value) {
                            //   if (value.isEmpty) {
                            //     return 'Please choose location';
                            //   }
                            //   return null;
                            // },
                            onSaved: (String value) {},
                            controller: locationName,
                            onTap: _showLocation,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: color2,
                            ),
                            keyboardType: TextInputType.text,
                            decoration:
                                textDecoration('Location', 'Choose Loaction'),
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
                                  border: Border.all(
                                      color: primaryColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                "Browse Image",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          _postimages(),
                          fileImg.length != 0
                              ? Text("Newly Added Image: ")
                              : SizedBox(),
                          SizedBox(
                            height: 3,
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
                                                        BorderRadius.circular(
                                                            7),
                                                    image: DecorationImage(
                                                        image: FileImage(
                                                            fileImg[index]),
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
                                                        imageName
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: Card(
                                                      elevation: 4,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
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
                            height: 15,
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
                )
              : Container(
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
                  )),
                ),
        ),
        _submitLoad ? SizedBox() : FullScreenLoading(),
      ],
    );
  }

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _submitLoad = false;
      });
      _updataPost(
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
    }
    // Navigator.of(context, rootNavigator: true)
    //     .push(CupertinoPageRoute(builder: (_) => Checked()));
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
                          locationName.text = item.city_name;
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

  void _closeModal(void value) {
    print('modal closed');
    location.clear();
    // Navigator.pop(context);
  }

  Widget _postimages() {
    return imageList.length != 0
        ? Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                shrinkWrap: false,
                scrollDirection: Axis.horizontal,
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Stack(
                      children: [
                        Image.network(
                          imageList[index].image_name,
                          height: 100,
                          width: 100,
                        ),
                        GestureDetector(
                          child: Card(
                            elevation: 7,
                            color: Color(0xFFf8f8f8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.close,
                                size: 16,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content:
                                        Text("Are you sure confirm to delete"),
                                    //title: Text(),
                                    actions: <Widget>[
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context, "no");
                                        },
                                        child: const Text("NO"),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          delete_image(imageList[index].id);
                                          Navigator.pop(context, "ok");
                                          setState(() {
                                            imageList.removeAt(index);
                                            files.isNotEmpty
                                                ? files.removeAt(index)
                                                : null;
                                          });
                                        },
                                        child: const Text("YES"),
                                      ),
                                    ],
                                  );
                                });
                          },
                        )
                      ],
                    ),
                  );
                }),
          )
        : SizedBox();
  }
}
