import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Widgets/ElevateButton_1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  ContactUsPage({Key key}) : super(key: key);

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

final TextEditingController email = new TextEditingController();
final TextEditingController message = new TextEditingController();

class _ContactUsPageState extends State<ContactUsPage> {
  bool _isLoading = false;
  SharedPreferences sharedPreferences;

  sendmessage(
    msg,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'customer_id': sharedPreferences.getString("user_id"),
      'message': msg,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/contact_us"), body: data);
    print(response.body.toString());

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        message.clear();
        setState(() {
          _isLoading = false;
        });
        _alerDialog(jsonResponse['message']);
        // Navigator.of(context).pop();
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      }
    } else {
      jsonResponse = json.decode(response.body);
      _alerDialog(jsonResponse['message']);
      setState(() {
        _isLoading = false;
      });
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
                  Navigator.pop(context, "ok");
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: color2),
                ),
              )
            ],
          );
        });
  }

  Future<void> _alerBox() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Please Write your message"),
            //title: Text(),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
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
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Contact us",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "We'd Love to Hear from you",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 22, color: black, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                maxLines: 5,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Write Message';
                  }
                  return null;
                },
                cursorHeight: 18,
                onSaved: (String value) {},
                controller: message,
                obscureText: false,
                style: TextStyle(
                  fontSize: 14.0,
                  color: black,
                ),
                keyboardType: TextInputType.text,
                decoration: contactTextDecoration('Write Your Message'),
              ),
              SizedBox(height: 30),
              Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: ElevatedBtn1(submitButton, "SUBMIT")),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: primaryColor,
                  ),
                  SizedBox(width: 7),
                  Text(
                    "Office Address",
                    style: TextStyle(
                        color: black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                "        Glocal Bizz MarketPlace (Brand Name)",
                style: TextStyle(
                    color: black, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                "        Of VND INDUSTRIES PVT LTD",
                style: TextStyle(
                    color: black, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                "        Is located at:",
                style: TextStyle(
                    color: black, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                "        B 222 Nehru Colony Dehradun,",
                style: TextStyle(
                    color: black, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                "        248001 - Uttarakhand , India",
                style: TextStyle(
                    color: black, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: telephone,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_android,
                            color: primaryColor,
                          ),
                          SizedBox(width: 7),
                          Text(
                            "Customer Care",
                            style: TextStyle(
                                color: black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        "        0938-9994824",
                        style: TextStyle(
                            color: black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
              ),
              // SizedBox(height: 20),
              // GestureDetector(
              //   onTap: phone,
              //   child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             Icon(
              //               Icons.phone,
              //               color: primaryColor,
              //             ),
              //             SizedBox(width: 7),
              //             Text(
              //               "Phone",
              //               style: TextStyle(
              //                   color: black,
              //                   fontSize: 17,
              //                   fontWeight: FontWeight.bold),
              //             ),
              //           ],
              //         ),
              //         Text(
              //           "        +91 987654321",
              //           style: TextStyle(
              //               color: black,
              //               fontSize: 15,
              //               fontWeight: FontWeight.w500),
              //         ),
              //       ]),
              // ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: mail,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail,
                            color: primaryColor,
                          ),
                          SizedBox(width: 7),
                          Text(
                            "E-mail",
                            style: TextStyle(
                                color: black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        "        support@glocalbizz.com",
                        style: TextStyle(
                            color: black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
              ),
              SizedBox(height: 20),
              // Text(
              //   " Follow Us",
              //   style: TextStyle(
              //       color: black, fontSize: 17, fontWeight: FontWeight.bold),
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     IconButton(
              //       icon: FaIcon(
              //         FontAwesomeIcons.facebookSquare,
              //         size: 40,
              //         color: primaryColor,
              //       ),
              //       onPressed: fb,
              //     ),
              //     IconButton(
              //       icon: FaIcon(
              //         FontAwesomeIcons.twitterSquare,
              //         size: 40,
              //         color: primaryColor,
              //       ),
              //       onPressed: twitter,
              //     ),
              //     IconButton(
              //       icon: FaIcon(
              //         FontAwesomeIcons.instagramSquare,
              //         size: 40,
              //         color: primaryColor,
              //       ),
              //       onPressed: insta,
              //     ),
              //     IconButton(
              //       icon: FaIcon(
              //         FontAwesomeIcons.youtubeSquare,
              //         size: 40,
              //         color: primaryColor,
              //       ),
              //       onPressed: youtube,
              //     ),
              //     IconButton(
              //       icon: FaIcon(
              //         FontAwesomeIcons.linkedin,
              //         size: 40,
              //         color: primaryColor,
              //       ),
              //       onPressed: linkedin,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void submitButton() {
    if (message.text.isEmpty) {
      _alerBox();
    } else {
      sendmessage(
        message.text,
      );
    }
  }

  void telephone() async {
    const url = "tel:04098765";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void phone() async {
    const url = 'tel:987654321';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void mail() async {
    const url = 'mailto:support@glocalbizz.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void fb() async {
    const url = 'https://www.facebook.com/GlocalBizz/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void twitter() async {
    const url = 'https://twitter.com/Glocal_bizz';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void insta() async {
    const url = 'https://www.instagram.com/glocal_bizz/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void youtube() async {
    const url = 'https://www.youtube.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void linkedin() async {
    const url = 'https://www.linkedin.com/company/glocalbizz/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
