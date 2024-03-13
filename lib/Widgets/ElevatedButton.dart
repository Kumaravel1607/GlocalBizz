import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';

class ElevatedBtn extends StatelessWidget {
  final Function selcetedBtn;
  final String btnName;
  final Icon btnIcon;

  ElevatedBtn(
    this.selcetedBtn,
    this.btnName,
    this.btnIcon,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      child: ElevatedButton.icon(
        onPressed: selcetedBtn,
        icon: btnIcon,
        label: Text(
          btnName,
          style: TextStyle(),
        ),
        style: ElevatedButton.styleFrom(
            elevation: 7,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            primary: primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    ); //Container
  }
}
