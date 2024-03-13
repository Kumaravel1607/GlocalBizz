import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class AddProduct extends StatefulWidget {
  AddProduct({Key key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController productname = new TextEditingController();
  final TextEditingController mrp = new TextEditingController();
  final TextEditingController price = new TextEditingController();
  final TextEditingController description = new TextEditingController();
  final TextEditingController quantity = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  bool _isLoading = false;

  String _currentSelectedValue;
  String productLogo;
  bool _submitLoad = true;

  final picker = ImagePicker();
  void open_gallery() async {
    // var image = await picker.getImage(source: ImageSource.gallery);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    var imagepath = File(pickedFile.path);
    setState(() {
      // storeLogoFile = imagepath;
      productLogo = base64Encode(imagepath.readAsBytesSync());
    });
    print(productLogo);
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
          actionBarTitle: "NK",
          allViewTitle: "All Photos",
          useDetailsView: false,
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

  List fileImg = [];

  _submit() async {
    for (int i = 0; i < images.length; i++) {
      var path2 =
          await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      // print(File(path2));
      var file = await getImageFileFromAsset(path2);
      var base64Image = base64Encode(file.readAsBytesSync());
      setState(() {
        fileImg.add(File(path2));
        files.add(base64Image);
      });
    }
  }

  void _createProduct(
    pname,
    pmrp,
    pprice,
    pcount,
    pdescription,
  ) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'store_id': prefs.getString("store_id"),
      // 'category_id': "1",
      'product_name': pname,
      'product_mrp': pmrp,
      'product_price': pprice,
      'product_count': pcount,
      'product_description': pdescription,
      'product_image': files.isNotEmpty ? files.join(", ") : "", //productLogo
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/create_product"), body: data);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = true;
        _submitLoad = true;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('New Product added'),
        ),
      );
      Navigator.of(context).pop();
      // Navigator.of(context, rootNavigator: true).pushReplacement(
      //     CupertinoPageRoute(builder: (_) => MyStoreDetails()));
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
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: primaryColor,
            iconTheme: IconThemeData(color: white),
            title: Text(
              "ADD PRODUCT",
              style: TextStyle(color: white),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Product Images",
                                style: TextStyle(color: color2),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              InkWell(
                                onTap: () {
                                  loadAssets();
                                  print("NK");
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height: 50,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: primaryColor, width: 1.5),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    "Add Product Image",
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
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
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    height: 58,
                                                    width: 55,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        image: DecorationImage(
                                                            image: FileImage(
                                                                fileImg[index]),
                                                            fit: BoxFit.fill)),
                                                  ),
                                                  Container(
                                                    height: 60,
                                                    width: 55,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            fileImg.removeAt(
                                                                index);
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
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: productname,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                          color: black,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration1('product Name *'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              cursorHeight: 18,
                              onSaved: (String value) {},
                              controller: mrp,
                              obscureText: false,
                              onTap: () {},
                              style: TextStyle(
                                fontSize: 14.0,
                                color: black,
                              ),
                              keyboardType: TextInputType.text,
                              decoration: textDecoration1(
                                'MRP *',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: TextFormField(
                              cursorHeight: 18,
                              onSaved: (String value) {},
                              controller: price,
                              obscureText: false,
                              onTap: () {},
                              style: TextStyle(
                                fontSize: 14.0,
                                color: black,
                              ),
                              keyboardType: TextInputType.text,
                              decoration: textDecoration1(
                                'Price',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter Description';
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
                        minLines: 1,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        decoration: textDecoration1('Description'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      divider(),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please add quantity';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: quantity,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                          color: black,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration1('Quantity *'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
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
        ),
        _submitLoad ? SizedBox() : FullScreenLoading(),
      ],
    );
  }

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (files.isNotEmpty) {
        setState(() {
          _submitLoad = false;
        });
        _createProduct(productname.text, mrp.text, price.text, quantity.text,
            description.text);
      } else {
        _alerDialog("Please add image.");
      }
    }
  }
}
