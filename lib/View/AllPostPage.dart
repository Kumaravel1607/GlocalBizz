// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:glocal_bizz/Controller/api.dart';
// import 'package:glocal_bizz/Controller/constand.dart';
// import 'package:glocal_bizz/Controller/fav_controller.dart';
// import 'package:glocal_bizz/Model/home_model.dart';
// import 'package:glocal_bizz/Widgets/GridWidget.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';
// import 'DetailPage.dart';

// class AllPostPage extends StatefulWidget {
//   final String cat_id;
//   final String subcat_id;
//   AllPostPage({Key key, this.cat_id, this.subcat_id}) : super(key: key);

//   @override
//   _AllPostPageState createState() => _AllPostPageState();
// }

// class _AllPostPageState extends State<AllPostPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//   // bool fav = false;

//   bool _isLoading = false;
//   SharedPreferences prefs;

//   @override
//   void initState() {
//     super.initState();
//     ads_list();
//   }

//   int page = 1;

//   void ads_list() async {
//     prefs = await SharedPreferences.getInstance();
//     Map data = {
//       'page': page.toString(),
//       'limit': limit,
//       'category_id': widget.cat_id,
//       'sub_category_id': widget.subcat_id,
//       'customer_id': prefs.getString("user_id"),
//       'city_id':
//           prefs.getString("city_Id") != null ? prefs.getString("city_Id") : "",
//       'search_text': "",
//       // 'feature_status': "",
//     };
//     print(data);
//     var result;
//     var response = await http.post(Uri.parse(api_url + "/ads"), body: data);

//     // print(json.decode(response.body));
//     if (response.statusCode == 200) {
//       setState(() {
//         _isLoading = true;
//       });
//       result = json.decode(response.body);
//       print("-----NK-----");
//       print(result);

//       if (page == 1) {
//         get_adsList(result).then((value) {
//           setState(() {
//             ads = value;
//           });
//         });
//       } else {
//         get_adsList(result).then((value) {
//           setState(() {
//             ads.addAll(value);
//           });
//         });
//       }
//     } else {
//       print(result);
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   List<AdsList> ads = List<AdsList>();

//   Future<List<AdsList>> get_adsList(adsJson) async {
//     var ads = List<AdsList>();
//     for (var adJson in adsJson) {
//       ads.add(AdsList.fromJson(adJson));
//     }
//     return ads;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orientation = MediaQuery.of(context).orientation;
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Color(0xFFf8f8f8),
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Text(
//           "Posts",
//           style: TextStyle(color: white),
//         ),
//         centerTitle: true,
//         iconTheme: IconThemeData(color: white),
//       ),
//       body: CustomScrollView(slivers: [
//         _isLoading
//             ? ads.length != 0
//                 ? SliverGrid(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisSpacing: 2,
//                         mainAxisSpacing: 3,
//                         childAspectRatio: 0.90,
//                         crossAxisCount:
//                             (orientation == Orientation.portrait) ? 2 : 3),
//                     delegate: SliverChildBuilderDelegate(
//                       (BuildContext context, int index) {
//                         List<String> savedFav = List<String>();
//                         String favID = ads[index].id.toString();
//                         savedFav.remove(favID);
//                         if (ads[index].favorite_status == "1") {
//                           savedFav.add(favID);
//                         }
//                         bool issaved = savedFav.contains(favID);

//                         void selectFav() {
//                           setState(() {
//                             print(savedFav.contains(favID));
//                             if (issaved) {
//                               ads[index].favorite_status = "0";
//                               savedFav.remove(favID);

//                               deleteFav(ads[index].id.toString());
//                             } else {
//                               ads[index].favorite_status = "1";
//                               savedFav.add(favID);
//                               saveFav(ads[index].id.toString());
//                             }
//                           });
//                         }

//                         return GridWidget(issaved, selectFav, ads, index);
//                       },
//                       childCount: ads.length,
//                     ),
//                   )
//                 : SliverToBoxAdapter(
//                     child: Container(
//                         height: MediaQuery.of(context).size.height * 0.6,
//                         alignment: Alignment.bottomCenter,
//                         child: Center(child: Image.asset("assets/nodata.png"))),
//                   )
//             : SliverToBoxAdapter(
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.5,
//                   alignment: Alignment.bottomCenter,
//                   child: CircularProgressIndicator(
//                     valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
//                   ),
//                 ),
//               ),
//       ]),
//     );
//   }
// }
