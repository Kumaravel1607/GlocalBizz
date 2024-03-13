import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/View/AddNewPost.dart';
import 'package:http/http.dart' as http;

class PGandGustHouse extends StatefulWidget {
  final String subcat_type;
  final String cat_id;
  final String subcat_id;
  PGandGustHouse({Key key, this.subcat_type, this.cat_id, this.subcat_id})
      : super(key: key);

  @override
  _PGandGustHouseState createState() => _PGandGustHouseState();
}

class _PGandGustHouseState extends State<PGandGustHouse> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String type;
  String addListedBY;
  String furnished;
  String carparking;
  String meals;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDropdownValues();
  }

  List typeList = List();
  List furnishedList = List();
  List addListedBYList = List();
  List parkingSpaceList = List();
  List mealsList = List();

  Future<String> getDropdownValues() async {
    Map data = {
      'attribute_id': widget.subcat_type,
    };
    var res =
        await http.post(Uri.parse(api_url + "/attribute_mutiple"), body: data);
    var resBody = (json.decode(res.body));
    print("---------------NK-----------------");
    print(resBody);
    setState(() {
      typeList = resBody['subtype'];
      furnishedList = resBody['furnished'];
      addListedBYList = resBody['listed-by'];
      parkingSpaceList = resBody['car-parking-space'];
      mealsList = resBody['meals-included'];
    });
    // print(allBrands);
    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "PG & Guest House",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Type', "Type *"),
                  style: TextStyle(fontSize: 14),
                  items: typeList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item["id"].toString(),
                      child: new Text(
                        item['attribute_list_name'],
                        style: TextStyle(
                          color: color2,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      type = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Select type ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('furnished', "Furnished *"),
                  style: TextStyle(fontSize: 14),
                  items: furnishedList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item["id"].toString(),
                      child: new Text(
                        item['attribute_list_name'],
                        style: TextStyle(
                          color: color2,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      furnished = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select furnished ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Listed By', "Listed By *"),
                  style: TextStyle(fontSize: 14),
                  items: addListedBYList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item["id"].toString(),
                      child: new Text(
                        item['attribute_list_name'],
                        style: TextStyle(
                          color: color2,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      addListedBY = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select listed by ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Car Parking', "Car Parking *"),
                  style: TextStyle(fontSize: 14),
                  items: parkingSpaceList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item["id"].toString(),
                      child: new Text(
                        item['attribute_list_name'],
                        style: TextStyle(
                          color: color2,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      carparking = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select Car Parking ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      textDecoration('Meals Included', "Meals Included *"),
                  style: TextStyle(fontSize: 14),
                  items: mealsList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item["id"].toString(),
                      child: new Text(
                        item['attribute_list_name'],
                        style: TextStyle(
                          color: color2,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      meals = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select Meals Included ' : null,
                ),
                SizedBox(
                  height: 60,
                ),
                Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: ElevatedBtn1(submitButton, "Next")),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map pgData = {
        'sub_category_type': widget.subcat_type,
        'pg_sub_type': type,
        'furnished': furnished,
        'listed_by': addListedBY,
        'car_parking_space': carparking,
        'meal_included': meals,
      };

      print(pgData);
      Navigator.of(context, rootNavigator: true).pushReplacement(
          CupertinoPageRoute(
              builder: (_) => AddNewPost(
                  cat_id: widget.cat_id.toString(),
                  subcat_id: widget.subcat_id,
                  mapdata: pgData,
                  productType: widget.subcat_type)));
    }
  }
}
