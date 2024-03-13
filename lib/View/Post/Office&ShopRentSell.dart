import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/View/AddNewPost.dart';
import 'package:http/http.dart' as http;

class OfficeAndShopRentAndSell extends StatefulWidget {
  final String subcat_type;
  final String cat_id;
  final String subcat_id;
  OfficeAndShopRentAndSell(
      {Key key, this.subcat_type, this.cat_id, this.subcat_id})
      : super(key: key);

  @override
  _OfficeAndShopRentAndSellState createState() =>
      _OfficeAndShopRentAndSellState();
}

class _OfficeAndShopRentAndSellState extends State<OfficeAndShopRentAndSell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController amount = new TextEditingController();
  final TextEditingController superBuildupArea = new TextEditingController();
  final TextEditingController carpetArea = new TextEditingController();
  final TextEditingController washroom = new TextEditingController();
  final TextEditingController monthlyrent = new TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String furnished;
  String constructionStatus;
  String addListedBY;
  String parkingSpace;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDropdownValues();
  }

  List furnishedList = List();
  List constructionStatusList = List();
  List addListedBYList = List();
  List parkingSpaceList = List();

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
      furnishedList = resBody['furnished'];
      constructionStatusList = resBody['construction-status'];
      addListedBYList = resBody['listed-by'];
      parkingSpaceList = resBody['car-parking-space'];
    });
    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Office & Shop",
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
                  decoration: textDecoration('Furnished', "Furnished *"),
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
                  decoration:
                      textDecoration('Add Listed By', "Add Listed By *"),
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
                      value == null ? 'Select add listed by ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter Super Buildup area in Sq ft';
                    }
                    return null;
                  },
                  onSaved: (String value) {},
                  controller: superBuildupArea,
                  onTap: () {},
                  style: TextStyle(
                    fontSize: 14.0,
                    color: black,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: textDecoration(
                    'Enter Super Buildup area in Sq ft ',
                    'Super Buildup area in Sq ft *',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter Carpet Area in Sq ft ';
                    }
                    return null;
                  },
                  onSaved: (String value) {},
                  controller: carpetArea,
                  onTap: () {},
                  style: TextStyle(
                    fontSize: 14.0,
                    color: black,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: textDecoration(
                    'Enter Carpet Area in Sq ft ',
                    'Carpet Area in Sq ft *',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter washroom';
                    }
                    return null;
                  },
                  onSaved: (String value) {},
                  controller: washroom,
                  onTap: () {},
                  style: TextStyle(
                    fontSize: 14.0,
                    color: black,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: textDecoration(
                    'Enter washroom ',
                    'Washrooms *',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                // widget.subcat_type == "rent-shop"
                //     ? TextFormField(
                //         validator: (value) {
                //           if (value.isEmpty) {
                //             return 'Please enter monthly rent';
                //           }
                //           return null;
                //         },
                //         onSaved: (String value) {},
                //         controller: monthlyrent,
                //         onTap: () {},
                //         style: TextStyle(
                //           fontSize: 14.0,
                //           color: black,
                //         ),
                //         keyboardType: TextInputType.text,
                //         decoration: textDecoration(
                //           'Enter monthly Rent ',
                //           'Monthly Rent *',
                //         ),
                //       )
                //     : SizedBox(),
                // widget.subcat_type == "rent-shop"
                //     ? SizedBox(
                //         height: 15,
                //       )
                //     : SizedBox(),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Parking Space', "Parking *"),
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
                      parkingSpace = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select parking space ' : null,
                ),
                // SizedBox(
                //   height: 15,
                // ),
                // widget.subcat_type == "sale-shop"
                //     ? TextFormField(
                //         validator: (value) {
                //           if (value.isEmpty) {
                //             return 'Please enter Rent amount';
                //           }
                //           return null;
                //         },
                //         onSaved: (String value) {},
                //         controller: amount,
                //         onTap: () {},
                //         style: TextStyle(
                //           fontSize: 14.0,
                //           color: black,
                //         ),
                //         keyboardType: TextInputType.text,
                //         decoration: textDecoration(
                //           'Enter Amount ',
                //           'Amount *',
                //         ),
                //       )
                //     : SizedBox(),
                SizedBox(
                  height: 15,
                ),
                widget.subcat_type == "sale-shop"
                    ? DropdownButtonFormField<String>(
                        decoration: textDecoration(
                            'Construction Status', "Construction Status *"),
                        style: TextStyle(fontSize: 14),
                        items: constructionStatusList.map((item) {
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
                            constructionStatus = newValue;
                          });
                        },
                        validator: (value) => value == null
                            ? 'Select construction status '
                            : null,
                      )
                    : SizedBox(),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 30,
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
      Map shopData = widget.subcat_type == "rent-shop"
          ? {
              'sub_category_type': widget.subcat_type,
              'furnished': furnished,
              'listed_by': addListedBY,
              'super_buildup_area_sq_ft': superBuildupArea.text,
              'carpet_area_sq_ft': carpetArea.text,
              'washrooms': washroom.text,
              // 'rent_monthly': monthlyrent.text,
              'car_parking_space': parkingSpace,
            }
          : {
              'sub_category_type': widget.subcat_type,
              'furnished': furnished,
              'listed_by': addListedBY,
              'super_buildup_area_sq_ft': superBuildupArea.text,
              'carpet_area_sq_ft': carpetArea.text,
              'washrooms': washroom.text,
              'car_parking_space': parkingSpace,
              'construction_status': constructionStatus,
              // 'sale_amount': amount.text,
            };

      print(shopData);
      Navigator.of(context, rootNavigator: true).pushReplacement(
          CupertinoPageRoute(
              builder: (_) => AddNewPost(
                  cat_id: widget.cat_id.toString(),
                  subcat_id: widget.subcat_id,
                  mapdata: shopData,
                  productType: widget.subcat_type)));
    }
  }
}
