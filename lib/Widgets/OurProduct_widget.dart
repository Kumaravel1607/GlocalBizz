import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/Store_model.dart';
import 'package:glocal_bizz/View/CreateStore/ProductDetail.dart';
import 'package:glocal_bizz/View/DetailPage.dart';

class OurProductWidget extends StatelessWidget {
  final Products productList;
  OurProductWidget(this.productList);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          if (productList.id != null) {
            Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
                builder: (context) =>
                    ProductDetailPage(product_id: productList.id.toString())));
          } else {
            print("product id is not available");
          }
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
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    height: 130,
                    // width: 150,
                    decoration: BoxDecoration(
                      // color: appcolor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      // image: DecorationImage(
                      //     // image: NetworkImage(),
                      //     image: AssetImage("assets/audi.jpg"),
                      //     fit: BoxFit.fill),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: productList.product_image ?? "assets/image.png",
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            productList.product_name ?? "Empty Product",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(productList.product_price ?? "499",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700)),
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

class RelatedProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          print("product id is not available");
        },
        child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              width: 170,
              // color: appcolor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 130,
                    // width: 150,
                    decoration: BoxDecoration(
                      // color: appcolor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      // image: DecorationImage(
                      //     // image: NetworkImage(),
                      //     image: AssetImage("assets/audi.jpg"),
                      //     fit: BoxFit.fill),
                    ),
                    child: Image.asset("assets/image.png"),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Basmati Rice",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: "Poppins",
                                color: color2,
                                fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              Text(
                                "₹499",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: "Poppins",
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "₹599.00",
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 7,
                          )
                        ]),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
