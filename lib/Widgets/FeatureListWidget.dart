import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/View/DetailPage.dart';

class FeatureListWidget extends StatelessWidget {
  // final Function selcetedproduct;
  final VoidCallback selectedFav;
  final bool fav;
  final List<AdsList> feature_ads;
  final int index;

  FeatureListWidget(
    // this.selcetedproduct,
    this.fav,
    this.selectedFav,
    this.feature_ads,
    this.index,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              builder: (context) =>
                  AdsDetailPage(ads_id: feature_ads[index].id.toString())));
        },
        child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              width: 190,
              // color: appcolor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 130,
                        // width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          image: DecorationImage(
                            image: feature_ads[index].ads_image != null
                                ? NetworkImage(feature_ads[index].ads_image)
                                : AssetImage("assets/image.png"),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: selectedFav,
                            child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Icon(
                                    fav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 22,
                                    color: primaryColor,
                                  ),
                                )),
                          ),
                        ),
                      ),
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
                            feature_ads[index].ads_name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(feature_ads[index].ads_price,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700)),
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
                                child: Text(feature_ads[index].city_name,
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
