import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/DetailPage.dart';

class GridWidget extends StatelessWidget {
  // final Function selcetedproduct;
  final VoidCallback selectedFav;
  final bool fav;
  AdsList ads;
  final int index;

  GridWidget(
    // this.selcetedproduct,
    this.fav,
    this.selectedFav,
    this.ads,
    this.index,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              builder: (context) => AdsDetailPage(ads_id: ads.id.toString())));
        },
        child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              width: 180,
              // color: appcolor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          // color: Color(0xFFf9f9f9),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                        ),
                        child: Center(
                          child: ads.ads_image != null
                              ? CachedNetworkImage(
                                  imageUrl: ads.ads_image,
                                )
                              : Image.asset("assets/image.png"),
                        ),
                      ),
                      ads.feature_status == 1
                          ? Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 2),
                                child: Text(
                                  "FEATURED",
                                  style: TextStyle(fontSize: 9.5),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    alignment: Alignment.center,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            ads.ads_name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: new Row(
                              children: [
                                Text(ads.ads_price,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700)),
                                Spacer(),
                                GestureDetector(
                                  onTap: selectedFav,
                                  child: Icon(
                                    fav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 22,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          new Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 20,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Flexible(
                                child: Text(ads.city_name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                    )),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
