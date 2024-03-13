import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';

class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: const Color(0xFF0E3311).withOpacity(0.6),
      child: Center(
          child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
      )),
    );
  }
}
