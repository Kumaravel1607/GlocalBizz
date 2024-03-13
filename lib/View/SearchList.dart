import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Controller/fav_controller.dart';
import 'package:glocal_bizz/Google%20ADs/AdMob_Helper.dart';
import 'package:glocal_bizz/Google%20ADs/ad_helper.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:glocal_bizz/Widgets/GridWidget.dart';
import 'package:glocal_bizz/Widgets/SearchListWidget.dart';
import 'package:glocal_bizz/Widgets/gifLoader.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProductType {
  const ProductType(this.name, this.productValue);
  final String name;
  final String productValue;
}

class PriceType {
  const PriceType(this.price, this.priceValue);
  final String price;
  final String priceValue;
}

class SearchListPage extends StatefulWidget {
  final String cat_id;
  final String subcat_id;
  SearchListPage({Key key, this.cat_id, this.subcat_id}) : super(key: key);

  @override
  _SearchListPageState createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchData = new TextEditingController();
  final TextEditingController _location = new TextEditingController();
  PersistentBottomSheetController _controller;

  final TextEditingController minRate = new TextEditingController();
  final TextEditingController maxRate = new TextEditingController();

  // bool_isLoading= false;
  //bool _delayLoading= false;
  bool _changeScreen = true;
  SharedPreferences prefs;

  int indexSelected = -1;
  String sortName = "";

  String cityID;
  static const _pageSize = 10;
  final PagingController<int, AdsList> _pagingController =
      PagingController(firstPageKey: 0);

  // BannerAd _bannerAd;

  // // COMPLETE: Add _isBannerAdReady
  // bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    // _fetchPage(10, "", "", "", "", "");
    // ads_list("", "", "", "", "");
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      prefs = await SharedPreferences.getInstance();
      print("-------------");
      Map data = {
        'page': (((pageKey + 10) / (_pageSize)).toString()),
        'limit': _pageSize.toString(),
        'category_id': widget.cat_id != null ? widget.cat_id : "",
        'sub_category_id': widget.subcat_id != null ? widget.subcat_id : "",
        'customer_id': prefs.getString("user_id"),
        'city_id': cityID != null ? cityID : "",
        // prefs.getString("city_Id") != null ? prefs.getString("city_Id") : "",
        'search_text': _searchData.text,
        'price_range': ((minRate.text) + ("-" + maxRate.text)) != "-"
            ? ((minRate.text) + ("-" + maxRate.text))
            : "",
        'service_type': "${_productfilters.join(', ')}" != null
            ? "${_productfilters.join(', ')}"
            : "",
        'price_type': '${_pricefilters.join(', ')}' != null
            ? '${_pricefilters.join(', ')}'
            : "",
        'sort_by': sortName != null ? sortName : "",
      };
      print(data);
      var result;
      var response = await http.post(Uri.parse(api_url + "/ads"), body: data);
      result = json.decode(response.body);
      print(result);

      List<AdsList> list = AdsListResponse(jsonEncode(result));

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

