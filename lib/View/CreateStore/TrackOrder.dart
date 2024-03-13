import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Model/OrderTrack_model.dart';
import 'package:glocal_bizz/Widgets/LoadingWidget.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TrackOrderPage extends StatefulWidget {
  final String orderid;
  final String orderNO;
  TrackOrderPage({this.orderid, this.orderNO}) : super();

  final String title = "Track Order";

  @override
  TrackOrderPageState createState() => TrackOrderPageState();
}

class TrackOrderPageState extends State<TrackOrderPage> {
  SharedPreferences prefs;
  bool initialLoading = false;
  int delivery_status;

  @override
  void initState() {
    super.initState();
    track_order();
  }

  track_order() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      'order_id': widget.orderid,
      'customer_id': prefs.getString("user_id"),
    };
    print(data);
    var response = await http.post(Uri.parse(api_url + "/store_order_tracking"),
        body: data);
    print(response.body.toString());
    var jsonResponse;
    if (response.statusCode == 200) {
      setState(() {
        initialLoading = true;
      });
      jsonResponse = json.decode(response.body);
      print("-------------NK-----------");
      print(jsonResponse);

      get_tracklist(jsonResponse).then((value) {
        setState(() {
          trackList = value;
        });
      });
    } else {
      throw Exception('Failed to load post');
    }
  }

  List<OrderTrackModel> trackList = List<OrderTrackModel>();

  Future<List<OrderTrackModel>> get_tracklist(trackLisJson) async {
    var trackList = List<OrderTrackModel>();
    for (var trackListsJson in trackLisJson) {
      trackList.add(OrderTrackModel.fromJson(trackListsJson));
    }
    return trackList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Tracking'),
        backgroundColor: primaryColor,
      ),
      body: initialLoading
          ? Padding(
              padding: const EdgeInsets.only(top: 30, left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tracking Your Order",
                    style: TextStyle(
                        color: color2,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    "Order Id: " + widget.orderNO,
                    style: TextStyle(
                        color: color2,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                          itemCount: trackList.length,
                          itemBuilder: (context, index) {
                            Color orderColor;
                            switch (trackList[index].orderDeliveryStatus) {
                              case 1:
                                orderColor = primaryColor;
                                break;
                              case 2:
                                orderColor = primaryColor;
                                break;
                              case 3:
                                orderColor = primaryColor;
                                break;
                              case 4:
                                orderColor = primaryColor;
                                break;
                              case 0:
                                orderColor = Colors.grey[350];
                                break;
                              default:
                              // orderColor = Colors.grey;
                            }
                            Icon orderStatusIcon;
                            switch (trackList[index].orderStage) {
                              case 1:
                                orderStatusIcon = Icon(
                                  Icons.local_mall_outlined,
                                  color: Colors.grey[600],
                                );
                                break;
                              case 2:
                                orderStatusIcon = Icon(
                                  Icons.card_giftcard_outlined,
                                  color: Colors.grey[600],
                                );
                                break;
                              case 3:
                                orderStatusIcon = Icon(
                                  Icons.local_shipping_outlined,
                                  color: Colors.grey[600],
                                );
                                break;
                              case 4:
                                orderStatusIcon = Icon(
                                  Icons.done_outline_outlined,
                                  color: Colors.grey[600],
                                );
                                break;
                              default:
                              // orderColor = Colors.grey;
                            }
                            return Container(
                              height: 100,
                              child: TimelineTile(
                                isFirst: index == 0 ? true : false,
                                isLast: (index + 1) == trackList.length
                                    ? true
                                    : false,
                                afterLineStyle:
                                    LineStyle(color: orderColor, thickness: 3),
                                beforeLineStyle:
                                    LineStyle(color: orderColor, thickness: 3),
                                indicatorStyle:
                                    IndicatorStyle(color: orderColor),
                                endChild: Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Row(
                                    children: [
                                      orderStatusIcon,
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(trackList[index]
                                              .orderDeliveryStatusText),
                                          Text(trackList[index]
                                                  .updatedAt
                                                  .substring(0, 10) ??
                                              "--"),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                  Text(
                    "Your order has been deliverd.",
                    style: TextStyle(
                        color: color2,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                  SizedBox(height: 70),
                ],
              ))
          : Loading(),
    );
  }
}
