import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/View/Add%20Package/CartPage.dart';

class FeaturePackages extends StatefulWidget {
  FeaturePackages({Key key}) : super(key: key);

  @override
  _FeaturePackagesState createState() => _FeaturePackagesState();
}

class _FeaturePackagesState extends State<FeaturePackages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Feature Package", style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: Container(
        // padding: EdgeInsets.all(15),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: listOfPackages(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: listOfPackages(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: listOfPackages(),
            ),
          ],
        ),
      ),
    );
  }

  Widget listOfPackages() {
    return InkWell(
      onTap: () {
        print("NK");
      },
      child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 100,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[350], width: 0.6),
              borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            Expanded(
              flex: 2,
              child: Text(
                "Rs.1000",
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600),
              ),
            ),
            VerticalDivider(
              color: Colors.grey[350],
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Featured Ad for 30 days",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: color2,
                        fontSize: 14,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Reach up to 10 times more buyers",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 9,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 7,
            ),
            Expanded(
              flex: 2,
              child: button(),
            ),
          ])),
    );
  }

  Widget button() {
    return ElevatedButton(
      onPressed: () {
        _showMessage();
      },
      child: Text(
        "Buy",
        style: TextStyle(
            fontSize: 16,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          elevation: 7,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          primary: primaryColor,
          // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    ); //Container
  }

  void _showMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(35.0),
                topRight: const Radius.circular(35.0)),
          ),
          context: context,
          builder: (builder) {
            return new Container(
              height: 230.0,
              decoration: new BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0))),
              child: new Container(
                  padding: EdgeInsets.all(15),
                  // decoration: new BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: new BorderRadius.only(
                  //         topLeft: const Radius.circular(25.0),
                  //         topRight: const Radius.circular(25.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Featured Ad for 30 days",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            // color: color2,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "Reach up to 10 times more buyers",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 10,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigator.of(context, rootNavigator: true)
                              //     .push(MaterialPageRoute(builder: (context) => CartPage()));
                            },
                            child: Text(
                              "Pay  ₹ 1000",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                primary: color2,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          )),
                    ],
                  )),
            );
          });
    });
  }
}
