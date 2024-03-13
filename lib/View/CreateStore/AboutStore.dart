import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';

class AboutStore extends StatelessWidget {
  final String title;
  final String address;
  final String workTimeFrom;
  final String workTimeTo;
  final String mobileNO;
  const AboutStore(
      {Key key,
      this.title,
      this.address,
      this.workTimeFrom,
      this.workTimeTo,
      this.mobileNO})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "More Info",
              style: TextStyle(),
            ),
            Text(
              title ?? "--",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Other Info",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.location_on_outlined,
                        // size: 23,
                        color: Colors.green[800],
                      ),
                      title: Text(
                        address ?? "--",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.timeline,
                        color: Colors.green[800],
                        size: 22,
                      ),
                      title: Text(
                        "OPEN : " + workTimeFrom + " to " + workTimeTo,
                        style: TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        "Hours may differ",
                        style: TextStyle(
                            fontSize: 10, color: Colors.blue.shade900),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.call_outlined,
                        color: Colors.green[800],
                      ),
                      title: Text(
                        mobileNO ?? "--",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
