import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:http/http.dart' as http;

import '../AddNewPost.dart';

class JobPost extends StatefulWidget {
  final String subcat_type;
  final String cat_id;
  final String subcat_id;
  final String jobCategory;
  JobPost(
      {Key key,
      this.subcat_type,
      this.cat_id,
      this.subcat_id,
      this.jobCategory})
      : super(key: key);

  @override
  _JobPostState createState() => _JobPostState();
}

class _JobPostState extends State<JobPost> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // final TextEditingController title = new TextEditingController();
  final TextEditingController description = new TextEditingController();
  final TextEditingController companyname = new TextEditingController();
  final TextEditingController yearOfRegister = new TextEditingController();
  final TextEditingController minsalary = new TextEditingController();
  final TextEditingController maxsalary = new TextEditingController();
  final TextEditingController expfrom = new TextEditingController();
  final TextEditingController expto = new TextEditingController();
  final TextEditingController price = new TextEditingController();

  String salarytype;
  String jobtype;
  String type;
  String qualification;
  String english;
  String experience;
  String gender;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDropdownValues();
  }

  List typeList = List();
  List salarytypeList = List();
  List jobtypeList = List();
  List qualificationList = List();
  List englishList = List();
  List experienceList = List();
  List genderList = List();

  Future<String> getDropdownValues() async {
    Map data = {
      'attribute_id': "jobs",
    };
    var res =
        await http.post(Uri.parse(api_url + "/attribute_mutiple"), body: data);
    var resBody = (json.decode(res.body));
    setState(() {
      typeList = resBody['jobs-category'];
      salarytypeList = resBody['salary-period'];
      jobtypeList = resBody['job_type'];
      qualificationList = resBody['qualification'];
      englishList = resBody['english '];
      experienceList = resBody['experience '];
      genderList = resBody['gender '];
    });
    return "Success";
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Job Post",
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
                  validator: (value) => value == null ? 'Type' : null,
                ),
                // SizedBox(
                //   height: 15,
                // ),
                // TextFormField(
                //   validator: (value) {
                //     if (value.isEmpty) {
                //       return 'Please enter job Title';
                //     }
                //     return null;
                //   },
                //   onSaved: (String value) {},
                //   controller: title,
                //   onTap: () {},
                //   style: TextStyle(
                //     fontSize: 14.0,
                //     color: black,
                //   ),
                //   keyboardType: TextInputType.text,
                //   decoration: textDecoration(
                //     'Enter Job Title ',
                //     'Job Title *',
                //   ),
                // ),
                // SizedBox(
                //   height: 15,
                // ),
                // TextFormField(
                //   validator: (value) {
                //     if (value.isEmpty) {
                //       return 'Please enter job description';
                //     }
                //     return null;
                //   },
                //   onSaved: (String value) {},
                //   controller: description,
                //   minLines: 1,
                //   maxLines: 4,
                //   onTap: () {},
                //   style: TextStyle(
                //     fontSize: 14.0,
                //     color: black,
                //   ),
                //   keyboardType: TextInputType.multiline,
                //   decoration: textDecoration(
                //     'Enter Job Description ',
                //     'Job Description *',
                //   ),
                // ),
                widget.jobCategory == "I need a Job"
                    ? SizedBox()
                    : SizedBox(
                        height: 15,
                      ),
                widget.jobCategory == "I need a Job"
                    ? SizedBox()
                    : TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter Company name';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: companyname,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                          color: black,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration(
                          'Enter Company Name ',
                          'Company Name *',
                        ),
                      ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: textDecoration('Job Type', "Job Type *"),
                  style: TextStyle(fontSize: 14),
                  items: jobtypeList.map((item) {
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
                      jobtype = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Job Type' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: widget.jobCategory == "I need a Job"
                      ? textDecoration('Qualification', "Qualification *")
                      : textDecoration(
                          'Minimum Qualification', "Minimum Qualification *"),
                  style: TextStyle(fontSize: 14),
                  items: qualificationList.map((item) {
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
                      qualification = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Job qualification' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      textDecoration('Salary Period *', "Salary Period *"),
                  style: TextStyle(fontSize: 14),
                  items: salarytypeList.map((item) {
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
                      salarytype = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Salary Period  ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter Minimum Salary';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: minsalary,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                          color: black,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration(
                          'Enter minimum salary ',
                          'Min Salary *',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter max salary';
                          }
                          return null;
                        },
                        onSaved: (String value) {},
                        controller: maxsalary,
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14.0,
                          color: black,
                        ),
                        keyboardType: TextInputType.text,
                        decoration: textDecoration(
                          'Enter Max Salary ',
                          'Max Salary *',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: widget.jobCategory == "I need a Job"
                      ? textDecoration('English', "English *")
                      : textDecoration(
                          'English Required ', "English Required *"),
                  style: TextStyle(fontSize: 14),
                  items: englishList.map((item) {
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
                      english = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'English Required  ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      textDecoration('Work Experience ', "Experience *"),
                  style: TextStyle(fontSize: 14),
                  items: experienceList.map((item) {
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
                      experience = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Work Experience  ' : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  decoration: widget.jobCategory == "I need a Job"
                      ? textDecoration('Gender ', "Gender *")
                      : textDecoration(
                          'Gender Preference ', "Gender Preference *"),
                  style: TextStyle(fontSize: 14),
                  items: genderList.map((item) {
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
                      gender = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Gender Preference  ' : null,
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
      print(widget.subcat_type);
      Map jobData = widget.jobCategory == "I need a Job"
          ? {
              'sub_category_type': widget.subcat_type,
              'jobs_category': type,
              'salary_period': salarytype,
              'job_type': jobtype,
              'qualification': qualification,
              'english': english,
              'experience': experience,
              'gender': gender,
              'salary_from': minsalary.text,
              'salary_to': maxsalary.text,
            }
          : {
              'sub_category_type': widget.subcat_type,
              'jobs_category': type,
              'company_name': companyname.text,
              'salary_period': salarytype,
              'job_type': jobtype,
              'qualification': qualification,
              'english': english,
              'experience': experience,
              'gender': gender,
              'salary_from': minsalary.text,
              'salary_to': maxsalary.text,
            };

      print(jobData);
      Navigator.of(context, rootNavigator: true).pushReplacement(
          CupertinoPageRoute(
              builder: (_) => AddNewPost(
                  cat_id: widget.cat_id.toString(),
                  subcat_id: widget.subcat_id,
                  mapdata: jobData,
                  productType: widget.subcat_type)));
    }
  }
}