  static List<AdsList> AdsListResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<AdsList>((json) => AdsList.fromJson(json)).toList();
  }

  int page = 1;

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      page = 1;
    });
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: const Text('Refresh Completed...'),
      ),
    );

    // ads_list("", "", "", "", "");
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted)
      setState(() {
        page++;
        // ads_list("", "", "", "", "");
      });
  }

  void isLoad() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //   // _delayLoading= true;
      });
    });
  }

  final List<ProductType> _cast = <ProductType>[
    const ProductType('NEW', '1'),
    const ProductType('Old', '2'),
    const ProductType('Services', '3'),
  ];
  List<String> _productfilters = <String>[];

  Iterable<Widget> get productWidgets sync* {
    for (final ProductType product in _cast) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
          // avatar: CircleAvatar(child: Text(actor.productValue)),
          label: Text(product.name),
          selected: _productfilters.contains(product.productValue),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _productfilters.add(product.productValue);
              } else {
                _productfilters.removeWhere((String productValue) {
                  return productValue == product.productValue;
                });
              }
            });
          },
        ),
      );
    }
  }

  final List<PriceType> _pricecast = <PriceType>[
    const PriceType('Negotiable', '1'),
    const PriceType('Fixed', '2'),
  ];
  List<String> _pricefilters = <String>[];

  Iterable<Widget> get priceWidgets sync* {
    for (final PriceType price in _pricecast) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
          // avatar: CircleAvatar(child: Text(actor.productValue)),
          label: Text(price.price),
          selected: _pricefilters.contains(price.priceValue),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _pricefilters.add(price.priceValue);
              } else {
                _pricefilters.removeWhere((String priceValue) {
                  return priceValue == price.priceValue;
                });
              }
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return _changeScreen
        ? Scaffold(
            key: _scaffoldKey,
            backgroundColor: Color(0xFFffffff),
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: primaryColor,
              automaticallyImplyLeading: false,
              title: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: white,
                ),
                // width: 355,
                child: CupertinoTextField(
                  enableSuggestions: true,
                  onSubmitted: (value) {
                    setState(() {
                      // _isLoading= false;
                      // _delayLoading= true;
                    });
                    _pagingController.refresh();
                    // _pagingController.addPageRequestListener((pageKey) {
                    //   _fetchPage(pageKey, _searchData.text, "", "", "", "");
                    // });
                    // ads_list(_searchData.text, "", "", "", "");
                    print(_searchData.text);
                  },
                  cursorColor: color2,
                  // autofocus: true,
                  keyboardType: TextInputType.text,
                  controller: _searchData,
                  placeholder: 'Search',
                  placeholderStyle: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.grey,
                  ),
                  prefix: Padding(
                    padding: const EdgeInsets.fromLTRB(9.0, 7.0, 9.0, 8.0),
                    child: InkWell(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                          size: 23,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        }),
                  ),
                  suffix: Padding(
                    padding: const EdgeInsets.fromLTRB(9.0, 7.0, 9.0, 8.0),
                    child: InkWell(
                        child: Icon(
                          Icons.search_sharp,
                          color: Colors.grey,
                          size: 23,
                        ),
                        onTap: () {
                          setState(() {
                            // _isLoading= false;
                            // _delayLoading= true;
                            // _searchData.text = value;
                          });
                          _pagingController.refresh();
                          // ads_list(_searchData.text, "", "", "", "");
                          print(_searchData.text);
                        }),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Color(0xffffffff),
                  ),
                ),
              ),
              actions: [
                IconButton(
                    icon: Icon(Icons.tune, color: white),
                    onPressed: () {
                      // _filter();
                      setState(() {
                        _changeScreen = false;
                      });
                    }),
              ],
            ),
            body:
                //  list.length != 0
                //     ?
                PagedGridView<int, AdsList>(
                    physics: BouncingScrollPhysics(),
                    showNewPageProgressIndicatorAsGridChild: false,
                    showNewPageErrorIndicatorAsGridChild: false,
                    showNoMoreItemsIndicatorAsGridChild: false,
                    pagingController: _pagingController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 100 / 100,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                    ),
                    builderDelegate: PagedChildBuilderDelegate<AdsList>(
                      itemBuilder: (context, item, index) {
                        List<String> savedFav = List<String>();
                        String favID = item.id.toString();
                        savedFav.remove(favID);
                        if (item.favorite_status == "1") {
                          savedFav.add(favID);
                        }
                        bool issaved = savedFav.contains(favID);

                        void selectFav() {
                          setState(() {
                            print(savedFav.contains(favID));
                            if (issaved) {
                              item.favorite_status = "0";
                              savedFav.remove(favID);

                              deleteFav(item.id.toString());
                            } else {
                              item.favorite_status = "1";
                              savedFav.add(favID);
                              saveFav(item.id.toString());
                            }
                          });
                        }

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

                        return GridWidget(issaved, selectFav, item, index);
                      },
                    )))
        // : Container(
        //     height: MediaQuery.of(context).size.height * 0.6,
        //     alignment: Alignment.bottomCenter,
        //     child: Center(child: Image.asset("assets/nodata.png"))))
        : Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Filter and sort",
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Choose the price range",
                          style: TextStyle(
                              color: color2,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: TextFormField(
                                cursorHeight: 18,
                                onSaved: (String value) {},
                                controller: minRate,
                                obscureText: false,
                                onTap: () {},
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: black,
                                ),
                                keyboardType: TextInputType.text,
                                decoration: textDecoration1(
                                  'min',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text("to"),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: TextFormField(
                                cursorHeight: 18,
                                onSaved: (String value) {},
                                controller: maxRate,
                                obscureText: false,
                                onTap: () {},
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: black,
                                ),
                                keyboardType: TextInputType.text,
                                decoration: textDecoration1(
                                  'max',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Choose the product type",
                          style: TextStyle(
                              color: color2,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Wrap(
                          children: productWidgets.toList(),
                        ),
                        Text('Look for: ${_productfilters.join(', ')}'),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Choose the price type",
                          style: TextStyle(
                              color: color2,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Wrap(
                          children: priceWidgets.toList(),
                        ),
                        Text('Look for: ${_pricefilters.join(', ')}'),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Change sort",
                          style: TextStyle(
                              color: color2,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Wrap(
                          children: [
                            ChoiceChip(
                              label: Text("Date Published"),
                              selected: indexSelected == 1,
                              onSelected: (value) {
                                setState(() {
                                  indexSelected = value ? 1 : -1;
                                  sortName = "date_publish";
                                  print(sortName);
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text("Relevance"),
                              selected: indexSelected == 2,
                              onSelected: (value) {
                                setState(() {
                                  indexSelected = value ? 2 : -1;
                                  sortName = "relevance";
                                  print(sortName);
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text("Price Low to High"),
                              selected: indexSelected == 3,
                              onSelected: (value) {
                                setState(() {
                                  indexSelected = value ? 3 : -1;
                                  sortName = "price_low";
                                  print(sortName);
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text("Price High to Low"),
                              selected: indexSelected == 4,
                              onSelected: (value) {
                                setState(() {
                                  indexSelected = value ? 4 : -1;
                                  sortName = "price_high";
                                  print(sortName);
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: button(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void _closeModal(void value) {
    print('modal closed');
    // Navigator.pop(context);
  }

  void selectBtn() {
    // Navigator.push(context, MaterialPageRoute(builder: (_) => OtpPage()));
  }

  Widget button() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              print(((minRate.text) + "-" + (maxRate.text)));
              setState(() {
                _changeScreen = true;
              });
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(color: color2),
            ),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _changeScreen = true;
                // _isLoading= false;
              });
              _pagingController.refresh();
            },
            style: ButtonStyle(
              // backgroundColor: #,
              backgroundColor: MaterialStateProperty.all(color2),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
            ),
            child: const Text(
              "Apply",
              style: TextStyle(color: white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _list() {
    return SingleChildScrollView(
      child: ListTile(
        title: Text("Palacode"),
        // subtitle: Text(location.id),
      ),
    );
  }

  void _showLocation() {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
            height: MediaQuery.of(context).size.height,
            color: white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Search Your Location",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: appcolor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 45,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200],
                      blurRadius: 5.0,
                      spreadRadius: 3.0,
                    ),
                  ]),
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        controller: _location,
                        decoration: textDecoration2("Search Location")),
                    suggestionsCallback: (pattern) async {},
                    itemBuilder: (context, item) {
                      return _list();
                    },
                    onSuggestionSelected: (item) async {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }
}

// class TimeValue {
//   final int _key;
//   final String _value;
//   TimeValue(this._key, this._value);
// }

// void _filter() {
//     Future<void> future = showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         int selectedRadio;
//         String commendType;

//         final _buttonOptions = [
//           TimeValue(0, "Date Published"),
//           TimeValue(1, "Relevance"),
//           TimeValue(2, "Distance"),
//           TimeValue(3, "Price: Low to High"),
//           TimeValue(4, "Price: High to Low"),
//         ];
//         return StatefulBuilder(builder: (BuildContext context,
//             StateSetter setState /*You can rename this!*/) {
//           return Container(
//             // padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
//             alignment: Alignment.topCenter,
//             height: MediaQuery.of(context).size.height * 0.75,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(15), topRight: Radius.circular(15)),
//             ),
//             child: Stack(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Center(
//                       child:
//                           Container(height: 2, width: 50, color: Colors.grey),
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Text(
//                             "FILTERS & SORT",
//                             style: TextStyle(
//                                 fontSize: 24.0, fontWeight: FontWeight.w600),
//                           ),
//                           Spacer(),
//                           Text(
//                             'Select Category',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16.0,
//                               decoration: TextDecoration.underline,
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: 5,
//                     ),
//                     Divider(),
//                     Row(
//                       children: [
//                         Expanded(
//                             flex: 3,
//                             child: Container(
//                               height: MediaQuery.of(context).size.height * 0.55,
//                               color: Colors.grey[300],
//                               child: Column(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         selected = 'first';
//                                       });
//                                     },
//                                     child: Container(
//                                       width: MediaQuery.of(context).size.width,
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                           color: selected == 'first'
//                                               ? Colors.white
//                                               : Colors.grey[400],
//                                           border: Border.all(
//                                               color: Colors.grey[400])),
//                                       child: Center(
//                                         child: Text(
//                                           "By Budget",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         selected = 'Second';
//                                       });
//                                     },
//                                     child: Container(
//                                       width: MediaQuery.of(context).size.width,
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                           color: selected == 'Second'
//                                               ? Colors.white
//                                               : Colors.grey[400],
//                                           border: Border.all(
//                                               color: Colors.grey[400])),
//                                       child: Center(
//                                         child: Text(
//                                           "Change Sort",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )),
//                         Expanded(
//                             flex: 6,
//                             child: Container(
//                               // alignment: Alignment.topLeft,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text("Choose a range below"),
//                                   ),
//                                   selected == 'first'
//                                       ? Row(
//                                           // mainAxisAlignment: MainAxisAlignment.start,
//                                           // crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             SizedBox(
//                                               width: 7,
//                                             ),
//                                             Expanded(
//                                               child: TextFormField(
//                                                 cursorHeight: 18,
//                                                 onSaved: (String value) {},
//                                                 controller: minRate,
//                                                 obscureText: false,
//                                                 onTap: () {},
//                                                 style: TextStyle(
//                                                   fontSize: 14.0,
//                                                   color: black,
//                                                 ),
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 decoration: textDecoration1(
//                                                   'min',
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 5,
//                                             ),
//                                             Text("to"),
//                                             SizedBox(
//                                               width: 5,
//                                             ),
//                                             Expanded(
//                                               child: TextFormField(
//                                                 cursorHeight: 18,
//                                                 onSaved: (String value) {},
//                                                 controller: maxRate,
//                                                 obscureText: false,
//                                                 onTap: () {},
//                                                 style: TextStyle(
//                                                   fontSize: 14.0,
//                                                   color: black,
//                                                 ),
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 decoration: textDecoration1(
//                                                   'max',
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 7,
//                                             ),
//                                           ],
//                                         )
//                                       : Container(
//                                           child: StatefulBuilder(builder:
//                                               (BuildContext context,
//                                                   StateSetter setState) {
//                                             return Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: _buttonOptions
//                                                   .map((timeValue) =>
//                                                       RadioListTile(
//                                                         groupValue:
//                                                             selectedRadio,
//                                                         title: Text(
//                                                             timeValue._value),
//                                                         value: timeValue._key,
//                                                         // value: timeValue._key,
//                                                         onChanged: (val) {
//                                                           setState(() {
//                                                             debugPrint(
//                                                                 'VAL = $val');
//                                                             selectedRadio = val;
//                                                             commendType =
//                                                                 timeValue
//                                                                     ._value;
//                                                             debugPrint(timeValue
//                                                                 ._value);
//                                                           });
//                                                         },
//                                                       ))
//                                                   .toList(),
//                                             );
//                                           }),
//                                         ),
//                                 ],
//                               ),
//                             ))
//                       ],
//                     )
//                   ],
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: button(),
//                 )
//               ],
//             ),
//           );
//         });
//       },
//     );
//     future.then((void value) => _closeModal(value));
//   }
