// import 'dart:convert';
// import 'dart:io';

// import 'package:async/async.dart';
// import 'package:flutter/material.dart';
// import 'package:glocal_bizz/Controller/api.dart';
// import 'package:glocal_bizz/Controller/constand.dart';
// import 'package:http/http.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class DemoTest extends StatefulWidget {
//   DemoTest({Key key}) : super(key: key);

//   @override
//   _DemoTestState createState() => _DemoTestState();
// }

// class _DemoTestState extends State<DemoTest> {
//   File _image;
//   String _imagefileName;
//   String _imageName;
//   final picker = ImagePicker();

//   List fileImg = [];
//   List images = [];
//   postData() async {
//     var request =
//         new http.MultipartRequest("POST", Uri.parse(api_url + "/upload_files"));
//     List<MultipartFile> newList = new List<MultipartFile>();
//     for (int i = 0; i < images.length; i++) {
//       File imageFile = File(images[i].toString());
//       print("-----------------NK King----------------");
//       print(images[i]);
//       var stream =
//           new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
//       var length = await imageFile.length();
//       var multipartFile = await http.MultipartFile.fromPath(
//         imageFile.path.split('/').last,
//         imageFile.path,
//       );
//       //  new http.MultipartFile("imagefile", stream, length,
//       //     filename: imageFile.path.split('/').last);

//       newList.add(multipartFile);
//       // newList.add(await http.MultipartFile.fromPath(
//       //   imageFile.path.split('/').last,
//       //   imageFile.path,
//       // ));
//     }
//     request.files.addAll(newList);
//     // request.files.add(await http.MultipartFile.fromPath(
//     //   'files',
//     //   file.path,
//     // ));
//     request.send().then((response) {
//       if (response.statusCode == 200) {
//         print("Uploaded!");
//         print(jsonDecode(response.toString()));
//         // print(response.toString());
//       } else {
//         print(response.statusCode);
//         print("not Uploaded!");
//       }
//       response.stream.transform(utf8.decoder).listen((value) {
//         print(value);
//       });
//     });
//   }

//   void open_camera() async {
//     var image =
//         await picker.getImage(source: ImageSource.camera, imageQuality: 50);
//     // print(images);
//     setState(() {
//       _image = File(image.path);
//       images.add(image.path);
//       fileImg.add(_image);
//       // _imageName = _image.path.split('/').last;
//       // _imagefileName = base64Encode(_image.readAsBytesSync());
//     });
//   }

//   Future uploadmultipleimage() async {
//     var uri = Uri.parse(api_url + "/upload_files");
//     http.MultipartRequest request = new http.MultipartRequest('POST', uri);
//     request.headers[''] = '';
//     request.fields['user_id'] = '10';
//     request.fields['post_details'] = 'dfsfdsfsd';
//     //multipartFile = new http.MultipartFile("imagefile", stream, length, filename: basename(imageFile.path));
//     List<MultipartFile> newList = new List<MultipartFile>();
//     for (int i = 0; i < images.length; i++) {
//       File imageFile = File(images[i].toString());
//       print(images[i].toString());
//       var stream =
//           new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
//       var length = await imageFile.length();
//       var multipartFile = new http.MultipartFile("files[]", stream, length,
//           filename: imageFile.path.split('/').last);
//       newList.add(multipartFile);
//     }
//     request.files.addAll(newList);
//     var response = await request.send();
//     if (response.statusCode == 200) {
//       print("Image Uploaded");
//     } else {
//       print("Upload Failed");
//     }
//     response.stream.transform(utf8.decoder).listen((value) {
//       print(value);
//     });
//   }

//   void open_gallery() async {
//     var image =
//         await picker.getImage(source: ImageSource.gallery, imageQuality: 70);
//     //  var pickedFile = await picker.getImage(source: ImageSource.gallery);
//     setState(() {
//       _image = File(image.path);
//       // _image = image;
//       _imageName = _image.path.split('/').last;
//       _imagefileName = base64Encode(_image.readAsBytesSync());

//       // final bytes = _image.readAsBytesSync().lengthInBytes;
//       // final kb = bytes / 1024;
//       // final mb = kb / 1024;
//       // print("-------NK-----------");
//       // print(mb.round());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Demo Image pic"),
//       ),
//       body: Container(
//         child: Center(
//           child: Column(
//             children: [
//               ElevatedButton(
//                   onPressed: () {
//                     // postData();
//                     uploadmultipleimage();
//                   },
//                   child: Text("submit")),
//               Text(
//                 "data",
//                 style: TextStyle(color: color2),
//               ),
//               ElevatedButton(
//                   onPressed: () {
//                     _showPicker(context);
//                   },
//                   child: Text("Select image")),
//               SizedBox(
//                 height: 50,
//               ),
//               fileImg.length != 0
//                   ? Container(
//                       height: 80,
//                       child: ListView.builder(
//                           shrinkWrap: true,
//                           physics: ScrollPhysics(),
//                           scrollDirection: Axis.horizontal,
//                           itemCount: fileImg.length,
//                           itemBuilder: (context, index) {
//                             // print("------------NK----------");
//                             // print(fileImg[index]);
//                             return Padding(
//                               padding: const EdgeInsets.all(3.0),
//                               child: Stack(
//                                 children: [
//                                   Container(
//                                     height: 78,
//                                     width: 75,
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(7),
//                                         image: DecorationImage(
//                                             image: FileImage(fileImg[index]),
//                                             fit: BoxFit.fill)),
//                                   ),
//                                   Container(
//                                     height: 80,
//                                     width: 75,
//                                     child: Align(
//                                       alignment: Alignment.topRight,
//                                       child: InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             fileImg.removeAt(index);
//                                           });
//                                         },
//                                         child: Card(
//                                           elevation: 4,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(2.0),
//                                             child: Icon(
//                                               Icons.close,
//                                               size: 13,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             );
//                           }),
//                     )
//                   : SizedBox(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showPicker(context) {
//     showModalBottomSheet(
//         context: context,
//         builder: (BuildContext bc) {
//           return SafeArea(
//             child: Container(
//               child: new Wrap(
//                 children: <Widget>[
//                   new ListTile(
//                       leading: new Icon(Icons.photo_library),
//                       title: new Text('Photo Gallery'),
//                       onTap: () {
//                         open_gallery();
//                         // loadAssets();
//                         Navigator.of(context).pop();
//                       }),
//                   new ListTile(
//                     leading: new Icon(Icons.photo_camera),
//                     title: new Text('Camera'),
//                     onTap: () {
//                       open_camera();
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
// }
