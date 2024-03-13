import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final Function selcetedAuth;
  final String authName;
  final Icon authIcon;

  AuthButton(
    this.selcetedAuth,
    this.authName,
    this.authIcon,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: selcetedAuth,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 3),
            child: Row(
              children: [
                authIcon,
                Text(
                  authName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins"),
                ),
              ],
            ),
          ),
          // icon: authIcon,
          // label: Text(
          //   authName,
          //   style: TextStyle(color: Colors.black),
          // ),
          style: ElevatedButton.styleFrom(
              elevation: 7,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              primary: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ), //RaisedButton
    ); //Container
  }
}
