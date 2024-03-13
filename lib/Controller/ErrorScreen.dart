import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  final String data;
  ErrorPage({Key key, this.data}) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(child: Text(widget.data)),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class ErrorPage extends StatefulWidget {
//   final String data;
//   ErrorPage({Key key, this.data}) : super(key: key);

//   @override
//   _ErrorPageState createState() => _ErrorPageState();
// }

// class _ErrorPageState extends State<ErrorPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Center(child: Text(widget.data)),
//       ),
//     );
//   }
// }
