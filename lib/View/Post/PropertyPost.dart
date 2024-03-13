import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:glocal_bizz/View/AddNewPost.dart';
import 'package:http/http.dart' as http;

class PropertyPost extends StatefulWidget {
  final String subcat_type;
  final String cat_id;
  final String subcat_id;
  PropertyPost({Key key, this.subcat_type, this.cat_id, this.subcat_id})
      : super(key: key);

  @override
  _PropertyPostState createState() => _PropertyPostState();
}

class _PropertyPostState extends State<PropertyPost> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController floor = new TextEditingController();
  final TextEditingController superBuildupArea = new TextEditingController();
  final TextEditingController carpetArea = new TextEditingController();
  final TextEditingController rent = new TextEditingController();

  String propertyType;
  String roomType;
  String furnished;
  String constructionStatus;
  String addListedBY;
  String carParkingSpace;
  String facing;
  String whom;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDropdownValues();
  }

  List propertyTypeList = List();
  List roomTypeList = List();
  List furnishedList = List();
  List constructionStatusList = List();
  List addListedBYList = List();
  List carParkingSpaceList = List();
  List facingList = List();
  List whomList = List();
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
      propertyTypeList = resBody['type-of-property'];
      roomTypeList = resBody['bedrooms-type'];
      furnishedList = resBody['furnished'];
      constructionStatusList = resBody['construction-status'];
      addListedBYList = resBody['listed-by'];
      carParkingSpaceList = resBody['car-parking-space'];
      facingList = resBody['facing'];
      whomList = resBody['rent_for_whom'];
    });
    // print(allBrands);
    return "Success";
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Property",
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
                  decoration:
                      textDecoration('Type Of Property', "Type Of Property *"),
                  style: TextStyle(fontSize: 14),
                  items: propertyTypeList.map((item) {
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
                      propertyType = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select property type ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      textDecoration('Type Of Rooms', "Type Of Rooms *"),
                  style: TextStyle(fontSize: 14),
                  items: roomTypeList.map((item) {
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
                      roomType = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select Bedroom type ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter floor';
                    }
                    return null;
                  },
                  onSaved: (String value) {},
                  controller: floor,
                  onTap: () {},
                  style: TextStyle(
                    fontSize: 14.0,
                    color: black,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: textDecoration(
                    'Enter floor ',
                    'Floor *',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
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
                  validator: (value) =>
                      value == null ? 'Select construction status ' : null,
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
                DropdownButtonFormField<String>(
                  decoration: textDecoration(
                      'Car Parking Space', "Car Parking Space *"),
                  style: TextStyle(fontSize: 14),
                  items: carParkingSpaceList.map((item) {
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
                      carParkingSpace = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select car parking space ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Facing', "Facing *"),
                  style: TextStyle(fontSize: 14),
                  items: facingList.map((item) {
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
                      facing = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Select Facing ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                // widget.subcat_type == "sale-property"
                //     ? SizedBox()
                //     : TextFormField(
                //         validator: (value) {
                //           if (value.isEmpty) {
                //             return 'Please enter Rent rate';
                //           }
                //           return null;
                //         },
                //         onSaved: (String value) {},
                //         controller: rent,
                //         onTap: () {},
                //         style: TextStyle(
                //           fontSize: 14.0,
                //           color: black,
                //         ),
                //         keyboardType: TextInputType.text,
                //         decoration: textDecoration(
                //           'Enter Rent ',
                //           'Rent *',
                //         ),
                //       ),
                // SizedBox(
                //   height: 15,
                // ),
                widget.subcat_type == "sale-property"
                    ? SizedBox()
                    : DropdownButtonFormField<String>(
                        decoration: textDecoration('For Whom', "For Whom *"),
                        style: TextStyle(fontSize: 14),
                        items: whomList.map((item) {
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
                            whom = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Select for whom ' : null,
                      ),
                widget.subcat_type == "sale-property"
                    ? SizedBox()
                    : SizedBox(
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
      Map propertyData = widget.subcat_type == "sale-property"
          ? {
              'sub_category_type': widget.subcat_type,
              'type_of_property': propertyType,
              'bedrooms_type': roomType,
              'floor': floor.text,
              'furnished': furnished,
              'construction_status': constructionStatus,
              'listed_by': addListedBY,
              'super_buildup_area_sq_ft': superBuildupArea.text,
              'carpet_area_sq_ft': carpetArea.text,
              'car_parking_space': carParkingSpace,
              'facing': facing,
            }
          : {
              'sub_category_type': widget.subcat_type,
              'type_of_property': propertyType,
              'bedrooms_type': roomType,
              'floor': floor.text,
              'furnished': furnished,
              'construction_status': constructionStatus,
              'listed_by': addListedBY,
              'super_buildup_area_sq_ft': superBuildupArea.text,
              'carpet_area_sq_ft': carpetArea.text,
              'car_parking_space': carParkingSpace,
              'facing': facing,
              // 'rent_monthly': rent.text,
              'form_whom': whom,
            };

      print(propertyData);
      Navigator.of(context, rootNavigator: true).pushReplacement(
          CupertinoPageRoute(
              builder: (_) => AddNewPost(
                  cat_id: widget.cat_id.toString(),
                  subcat_id: widget.subcat_id,
                  mapdata: propertyData,
                  productType: widget.subcat_type)));
    }
  }
}
