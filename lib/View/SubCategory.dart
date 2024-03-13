import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/SearchList.dart';
import 'package:http/http.dart' as http;

class SubCategoryPage extends StatefulWidget {
  final int category_id;
  SubCategoryPage({Key key, this.category_id}) : super(key: key);

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
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
    var response =
        await http.post(Uri.parse(api_url + "/subcategory"), body: data);
    print(json.decode(response.body));
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
                        Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                                builder: (_) => SearchListPage(
                                    cat_id: widget.category_id.toString(),
                                    subcat_id:
                                        sucategoryList[index].id.toString())));
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
