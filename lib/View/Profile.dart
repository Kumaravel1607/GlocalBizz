import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Model/profile_model.dart';
import 'package:glocal_bizz/View/Chatting/NewChatList.dart';
import 'package:glocal_bizz/View/CreateStore/MyOrders.dart';
import 'package:glocal_bizz/View/EditProfile.dart';
import 'package:glocal_bizz/View/Add%20Package/Packages.dart';
import 'package:glocal_bizz/View/MyAddress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:glocal_bizz/View/ChangePassword/ChangePassword.dart';

import '../Controller/constand.dart';
import '../View/Help/ContactUs.dart';
import '../View/Help/Help&Support.dart';
import 'Add Package/Buy&Transaction.dart';
import 'Add Package/CategoryPackage.dart';
import 'CreateStore/Create_store.dart';
import 'CreateStore/MyStoreDetail.dart';
import 'CreateStore/StoreBottomTab.dart';
import 'FavorateList.dart';
import 'Login.dart';
import 'MyPosts.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String image = "https://varmalaa.com/assets/default/avatar.png";
  String name;
  String lastname;
  SharedPreferences prefs;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  @override
  void initState() {
    super.initState();
    getUserDetail();
  }

  Future<void> checkLogoutStatus() async {
    _alerDialog("Confirm to Logout");
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
  }

  Future<Null> _logOutFB() async {
    await facebookSignIn.logOut();
  }

  Future<UserDetails> getUserDetail() async {
    prefs = await SharedPreferences.getInstance();
    // var jsonResponse = null;
    Map data = {
      'customer_id': prefs.getString("user_id"),
    };
    var response;
    response = await http.post(Uri.parse(api_url + "/customer"), body: data);
    if (response.statusCode == 200) {
      var userDetail = (json.decode(response.body));
      setState(() {
        name = (userDetail['first_name']);
        image = (userDetail['profile_image']);
      });
      return UserDetails.fromJson(userDetail);
    } else {
      throw Exception('Failed to load post');
    }
  }

  FutureOr onGoBack(dynamic value) {
    getUserDetail();
    setState(() {});
  }

  Future<void> _alerDialog(message) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message),
            //title: Text(),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () async {
                  Navigator.pop(context, "ok");
                },
                child: const Text(
                  "No",
                  style: TextStyle(color: color2),
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  prefs = await SharedPreferences.getInstance();
                  prefs.clear();
                  prefs.commit();
                  _signOut();
                  _logOutFB();

                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()),
                      (Route<dynamic> route) => false);
                },
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: color2),
                ),
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
          "My Account",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Color(0xFFf8f8f8),
                    child: InkWell(
                      child: CircleAvatar(
                        backgroundColor: Color(0xFFf8f8f8),
                        radius: 50,
                        backgroundImage: image != null
                            ? NetworkImage(image)
                            : AssetImage(
                                'assets/profile.jpg',
                              ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(new PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) {
                              return new Material(
                                  color: Colors.black54,
                                  child: new Container(
                                    padding: const EdgeInsets.all(30.0),
                                    child: new InkWell(
                                      child: new Hero(
                                        // tag: null,
                                        child: Center(
                                          child: Container(
                                            height: 350,
                                            width: 350,
                                            child: CircleAvatar(
                                              // radius: 75,
                                              backgroundImage: image != null
                                                  ? NetworkImage(image)
                                                  : AssetImage(
                                                      'assets/user.png'),
                                            ),
                                          ),
                                        ),
                                        tag: 'id',
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ));
                            }));
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    name != null ? name : "user",
                    style: TextStyle(
                        color: black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  InkWell(
                    onTap: () {
                      Route route = MaterialPageRoute(
                          builder: (context) => EditProfilePage());
                      Navigator.push(context, route).then(onGoBack);
                      // Navigator.of(context, rootNavigator: true).push(
                      //     CupertinoPageRoute(
                      //         builder: (_) => EditProfilePage()));
                    },
                    child: Text(
                      "View and edit profile",
                      style: TextStyle(color: primaryColor, fontSize: 12),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 1,
                    width: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    title: Text(
                      "Manage Store",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Manage Product",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Icon(
                      Icons.business,
                      color: color2,
                      size: 24,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () async {
                      prefs = await SharedPreferences.getInstance();
                      print("Nk King ");
                      print(prefs.getString("store_id"));
                      if (prefs.getString("store_id") != "") {
                        Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                                builder: (_) => StoreBottomTab()));
                      } else {
                        Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(builder: (_) => CreateStore()));
                      }
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "My Posts",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Sell and Service",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Image.asset(
                      "assets/post.png",
                      height: 25,
                      width: 25,
                      color: color2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () {
                      // Navigator.of(context, rootNavigator: true).push(
                      //   PageRouteBuilder(
                      //     pageBuilder: (c, a1, a2) => PostPage(),
                      //     transitionsBuilder: (c, anim, a2, child) =>
                      //         FadeTransition(opacity: anim, child: child),
                      //     transitionDuration: Duration(milliseconds: 500),
                      //   ),
                      // );
                      // MyPostPage
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (_) => MyPostPage()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "My Orders",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "See All Orders List",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Icon(
                      Icons.shopping_cart_outlined,
                      color: color2,
                      size: 24,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () async {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (_) => MyOrdersPage()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "My Address",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Add your current address",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Icon(
                      Icons.pin_drop_outlined,
                      color: color2,
                      size: 25,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () async {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (_) => MyAddressPage()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "Buy a package",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Add more packages",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Image.asset(
                      "assets/buy.png",
                      height: 30,
                      width: 30,
                      color: color2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(
                              builder: (_) => BuyAndTransaction()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "Message",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Your messages",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Image.asset(
                      "assets/message.png",
                      height: 25,
                      width: 25,
                      color: color2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (_) => ChatListPage()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "Favorites",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Your selected favorites",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Image.asset(
                      "assets/fav.png",
                      height: 25,
                      width: 25,
                      color: color2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (_) => FavoriteList()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "Help and Support",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Privacy policy, Safty tips",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Image.asset(
                      "assets/settings.png",
                      height: 25,
                      width: 25,
                      color: color2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (_) => HelpAndSupport()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "Contact Us",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Send your quries",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Image.asset(
                      "assets/contact.png",
                      height: 25,
                      width: 25,
                      color: color2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(builder: (_) => ContactUsPage()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "Change Password",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Set your new password",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Image.asset(
                      "assets/key.png",
                      height: 25,
                      width: 25,
                      color: color2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(
                              builder: (_) => ChangeNewPassword()));
                    },
                  ),
                  divider(),
                  ListTile(
                    title: Text(
                      "Logout",
                      style: TextStyle(
                          fontSize: 16,
                          color: color2,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Logout your account",
                      style: TextStyle(
                          fontSize: 12,
                          color: black,
                          fontWeight: FontWeight.w500),
                    ),
                    leading: Image.asset(
                      "assets/logout.png",
                      height: 25,
                      width: 25,
                      color: color2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: color2,
                      size: 20,
                    ),
                    onTap: () {
                      checkLogoutStatus();
                    },
                  ),
                  divider(),
                ]),
          ),
        ),
      ),
    );
  }
}
