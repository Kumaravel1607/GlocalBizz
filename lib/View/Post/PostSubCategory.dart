import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/Post/BikePost.dart';
import 'package:glocal_bizz/View/Post/CarPost.dart';
import 'package:glocal_bizz/View/Post/JobPost.dart';
import 'package:glocal_bizz/View/Post/Lands&PlotPost.dart';
import 'package:glocal_bizz/View/Post/Office&ShopRentSell.dart';
import 'package:glocal_bizz/View/Post/PG&GustHousePost.dart';
import 'package:glocal_bizz/View/Post/PropertyPost.dart';
import 'package:http/http.dart' as http;

import '../AddNewPost.dart';

class PostSubCategoryPage extends StatefulWidget {
  final int category_id;
  PostSubCategoryPage({Key key, this.category_id}) : super(key: key);

  @override
  _PostSubCategoryPageState createState() => _PostSubCategoryPageState();
}

class _PostSubCategoryPageState extends State<PostSubCategoryPage> {
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subcategory_list();
  }

  void subcategory_list() async {
    Map data = {
      'category_id': widget.category_id.toString(),
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/subcategory"), body: data);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print("-----NK-----");
      print(result);
      setState(() {
        _isLoading = true;
      });

      get_subcategoryList(result).then((value) {
        setState(() {
          sucategoryList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("error");
    }
  }

  List<SubCategoryList> sucategoryList = List<SubCategoryList>();

  Future<List<SubCategoryList>> get_subcategoryList(categorysJson) async {
    var subcategorys = List<SubCategoryList>();
    for (var categoryJson in categorysJson) {
      subcategorys.add(SubCategoryList.fromJson(categoryJson));
    }
    return subcategorys;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "SubCategory",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? new ListView.builder(
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              itemCount: sucategoryList.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 30, right: 25),
                      title: Text(
                        sucategoryList[index].sub_category_name,
                        style: TextStyle(
                            fontSize: 16,
                            color: black,
                            fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onTap: () {
                        print(sucategoryList[index].sub_category_type);
                        print("nandhu");
                        switch (sucategoryList[index].sub_category_type) {
                          case "cars":
                            {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(CupertinoPageRoute(
                                      builder: (_) => CarPost(
                                          subcat_type: sucategoryList[index]
                                              .sub_category_type,
                                          cat_id: widget.category_id.toString(),
                                          subcat_id: sucategoryList[index]
                                              .id
                                              .toString())));
                            }
                            break;
                          case "bike":
                            {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(CupertinoPageRoute(
                                      builder: (_) => BikePost(
                                          subcat_type: sucategoryList[index]
                                              .sub_category_type,
                                          cat_id: widget.category_id.toString(),
                                          subcat_id: sucategoryList[index]
                                              .id
                                              .toString())));
                            }
                            break;
                          case "sale-property":
                          case "rent-property":
                            {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(CupertinoPageRoute(
                                      builder: (_) => PropertyPost(
                                          subcat_type: sucategoryList[index]
                                              .sub_category_type,
                                          cat_id: widget.category_id.toString(),
                                          subcat_id: sucategoryList[index]
                                              .id
                                              .toString())));
                            }
                            break;
                          case "rent-shop":
                          case "sale-shop":
                            {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(CupertinoPageRoute(
                                      builder: (_) => OfficeAndShopRentAndSell(
                                          subcat_type: sucategoryList[index]
                                              .sub_category_type,
                                          cat_id: widget.category_id.toString(),
                                          subcat_id: sucategoryList[index]
                                              .id
                                              .toString())));
                            }
                            break;
                          case "lands-plots":
                            {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(CupertinoPageRoute(
                                      builder: (_) => LandsAndPlot(
                                          subcat_type: sucategoryList[index]
                                              .sub_category_type,
                                          cat_id: widget.category_id.toString(),
                                          subcat_id: sucategoryList[index]
                                              .id
                                              .toString())));
                            }
                            break;
                          case "pg":
                            {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(CupertinoPageRoute(
                                      builder: (_) => PGandGustHouse(
                                          subcat_type: sucategoryList[index]
                                              .sub_category_type,
                                          cat_id: widget.category_id.toString(),
                                          subcat_id: sucategoryList[index]
                                              .id
                                              .toString())));
                            }
                            break;
                          case "jobs":
                            {
                              // print(sucategoryList[index].sub_category_name);
                              // print(sucategoryList[index].sub_category_type);
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(CupertinoPageRoute(
                                      builder: (_) => JobPost(
                                          subcat_type: sucategoryList[index]
                                              .sub_category_type,
                                          cat_id: widget.category_id.toString(),
                                          subcat_id: sucategoryList[index]
                                              .id
                                              .toString(),
                                          jobCategory: sucategoryList[index]
                                              .sub_category_name)));
                            }
                            break;
                          default:
                            {
                              Navigator.of(context, rootNavigator: true).push(
                                  CupertinoPageRoute(
                                      builder: (_) => AddNewPost(
                                          cat_id: widget.category_id.toString(),
                                          subcat_id: sucategoryList[index]
                                              .id
                                              .toString())));
                            }
                            break;
                        }
                        // if (sucategoryList[index].sub_category_type == "cars") {
                        //   Navigator.of(context, rootNavigator: true)
                        //       .pushReplacement(CupertinoPageRoute(
                        //           builder: (_) => CarPost(
                        //               subcat_type: sucategoryList[index]
                        //                   .sub_category_type,
                        //               cat_id: widget.category_id.toString(),
                        //               subcat_id: sucategoryList[index]
                        //                   .id
                        //                   .toString())));
                        // } else if (sucategoryList[index].sub_category_type ==
                        //     "bike") {
                        //   Navigator.of(context, rootNavigator: true)
                        //       .pushReplacement(CupertinoPageRoute(
                        //           builder: (_) => BikePost(
                        //               subcat_type: sucategoryList[index]
                        //                   .sub_category_type,
                        //               cat_id: widget.category_id.toString(),
                        //               subcat_id: sucategoryList[index]
                        //                   .id
                        //                   .toString())));
                        // } else if (sucategoryList[index].sub_category_type ==
                        //         "sale-property" ||
                        //     sucategoryList[index].sub_category_type ==
                        //         "rent-property") {
                        //   Navigator.of(context, rootNavigator: true)
                        //       .pushReplacement(CupertinoPageRoute(
                        //           builder: (_) => PropertyPost(
                        //               subcat_type: sucategoryList[index]
                        //                   .sub_category_type,
                        //               cat_id: widget.category_id.toString(),
                        //               subcat_id: sucategoryList[index]
                        //                   .id
                        //                   .toString())));
                        // } else {
                        //   Navigator.of(context, rootNavigator: true).push(
                        //       CupertinoPageRoute(
                        //           builder: (_) => AddNewPost(
                        //               cat_id: widget.category_id.toString(),
                        //               subcat_id: sucategoryList[index]
                        //                   .id
                        //                   .toString())));
                        // }
                      },
                    ),
                    divider3(),
                  ],
                );
              })
          : Center(
              child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
            )),
    );
  }
}
