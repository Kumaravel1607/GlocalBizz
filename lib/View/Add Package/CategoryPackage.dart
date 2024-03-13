import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/Add%20Package/Packages.dart';
import 'package:http/http.dart' as http;

class CategoryPackage extends StatefulWidget {
  final String pkg_type;
  final String title;
  CategoryPackage({Key key, this.pkg_type, this.title}) : super(key: key);

  @override
  _CategoryPackageState createState() => _CategoryPackageState();
}

class _CategoryPackageState extends State<CategoryPackage> {
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    category_list();
  }

  void category_list() async {
    var response = await http.get(Uri.parse(api_url + "/category"));
    // print("-------NK-------");
    // print(json.decode(response.body));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print("-----NK-----");
      print(result);
      setState(() {
        _isLoading = true;
      });

      get_categoryList(result).then((value) {
        setState(() {
          categoryList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("error");
    }
  }

  List<CategoryList> categoryList = List<CategoryList>();

  Future<List<CategoryList>> get_categoryList(categorysJson) async {
    var categorys = List<CategoryList>();
    for (var categoryJson in categorysJson) {
      categorys.add(CategoryList.fromJson(categoryJson));
    }
    return categorys;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f8f8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: white),
        title: Text(
          "Choose a Category",
          style: TextStyle(color: white, fontFamily: "Poppins"),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? new ListView.builder(
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[350], width: 0.5),
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 30, right: 25),
                    title: Text(
                      categoryList[index].category_name,
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500),
                    ),
                    leading: CachedNetworkImage(
                      imageUrl: categoryList[index].category_image,
                      height: 35,
                      width: 35,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(
                              builder: (_) => SelectPackages(
                                  title: widget.title,
                                  pkg_type: widget.pkg_type,
                                  category_id:
                                      categoryList[index].id.toString())));
                    },
                  ),
                );
              })
          : Center(
              child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
            )),
    );
  }
}
