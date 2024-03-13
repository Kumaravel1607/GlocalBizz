import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/KYC_model.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class KYCPage extends StatefulWidget {
  KYCPage({Key key}) : super(key: key);

  @override
  _KYCPageState createState() => _KYCPageState();
}

class _KYCPageState extends State<KYCPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  bool _isLoading = false;
  List<Asset> images = List<Asset>();
  bool _submitLoad = true;
  bool initialLoading = false;

  List files = [];
  List<Asset> resultList;
  String _documentType = "";
  String documentImage;
  File selectedImage;

  String uploadedDocImage;
  String uploadedDocName;
  int kycID;

  @override
  void initState() {
    super.initState();
    get_documents();
  }

  final picker = ImagePicker();
  void open_gallery() async {
    // var image = await picker.getImage(source: ImageSource.gallery);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    var imagepath = File(pickedFile.path);
    setState(() {
      selectedImage = imagepath;
      documentImage = base64Encode(imagepath.readAsBytesSync());
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 100,
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

  void _createKYC() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'store_id': prefs.getString("store_id"),
      'document_type': _documentType,
      'kyc_document': documentImage ?? "",
      // 'kyc_document': files.isNotEmpty ? files.join(", ") : "",
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/create_store_kyc"), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = true;
        _submitLoad = true;
        prefs.setInt('kyc_id', jsonResponse['kyc_id']);
        kycID = jsonResponse['kyc_id'];
        selectedImage = null;
        _documentType = "";
      });
      // print("kyc id");
      // print(jsonResponse);
      get_documents();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('KYC Created'),
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

  void _updateKYC() async {
    prefs = await SharedPreferences.getInstance();
    String kycid = prefs.getInt("kyc_id").toString() ?? kycID.toString();
    Map data = {
      'kyc_id': kycid,
      'store_id': prefs.getString("store_id"),
      'document_type': _documentType,
      'kyc_document': documentImage ?? "",
      // 'kyc_document': files.isNotEmpty ? files.join(", ") : "",
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/update_store_kyc"), body: data);
    print(response.body.toString());
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = true;
        _submitLoad = true;
        selectedImage = null;
        _documentType = "";
      });
      get_documents();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('KYC Updated!!'),
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

  Future<void> get_documents() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'store_id': prefs.getString("store_id"),
    };
    var response =
        await http.post(Uri.parse(api_url + "/store_kyc_details"), body: data);

    if (response.statusCode == 200) {
      setState(() {
        initialLoading = true;
      });
      var jsonresponse = json.decode(response.body);
      print(jsonresponse[0]['document_name']);
      print(jsonresponse[0]['document_type']);

      setState(() {
        kycID = jsonresponse[0]['id'];
        uploadedDocImage = jsonresponse[0]['document_name'];
        switch (jsonresponse[0]['document_type']) {
          case "1":
            uploadedDocName = "Aadhar Card";
            break;
          case "2":
            uploadedDocName = "Passport";
            break;
          case "3":
            uploadedDocName = "Smart Card";
            break;
          case "4":
            uploadedDocName = "PAN Card";
            break;
          default:
        }
        prefs.setInt('kyc_id', jsonresponse[0]['id']);
      });

      // get_documentList(jsonresponse).then((value) {
      //   setState(() {
      //     documentList = value;
      //   });
      // });
      // print(documentList.toString());
      // documentList.isEmpty ? print("is empty") : print("value is there");
      // print(documentList);
    }
  }

  List<KYCDocument> documentList = List<KYCDocument>();

  Future<List<KYCDocument>> get_documentList(documentsJson) async {
    var documents = List<KYCDocument>();
    for (var documentJson in documentsJson) {
      documents.add(KYCDocument.fromJson(documentJson));
    }
    return documents;
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

  Future<void> _alerImage() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Please add document image"),
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
          // backgroundColor: Color(0xFFf8f8f8),
          backgroundColor: white,
          body: initialLoading
              ? Container(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              "KYC",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color2,
                                  fontSize: 18),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 30, 30, 20),
                              child: Image.asset("assets/kyc1.png"),
                            ),
                            // SizedBox(
                            //   height: 15,
                            // ),
                            uploadedDocImage != null
                                ? InkWell(
                                    child: Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Container(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            children: [
                                              // Image.network(uploadedDocImage),
                                              CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      Loading(),
                                                  imageUrl: uploadedDocImage),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                uploadedDocName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: color2,
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  photoView()));
                                    },
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 10,
                            ),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 15),
                                child: Column(
                                  children: [
                                    kycID != null
                                        ? Text(
                                            "Update KYC",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                                fontSize: 16),
                                          )
                                        : Text(
                                            "Create KYC",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                                fontSize: 16),
                                          ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    DropdownButtonFormField<String>(
                                      decoration: textDecorate("Document Type"),
                                      items: <String>[
                                        'Aadhar Card',
                                        'Passport',
                                        'Smart Card',
                                        'PAN Card',
                                      ]
                                          .map((String value) =>
                                              DropdownMenuItem<String>(
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
                                        var documentVal;
                                        switch (newValue) {
                                          case "Aadhar Card":
                                            documentVal = "1";
                                            break;
                                          case "Passport":
                                            documentVal = "2";
                                            break;
                                          case "Smart Card":
                                            documentVal = "3";
                                            break;
                                          case "PAN Card":
                                            documentVal = "4";
                                            break;
                                          default:
                                        }
                                        setState(() {
                                          _documentType = documentVal;
                                          print(documentVal);
                                        });
                                      },
                                      validator: (value) => value == null
                                          ? 'Please select the Document'
                                          : null,
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // loadAssets();
                                        open_gallery();
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
                                          "Add KYC Document",
                                          style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    selectedImage != null
                                        ? Padding(
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
                                                              selectedImage),
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
                                                          selectedImage = null;
                                                          documentImage = null;
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
                                          )
                                        : SizedBox(),
                                    // fileImg.length != 0
                                    //     ? Container(
                                    //         height: 60,
                                    //         child: ListView.builder(
                                    //             shrinkWrap: true,
                                    //             physics: ScrollPhysics(),
                                    //             scrollDirection: Axis.horizontal,
                                    //             itemCount: fileImg.length,
                                    //             itemBuilder: (context, index) {
                                    //               // print("------------NK----------");
                                    //               // print(fileImg[index]);
                                    //               return Padding(
                                    //                 padding: const EdgeInsets.all(3.0),
                                    //                 child: Stack(
                                    //                   children: [
                                    //                     Container(
                                    //                       height: 58,
                                    //                       width: 55,
                                    //                       decoration: BoxDecoration(
                                    //                           borderRadius:
                                    //                               BorderRadius.circular(
                                    //                                   7),
                                    //                           image: DecorationImage(
                                    //                               image: FileImage(
                                    //                                   fileImg[index]),
                                    //                               fit: BoxFit.fill)),
                                    //                     ),
                                    //                     Container(
                                    //                       height: 60,
                                    //                       width: 55,
                                    //                       child: Align(
                                    //                         alignment:
                                    //                             Alignment.topRight,
                                    //                         child: InkWell(
                                    //                           onTap: () {
                                    //                             setState(() {
                                    //                               fileImg
                                    //                                   .removeAt(index);
                                    //                             });
                                    //                           },
                                    //                           child: Card(
                                    //                             elevation: 4,
                                    //                             child: Padding(
                                    //                               padding:
                                    //                                   const EdgeInsets
                                    //                                       .all(2.0),
                                    //                               child: Icon(
                                    //                                 Icons.close,
                                    //                                 size: 13,
                                    //                               ),
                                    //                             ),
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                     )
                                    //                   ],
                                    //                 ),
                                    //               );
                                    //             }),
                                    //       )
                                    //     : SizedBox(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    kycID != null
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.90,
                                            child: ElevatedBtn1(
                                                updateButton, "UPDATE"))
                                        : Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.90,
                                            child: ElevatedBtn1(
                                                createButton, "CREATE")),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Loading(),
        ),
        _submitLoad ? SizedBox() : FullScreenLoading(),
      ],
    );
  }

  void createButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (documentImage != null) {
        setState(() {
          _submitLoad = false;
        });
        _createKYC();
      } else {
        _alerImage();
      }
    }
  }

  void updateButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (documentImage != null) {
        setState(() {
          _submitLoad = false;
        });
        _updateKYC();
        // setState(() {
        //   documentImage = null;
        //   _documentType = "";
        // });
      } else {
        _alerImage();
      }
    }
  }

  textDecorate(String fieldName) => InputDecoration(
        fillColor: white,
        filled: true,
        contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        hintText: (fieldName),
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        border: new OutlineInputBorder(
          borderSide: new BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: new OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: new OutlineInputBorder(
          borderSide: new BorderSide(color: primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      );

  Widget photoView() => Container(
        child: Stack(children: [
          PhotoViewGallery(
            pageOptions: <PhotoViewGalleryPageOptions>[
              PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(uploadedDocImage),
              ),
            ],
            loadingBuilder: (context, progress) => Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(),
              ),
            ),
            // backgroundDecoration: widget.backgroundDecoration,
            // pageController: widget.pageController,
            // onPageChanged: onPageChanged,
          ),
          Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 100, right: 25),
              child: FloatingActionButton(
                elevation: 10,
                mini: true,
                foregroundColor: black,
                backgroundColor: white,
                child: Icon(
                  Icons.close,
                  color: black,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
        ]),
      );
}
