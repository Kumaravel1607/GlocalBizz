import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HelpSupport_CommonPages extends StatefulWidget {
  final String pageName;
  HelpSupport_CommonPages({Key key, this.pageName}) : super(key: key);

  @override
  _HelpSupport_CommonPagesState createState() =>
      _HelpSupport_CommonPagesState();
}

class _HelpSupport_CommonPagesState extends State<HelpSupport_CommonPages> {
  SharedPreferences prefs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getDeta();
  }

  String aboutus;
  String title;

  Future<void> getDeta() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'page_name': widget.pageName,
    };
    var response;
    response = await http.post(Uri.parse(api_url + "/pages"), body: data);
    // print("json.decode(response.body)");
    // print(json.decode(response.body));
    if (response.statusCode == 200) {
      var data = (json.decode(response.body));
      setState(() {
        title = data['page_name'];
        aboutus = data['page_description'];
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text(
                title,
                style: TextStyle(color: white),
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: white),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: color2,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    HtmlWidget(aboutus),
                  ],
                ),
              )),
            ),
          )
        : Scaffold(
            body: Center(
              child: Loading(),
            ),
          );
  }
}
