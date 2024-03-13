import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/View/Post/BikePost.dart';

import 'JobPost.dart';
import 'PG&GustHousePost.dart';
import 'Lands&PlotPost.dart';

class ListOfPosts extends StatefulWidget {
  const ListOfPosts({Key key}) : super(key: key);

  @override
  _ListOfPostsState createState() => _ListOfPostsState();
}

class _ListOfPostsState extends State<ListOfPosts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            list("Job Post", job),
            list("PG and GustHouse", pg),
            list("Land", land),
          ],
        ),
      ),
    );
  }

  Widget list(String name, submit) {
    return ListTile(
      title: Text(name),
      onTap: submit,
    );
  }

  void job() {
    Navigator.of((context), rootNavigator: true)
        .push(CupertinoPageRoute(builder: (_) => JobPost()));
  }

  void pg() {
    Navigator.of((context), rootNavigator: true)
        .push(CupertinoPageRoute(builder: (_) => PGandGustHouse()));
  }

  void land() {
    Navigator.of((context), rootNavigator: true)
        .push(CupertinoPageRoute(builder: (_) => LandsAndPlot()));
  }
}
