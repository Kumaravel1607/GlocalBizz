import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';

import 'package:http/http.dart' as http;
import 'SubCategory.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
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
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (context) => SubCategoryPage(
                                    category_id: categoryList[index].id)));
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
