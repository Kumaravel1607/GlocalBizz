import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/DetailPage.dart';

class SearchListWidget extends StatelessWidget {
  final List<AdsList> ads;
  final int index;
  SearchListWidget(this.ads, this.index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              builder: (context) =>
                  AdsDetailPage(ads_id: ads[index].id.toString())));
        },
        child: Card(
          borderOnForeground: true,
          child: Container(
            height: 150,
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          // color: appcolor,
                          image: DecorationImage(
                        image: NetworkImage(ads[index].ads_image),
                      )),
                    )),
                Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(ads[index].ads_price,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700)),
                          Flexible(
                            child: Text(
                              ads[index].ads_name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 14),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          // Text(
                          //   "ads[index].posted_at",
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: TextStyle(
                          //       fontWeight: FontWeight.normal, fontSize: 13),
                          // ),
                          // Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.green,
                              ),
                              Flexible(
                                child: Text(ads[index].city_name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                    )),
                              ),
                              Spacer(),
                              // Text("oooo",
                              //     // (ads[index].created_at)
                              //     //     .characters
                              //     //     .take(8)
                              //     //     .toString(),
                              //     style: TextStyle(
                              //       fontSize: 10,
                              //     )),
                            ],
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
