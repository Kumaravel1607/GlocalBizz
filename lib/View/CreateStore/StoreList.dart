import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Google%20ADs/AdMob_Helper.dart';
import 'package:glocal_bizz/Google%20ADs/ad_helper.dart';
import 'dart:convert';
import 'package:glocal_bizz/Model/Store_model.dart';
import 'package:glocal_bizz/View/CreateStore/Cart.dart';
import 'package:glocal_bizz/Widgets/gifLoader.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'StoreDetail.dart';

class StoreLists extends StatefulWidget {
  StoreLists({Key key}) : super(key: key);

  @override
  _StoreListsState createState() => _StoreListsState();
}

class _StoreListsState extends State<StoreLists> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  SharedPreferences prefs;

  static const _pageSize = 10;
  final PagingController<int, AllStoreList> _pagingController =
      PagingController(firstPageKey: 0);

  int page = 1;
  int cartCount;
  // BannerAd _bannerAd;

  // // COMPLETE: Add _isBannerAdReady
  // bool _isBannerAdReady = false;
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    // TODO: implement initState
    super.initState();
    // getStoreList();
    getCartCount();
    // _bannerAd = BannerAd(
    //   adUnitId: AdHelper.bannerAdUnitId,
    //   request: AdRequest(),
    //   size: AdSize(width: 400, height: 200),
    //   listener: BannerAdListener(
    //     onAdLoaded: (_) {
    //       setState(() {
    //         _isBannerAdReady = true;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, err) {
    //       print('Failed to load a banner ad: ${err.message}');
    //       _isBannerAdReady = false;
    //       ad.dispose();
    //     },
    //   ),
    // );

    // _bannerAd.load();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      prefs = await SharedPreferences.getInstance();
      print("-------------");
      prefs = await SharedPreferences.getInstance();
      Map data = {
        "page": (((pageKey + 10) / (_pageSize)).toString()),
        "limit": limit,
        "customer_id": prefs.getString("user_id"),
        "city_id": prefs.getString("city_Id") != null
            ? prefs.getString("city_Id")
            : "",
      };
      print(data);
      var result;
      var response =
          await http.post(Uri.parse(api_url + "/get_store"), body: data);
      result = json.decode(response.body);
      print(result);

      List<AllStoreList> list = AdsListResponse(jsonEncode(result));

      final newItems = list;
      print(newItems.length);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        print(newItems.length);
        _pagingController.appendPage(newItems, nextPageKey);
      }
      print(_pagingController);
    } catch (error) {
      _pagingController.error = error;
    }
  }

  static List<AllStoreList> AdsListResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<AllStoreList>((json) => AllStoreList.fromJson(json))
        .toList();
  }

  FutureOr onGoBack(dynamic value) {
    getCartCount();
    setState(() {});
  }

  getCartCount() async {
    prefs = await SharedPreferences.getInstance();
    Map data = {
      "customer_id": prefs.getString("user_id"),
    };
    print(data);
    var response =
        await http.post(Uri.parse(api_url + "/cart_count"), body: data);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print(result);
      print(result['cart_count']);
      setState(() {
        cartCount = result['cart_count'];
      });
    } else {
      print("error");
    }
  }

  // List<AllStoreList> storesList = List<AllStoreList>();

  // Future<List<AllStoreList>> get_store(storesListsJson) async {
  //   var storesList = List<AllStoreList>();
  //   for (var storesListsJson in storesListsJson) {
  //     storesList.add(AllStoreList.fromJson(storesListsJson));
  //   }
  //   return storesList;
  // }

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      page = 1;
    });
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: const Text('Refresh Completed...'),
      ),
    );
    _pagingController.refresh();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted)
      setState(() {
        page++;
        _pagingController.refresh();
      });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Store",
          style: TextStyle(color: white),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            child: cartCount != null
                ? Badge(
                    badgeContent: Text(
                      '$cartCount',
                      style: TextStyle(color: white),
                    ),
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.shopping_cart_sharp, color: white))
                : Icon(Icons.shopping_cart_sharp, color: white),
            onTap: () {
              // _checkVersion();
              Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (context) => CartPage()))
                  .then(onGoBack);
            },
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: Container(
        child: _isLoading == false
            ?
            // storesList.length == 0
            //     ? Center(child: Image.asset("assets/nodata.png"))
            //     :
            RefreshIndicator(
                onRefresh: () async {
                  _pagingController.refresh();
                },
                child: PagedGridView<int, AllStoreList>(
                  showNewPageProgressIndicatorAsGridChild: false,
                  showNewPageErrorIndicatorAsGridChild: false,
                  showNoMoreItemsIndicatorAsGridChild: false,
                  pagingController: _pagingController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 100 / 100,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                  ),
                  builderDelegate: PagedChildBuilderDelegate<AllStoreList>(
                    itemBuilder: (context, item, index) {
                      // if (index != 0 &&
                      //     index % 6 == 0 &&
                      //     _isBannerAdReady) {
                      //   return Align(
                      //     alignment: Alignment.topCenter,
                      //     child: Container(
                      //       width: _bannerAd.size.width.toDouble(),
                      //       height: _bannerAd.size.height.toDouble(),
                      //       child: AdWidget(ad: _bannerAd),
                      //     ),
                      //   );
                      // }

                      // if (index != 0 && index % 6 == 0) {
                      //   return Align(
                      //     alignment: Alignment.topCenter,
                      //     child: Container(
                      //       width: AdmobHelper.getBannerAd()
                      //           .size
                      //           .width
                      //           .toDouble(),
                      //       height: AdmobHelper.getBannerAd()
                      //           .size
                      //           .height
                      //           .toDouble(),
                      //       child: AdWidget(
                      //           ad: AdmobHelper.getBannerAd()..load()),
                      //     ),
                      //   );
                      // }
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        StoreDetails(store_id: item.id)));
                          },
                          child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                width: 190,
                                // color: appcolor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 100,
                                      // width: 150,
                                      decoration: BoxDecoration(
                                        // color: appcolor,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                        image: DecorationImage(
                                          image: item.store_logo != null
                                              ? NetworkImage(item.store_logo)
                                              : AssetImage("assets/car2.jpg"),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10, right: 10, top: 5),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              item.store_name,
                                              // maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: color2,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            new Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 20,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                      item.store_address,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                    },
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
              )),
      ),
      // ),
    );
  }
}
