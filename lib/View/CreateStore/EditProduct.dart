import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/detail_model.dart';
import 'package:glocal_bizz/Model/product_detail_model.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class EditProduct extends StatefulWidget {
  final String product_id;
  final String category_id;
  EditProduct({Key key, this.product_id, this.category_id}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
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
  String oldImg;
  bool _submitLoad = true;
  String _imagefileName;

  @override
  void initState() {
    super.initState();
    product_detail();
    image_api();
  }

  Future<ProductDetail> product_detail() async {
    Map data = {
      'id': widget.product_id,
    };
    print(data);

    var response =
        await http.post(Uri.parse(api_url + "/product_details"), body: data);
    print(json.decode(response.body));
    var jsonResponse;
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = true;
      });
      jsonResponse = json.decode(response.body);
      print("--------------NK-----------");
      print(jsonResponse);
      productname.text = jsonResponse['product_name'];
      mrp.text = jsonResponse['product_mrp'];
      price.text = jsonResponse['product_price'].toString();
      description.text = jsonResponse['product_description'];
      quantity.text = jsonResponse['product_count'].toString();
      setState(() {
        oldImg = jsonResponse['product_image'];
      });
      return ProductDetail.fromJson(jsonResponse);
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load post');
    }
  }

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

  void _editProduct(
    pname,
    pmrp,
    pprice,
    pcount,
    pdescription,
  ) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'product_id': widget.product_id,
      'store_id': prefs.getString("store_id"),
      'category_id': widget.category_id,
      'product_name': pname,
      'product_mrp': pmrp,
      'product_price': pprice,
      'product_count': pcount,
      'product_description': pdescription,
      'product_image': files.isNotEmpty
          ? files.join(", ")
          : oldImg, //productLogo != null ? productLogo : oldImg,
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/update_product"), body: data);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        // _isLoading = true;
        _submitLoad = true;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Product updated'),
        ),
      );
      Navigator.of(context).pop();
      // Navigator.of(context, rootNavigator: true).pushReplacement(
      //     CupertinoPageRoute(builder: (_) => MyStoreDetails()));
    } else {
      setState(() {
        _submitLoad = false;
      });
      jsonResponse = json.decode(response.body);
      _alerDialog(jsonResponse['message']);
    }
  }

  Future<void> image_api() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'id': widget.product_id,
      'customer_id': prefs.getString("user_id"),
    };
    var response =
        await http.post(Uri.parse(api_url + "/product_details"), body: data);

    if (response.statusCode == 200) {
      get_imageList(json.decode(response.body)['productimages']).then((value) {
        setState(() {
          imageList = value;
        });
      });
    }
  }

  List<AllProductImage> imageList = List<AllProductImage>();

  Future<List<AllProductImage>> get_imageList(imageListsJson) async {
    var imageLists = List<AllProductImage>();
    for (var imageListJson in imageListsJson) {
      imageLists.add(AllProductImage.fromJson(imageListJson));
    }
    return imageLists;
  }

  delete_image(imgID) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'product_id': widget.product_id,
      'image_id': imgID,
    };
    print(data);
    var jsonResponse;
    var response = await http.post(Uri.parse(api_url + "/delete_product_image"),
        body: data);
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
      var file = await getImageFileFromAsset(path2);
      var base64Image = base64Encode(file.readAsBytesSync());
      files.add(base64Image);
      // print("-------------NASA-----------");
      // print(files);
      setState(() {
        _imagefileName = files.join(", ");
      });
      // print("------NK_--------------");
      // print(_imagefileName);
    }
    print("------NK_--------------");
    print(files);
    print(files.length);
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
              "EDIT OLD PRODUCT",
              style: TextStyle(color: white),
            ),
          ),
          body: _isLoading
              ? SingleChildScrollView(
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
                                                color: primaryColor,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(10)),
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
                                    _postimages(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    // oldImg != null
                                    //     ? CircleAvatar(
                                    //         radius: 22,
                                    //         backgroundImage: NetworkImage(oldImg),
                                    //       )
                                    //     : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
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
                              height: 30,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  child: ElevatedBtn1(submitButton, "Submit")),
                            )
                          ],
                        ),
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
      // if (productLogo != null) {
      setState(() {
        _submitLoad = false;
      });
      _editProduct(productname.text, mrp.text, price.text, quantity.text,
          description.text);
      // } else {
      //   _alerDialog("Please add image.");
      // }
    }
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
                          imageList[index].product_image,
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
