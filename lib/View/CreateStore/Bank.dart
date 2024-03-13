import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/ErrorScreen.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class BankPage extends StatefulWidget {
  BankPage({Key key}) : super(key: key);

  @override
  _BankPageState createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController bankName = new TextEditingController();
  final TextEditingController accountNumber = new TextEditingController();
  final TextEditingController ifscCode = new TextEditingController();
  final TextEditingController branchName = new TextEditingController();
  // final TextEditingController upiCode = new TextEditingController();

  SharedPreferences prefs;
  bool _isLoading = false;
  bool _submitLoad = true;
  bool initialLoading = false;

  @override
  void initState() {
    super.initState();
    store_detail();
  }

  store_detail() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'store_id': prefs.getString("store_id"),
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/store_detail"), body: data);
    print(json.decode(response.body));
    var jsonResponse;
    if (response.statusCode == 200) {
      setState(() {
        initialLoading = true;
      });
      jsonResponse = json.decode(response.body);
      print("--------------NK-----------");
      print(jsonResponse['bank_name']);
      print(jsonResponse['account_number']);
      print(jsonResponse['branch']);

      bankName.text = jsonResponse['bank_name'];
      accountNumber.text = jsonResponse['account_number'];
      ifscCode.text = jsonResponse['ifsc'];
      branchName.text = jsonResponse['branch'];
      // upiCode.text = jsonResponse['upi'];
    } else {
      // setState(() {
      //   initialLoading = true;
      // });
      throw Exception('Failed to load post');
    }
  }

  void _updateBank(
    bname,
    accountNo,
    ifsc,
    branch,
    // upi,
  ) async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'id': prefs.getString("store_id"),
      'bank_name': bname,
      'account_number': accountNo,
      'ifsc': ifsc,
      'branch': branch,
      // 'upi': upi,
    };

    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/update_bank"), body: data);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = true;
        _submitLoad = true;
      });
      store_detail();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Your details updated!!'),
        ),
      );
    } else if (response.statusCode == 400) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              ErrorPage(data: response.body.toString())));
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              ErrorPage(data: response.body.toString())));
    } else if (response.statusCode == 500) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => ErrorPage(
              data: 'Error occured while communication with server' +
                  ' with status code : ${response.statusCode}')));
    } else {
      setState(() {
        _isLoading = false;
      });
      jsonResponse = json.decode(response.body);
      _alerDialog(jsonResponse['message']);
    }
  }

  Future<void> _alerDialog(message) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(message),
            //title: Text(),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _submitLoad = true;
                  });
                  Navigator.pop(context, "ok");
                },
                child: const Text("OK"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          // backgroundColor: Color(0xFFf8f8f8),
          backgroundColor: white,
          body: initialLoading
              ? Container(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Text(
                            "Bank Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color2,
                                fontSize: 18),
                          ),
                          Image.asset("assets/bank.png"),

                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
                          //   child: Image.asset("assets/kyc1.png"),
                          // ),
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 25, horizontal: 15),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Add Bank Informations",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                          fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter Bank Name';
                                        }
                                        return null;
                                      },
                                      onSaved: (String value) {},
                                      controller: bankName,
                                      obscureText: false,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: black,
                                      ),
                                      keyboardType: TextInputType.text,
                                      decoration: textDecorate("Bank Name"),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter account number';
                                        }
                                        return null;
                                      },
                                      onSaved: (String value) {},
                                      controller: accountNumber,
                                      obscureText: false,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: black,
                                      ),
                                      keyboardType: TextInputType.text,
                                      decoration:
                                          textDecorate("Account Number"),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter IFSC code';
                                        }
                                        return null;
                                      },
                                      onSaved: (String value) {},
                                      controller: ifscCode,
                                      obscureText: false,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: black,
                                      ),
                                      keyboardType: TextInputType.text,
                                      decoration: textDecorate("IFSC"),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter Branch';
                                        }
                                        return null;
                                      },
                                      onSaved: (String value) {},
                                      controller: branchName,
                                      obscureText: false,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: black,
                                      ),
                                      keyboardType: TextInputType.text,
                                      decoration: textDecorate("Branch Name"),
                                    ),
                                    // SizedBox(
                                    //   height: 15,
                                    // ),
                                    // TextFormField(
                                    //   validator: (value) {
                                    //     if (value.isEmpty) {
                                    //       return 'Please enter UPI';
                                    //     }
                                    //     return null;
                                    //   },
                                    //   onSaved: (String value) {},
                                    //   controller: upiCode,
                                    //   obscureText: false,
                                    //   style: TextStyle(
                                    //     fontSize: 16.0,
                                    //     color: black,
                                    //   ),
                                    //   keyboardType: TextInputType.text,
                                    //   decoration: textDecorate("UPI"),
                                    // ),
                                    // SizedBox(
                                    //   height: 15,
                                    // ),
                                    SizedBox(
                                      height: 35,
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        child: ElevatedBtn1(
                                            submitButton, "UPDATE")),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Loading(),
        ),
        _submitLoad ? SizedBox() : FullScreenLoading(),
      ],
    );
  }

  void submitButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _submitLoad = false;
      });
      _updateBank(
        bankName.text,
        accountNumber.text,
        ifscCode.text,
        branchName.text,
      );
    }
  }

  textDecorate(String fieldName) => InputDecoration(
        fillColor: white,
        filled: true,
        contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        hintText: (fieldName),
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        border: new OutlineInputBorder(
          borderSide: new BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: new OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: new OutlineInputBorder(
          borderSide: new BorderSide(color: primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      );
}
