import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/View/AddNewPost.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';

class CarPost extends StatefulWidget {
  final String subcat_type;
  final String cat_id;
  final String subcat_id;
  CarPost({Key key, this.subcat_type, this.cat_id, this.subcat_id})
      : super(key: key);

  @override
  _CarPostState createState() => _CarPostState();
}

class _CarPostState extends State<CarPost> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController model = new TextEditingController();
  final TextEditingController yearOfRegister = new TextEditingController();
  final TextEditingController engineSize = new TextEditingController();
  final TextEditingController kmDriven = new TextEditingController();

  String seller;
  String brand;
  String fuelType;
  String transmition;
  String noOfOwner;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDropdownValues();
  }

  List allBrands = List();
  List fuelList = List();
  List transmissionList = List();
  List ownersList = List();
  List sellersList = List();
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
      allBrands = resBody['car-brand'];
      fuelList = resBody['fuel-type'];
      transmissionList = resBody['transmission'];
      ownersList = resBody['owners'];
      sellersList = resBody['seller_by'];
    });
    print(allBrands);
    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Post Car",
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
                  decoration: textDecoration('brand *', "Brand *"),
                  style: TextStyle(fontSize: 14),
                  items: allBrands.map((item) {
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
                      brand = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Select brand ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter car model';
                    }
                    return null;
                  },
                  onSaved: (String value) {},
                  controller: model,
                  onTap: () {},
                  style: TextStyle(
                    fontSize: 14.0,
                    color: black,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: textDecoration(
                    'Enter Car Model ',
                    'Model *',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter car Registration year';
                    }
                    return null;
                  },
                  onSaved: (String value) {},
                  controller: yearOfRegister,
                  onTap: () {},
                  style: TextStyle(
                    fontSize: 14.0,
                    color: black,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: textDecoration(
                    'Enter Car Registration Year ',
                    'Registration Year *',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Fuel', "Fuel *"),
                  style: TextStyle(fontSize: 14),
                  items: fuelList.map((item) {
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
                      fuelType = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select fuel type ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter car Engine Size';
                    }
                    return null;
                  },
                  onSaved: (String value) {},
                  controller: engineSize,
                  onTap: () {},
                  style: TextStyle(
                    fontSize: 14.0,
                    color: black,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: textDecoration(
                    'Enter Car Engine Size',
                    'Engine CC *',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Transmission', "Transmission *"),
                  style: TextStyle(fontSize: 14),
                  items: transmissionList.map((item) {
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
                      transmition = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select transmission ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter KM driven';
                    }
                    return null;
                  },
                  onSaved: (String value) {},
                  controller: kmDriven,
                  onTap: () {},
                  style: TextStyle(
                    fontSize: 14.0,
                    color: black,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: textDecoration(
                    'Enter Car KM driven ',
                    'KM driven *',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('No Of Owner', "No Of Owner *"),
                  style: TextStyle(fontSize: 14),
                  items: ownersList.map((item) {
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
                      noOfOwner = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select No Of Owner ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Seller', "Seller *"),
                  style: TextStyle(fontSize: 14),
                  items: sellersList.map((item) {
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
                      seller = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Select Seller ' : null,
                ),
                SizedBox(
                  height: 50,
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
      Map carsData = {
        'sub_category_type': "cars",
        'brand_id': brand,
        'model': model.text,
        'registration_date': yearOfRegister.text,
        'fuel_type': fuelType,
        'engine_size': engineSize.text,
        'transmission': transmition,
        'km_driven': kmDriven.text,
        'no_of_owner': noOfOwner,
        'seller_by': seller,
      };

      print(carsData);
      Navigator.of(context, rootNavigator: true).pushReplacement(
          CupertinoPageRoute(
              builder: (_) => AddNewPost(
                  cat_id: widget.cat_id.toString(),
                  subcat_id: widget.subcat_id,
                  mapdata: carsData)));
    }
  }
}
