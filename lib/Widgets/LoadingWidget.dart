import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
      ),
    );
  }
}
