import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'CommonPage_help_support.dart.dart';
import 'package:glocal_bizz/View/ChangePassword/ChangePassword.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:http/http.dart' as http;

class HelpAndSupport extends StatefulWidget {
  HelpAndSupport({Key key}) : super(key: key);

  @override
  _HelpAndSupportState createState() => _HelpAndSupportState();
}

class _HelpAndSupportState extends State<HelpAndSupport> {
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_list();
  }

  void get_list() async {
    var response = await http.get(Uri.parse(api_url + "/pages_list"));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print(result);
      setState(() {
        _isLoading = true;
      });

      get_allList(result).then((value) {
        setState(() {
          helpList = value;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("error");
    }
  }

  List<HelpSupport> helpList = List<HelpSupport>();

  Future<List<HelpSupport>> get_allList(helpsJson) async {
    var subhelps = List<HelpSupport>();
    for (var helpJson in helpsJson) {
      subhelps.add(HelpSupport.fromJson(helpJson));
    }
    return subhelps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Help and Support",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? new ListView.builder(
                shrinkWrap: false,
                scrollDirection: Axis.vertical,
                itemCount: helpList.length,
                itemBuilder: (context, index) {
                  return list(helpList[index]);
                })
            : Center(
                child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
              )),
      )),
    );
  }

  // void about_us() {
  //   Navigator.of(context).push(CupertinoPageRoute(
  //       builder: (_) => HelpSupport_CommonPages(pageName: "about-us")));
  // }

  // void covid_19() {
  //   Navigator.of(context).push(CupertinoPageRoute(
  //       builder: (_) => HelpSupport_CommonPages(
  //           pageName: "covid-19-safety-tips-or-rules")));
  // }

  // void privacy_policy() {
  //   Navigator.of(context).push(CupertinoPageRoute(
  //       builder: (_) => HelpSupport_CommonPages(
  //           pageName: "products-services-listing-policy")));
  // }

  // void safety_tips() {
  //   Navigator.of(context).push(CupertinoPageRoute(
  //       builder: (_) =>
  //           HelpSupport_CommonPages(pageName: "safety-tips-for-any-froud")));
  // }

  // void terms_condition() {
  //   Navigator.of(context).push(CupertinoPageRoute(
  //       builder: (_) =>
  //           HelpSupport_CommonPages(pageName: "terms-and-condition")));
  // }

  // void change_password() {
  //   Navigator.of(context)
  //       .push(CupertinoPageRoute(builder: (_) => ChangeNewPassword()));
  // }

  Widget list(HelpSupport helpList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 30, right: 25),
          title: Text(
            helpList.page_name,
            style: TextStyle(
                fontSize: 16, color: color2, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: color2,
            size: 20,
          ),
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) =>
                    HelpSupport_CommonPages(pageName: helpList.page_slug)));
          },
        ),
        divider3(),
      ],
    );
  }
}
