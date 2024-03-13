import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/BottomTab.dart';
import 'package:glocal_bizz/Widgets/FullScreenLoadingWidget.dart';
import 'package:glocal_bizz/Widgets/auth_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:http/http.dart' as http;
import 'EmailLogin.dart';
import 'Help/CommonPage_help_support.dart.dart';
import 'Home.dart';
import 'OTP.dart';
import 'Regiaster.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController mobileNumber = new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String firebase_id;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getMessage();
  }

  void getMessage() {
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        firebase_id = token;
      });
    });
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("user_id") != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (Route<dynamic> route) => false);
    } else {
      // print("You are not sined in");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    }
  }

  SharedPreferences sharedPreferences;
  String name;
  String email;
  String imageUrl;
  String phone;

  Future<String> signInWithGoogle() async {
    await Firebase.initializeApp();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      setState(() {
        _isLoading = true;
      });
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');

      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoURL != null);
      // Store the retrieved data
      name = user.displayName;
      email = user.email;
      imageUrl = user.photoURL;
      // phone = user.phoneNumber;

      saveUserDetail(
        user.email.toString(),
        user.displayName.toString(),
        user.displayName.toString(),
        user.photoURL.toString(),
        "Google",
        // user.photoURL.toString(),
      );

      sharedPreferences.setString("user_name", user.displayName.toString());
      sharedPreferences.setString("user_email", user.email.toString());
      sharedPreferences.setString("user_image", user.photoURL.toString());
      // sharedPreferences.setString("user_id", user.uid.toString());

      // Only taking the first part of the name, i.e., First Name
      if (name.contains(" ")) {
        name = name.substring(0, name.indexOf(" "));
        sharedPreferences.setString("user_firstname", name.toString());
      }

      return '$user';
    }

    return null;
  }

  // Future<UserCredential> signInWithFacebook() async {
  //   print("-----------------NK--------c-------------");
  //   // Trigger the sign-in flow
  //   final AccessToken result =
  //       (await FacebookAuth.instance.login()) as AccessToken;
  //   print(result);
  //   // Create a credential from the access token
  //   final facebookAuthCredential =
  //       FacebookAuthProvider.credential(result.token);
  //   print("-----------------NK---------------------");

  //   print(facebookAuthCredential);
  //   print(result.token);
  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance
  //       .signInWithCredential(facebookAuthCredential);
  // }
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  String _message = 'Log in/out by pressing the buttons below.';

  Future<Null> signInWithFacebook() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final FacebookLoginResult result =
        await facebookSignIn.logIn(['email', 'public_profile']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        final response = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${accessToken.token}'));
        final profile = jsonDecode(response.body);
        setState(() {
          _isLoading = true;
        });
        print("-------------------NK--------------");
        print(profile);
        sharedPreferences.setString(
            "user_name", profile['first_name'].toString());
        sharedPreferences.setString("user_email", profile['email'].toString());
        saveUserDetail(
            profile['email'].toString(),
            profile['first_name'].toString(),
            profile['last_name'].toString(),
            profile['profile_image'].toString(),
            "Facebook"
            // "",
            );

        break;
      case FacebookLoginStatus.cancelledByUser:
        _alerDialog("Login cancelled by the user.");
        break;
      case FacebookLoginStatus.error:
        _alerDialog('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  Future<void> saveUserDetail(email, fname, lname, image, loginby) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'email': email,
      'first_name': fname,
      'last_name': lname,
      'mobile': "",
      'app_id': firebase_id,
      'profile_image': image,
      'login_by': loginby,
    };
    print(data);
    var jsonResponse;
    var response =
        await http.post(Uri.parse(api_url + "/firebase_signup"), body: data);
    print("--------------------nk---------------");
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = false;
      });
      sharedPreferences.setString(
          "user_id", jsonResponse['user_id'].toString());
      sharedPreferences.setString(
          "store_id", jsonResponse['store_id'].toString());

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => BottomTab()),
          (Route<dynamic> route) => false);
      print(jsonResponse);
    } else {
      print("error");
      print(json.decode(response.body));
    }
  }

  final SmsAutoFill _autoFill = SmsAutoFill();

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Color(0xFFF7A11F),
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      // alignment: Alignment.bottomCenter,
                      // color: appcolor,
                      child: Column(
                        children: [
                          new Image.asset(
                            "assets/glocal_logo.png",
                            height: 170,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Glocal Bizz",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      // padding: EdgeInsets.only(left: 40, right: 40),
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 2),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 23,
                              ),
                              Text(
                                "Welcome To Glocal Bizz",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: color2),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              // AuthButton(
                              //     phoneAuth,
                              //     "    Continue with Phone",
                              //     Icon(
                              //       Icons.mobile_friendly,
                              //       color: primaryColor,
                              //     )),
                              AuthButton(
                                  googleAuth,
                                  "    Continue with Google",
                                  Icon(
                                    Icons.language,
                                    color: primaryColor,
                                  )),
                              AuthButton(
                                  faceBookAuth,
                                  "    Continue with FaceBook",
                                  Icon(
                                    Icons.face,
                                    color: primaryColor,
                                  )),
                              AuthButton(
                                  emailAuth,
                                  "    Continue with Email / Mobile",
                                  Icon(
                                    Icons.mail,
                                    color: primaryColor,
                                  )),
                              SizedBox(
                                height: 15,
                              ),
                              // Text(
                              //   " ",
                              //   textAlign: TextAlign.justify,
                              //   style: TextStyle(
                              //       fontWeight: FontWeight.normal, fontSize: 14),
                              // ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text:
                                        'if you continue Sign up/Login, you are accepting ',
                                    style: TextStyle(
                                        color: black,
                                        fontSize: 13,
                                        fontFamily: "Poppins"),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Glocalbizz ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: 'Terms of Use & ',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .push(MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          HelpSupport_CommonPages(
                                                              pageName:
                                                                  "terms-and-condition")));
                                            },
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: 'Privacy Policy',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .push(MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          HelpSupport_CommonPages(
                                                              pageName:
                                                                  "privacy-policy")));
                                            },
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 7),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Dont't have an account? ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: black),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (_) =>
                                                        RegisterPage()));
                                          },
                                          child: Text('Sign Up',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: primaryColor)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "We will send One time message carrier rates may apply",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _isLoading ? FullScreenLoading() : SizedBox(),
      ],
    );
  }

  send_phoneNumber(
    number,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'mobile_no': number,
    };
    var jsonResponse = null;
    var response =
        await http.post(Uri.parse(api_url + "/sent_otp"), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = true;
        });
        if (jsonResponse['user_id'] != "") {
          sharedPreferences.setString(
              "user_id", jsonResponse['user_id'].toString());
        }

        print(jsonResponse);

        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (BuildContext context) => new BottomTab()),
        //     (Route<dynamic> route) => false);
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => OtpPage(
                    phone: number,
                    otp: jsonResponse['otp'],
                    userID: jsonResponse['user_id'].toString())));
      }
    } else {
      jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = false;
      });
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
              ElevatedButton(
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

  Future<void> phoneAuth() async {
    String mobileNumber = await _autoFill.hint;
    if (mobileNumber != null) {
      print(" my mobile Number");
      print(mobileNumber.substring(mobileNumber.length - 10));
      send_phoneNumber(mobileNumber.substring(mobileNumber.length - 10));
    } else {
      print("Error");
    }
  }

  void googleAuth() {
    signInWithGoogle().then((result) {
      if (result != null) {
        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (BuildContext context) => BottomTab()),
        //     (Route<dynamic> route) => false);
      }
    });
  }

  void faceBookAuth() {
    signInWithFacebook();
    // signInWithFacebook().then((result) {
    //   if (result != null) {
    //     Navigator.of(context).pushAndRemoveUntil(
    //         MaterialPageRoute(builder: (BuildContext context) => BottomTab()),
    //         (Route<dynamic> route) => false);
    //   }
    // });
  }

  void emailAuth() {
    Navigator.push(
        context, CupertinoPageRoute(builder: (_) => EmailLoginPage()));
  }
}
