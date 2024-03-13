import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/Add%20Package/Packages.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'PostSubCategory.dart';

class PostCategoryPage extends StatefulWidget {
  PostCategoryPage({Key key}) : super(key: key);

  @override
  _PostCategoryPageState createState() => _PostCategoryPageState();
}

class _PostCategoryPageState extends State<PostCategoryPage> {
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

  Future<void> checkAD(catID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': sharedPreferences.getString("user_id"),
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/check_ads"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (context) => PostSubCategoryPage(category_id: catID)));
      print(jsonResponse);
    } else if (response.statusCode == 422) {
      _alerDialog("Please buy a ads", catID);
    } else {
      print("error");
      print(json.decode(response.body));
    }
  }

  Future<void> _alerDialog(message, catID) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: Colors.red[800],
                ),
                SizedBox(
                  width: 11,
                ),
                Text(
                  "Alert !!",
                  style: TextStyle(
                      color: Colors.red[800], fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(color: color2, fontWeight: FontWeight.w500),
            ),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, "ok");
                },
                child: const Text(
                  "NO",
                  style: TextStyle(color: color2, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                    primary: primaryColor,
                    side: BorderSide(width: 1.2, color: color2)),
              ),
              SizedBox(
                width: 7,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                      CupertinoPageRoute(
                          builder: (_) => SelectPackages(
                              title: "Choose Package",
                              pkg_type: "2",
                              category_id: catID.toString())));
                },
                child: const Text(
                  "BUY NOW",
                  style: TextStyle(color: white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(
                        // fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: white)),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: white),
        title: Text(
          "Choose a Category",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? new ListView.builder(
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 30, right: 25),
                      title: Text(
                        categoryList[index].category_name,
                        style: TextStyle(
                            fontSize: 16,
                            color: black,
                            fontWeight: FontWeight.w500),
                      ),
                      leading: CachedNetworkImage(
                        imageUrl: categoryList[index].category_image,
                        height: 35,
                        width: 35,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onTap: () {
                        checkAD(categoryList[index].id);
                      },
                    ),
                    divider(),
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
