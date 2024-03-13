import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/api.dart';
import 'package:glocal_bizz/Model/home_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Service {
  static Future<List<AdsList>> getMatchDetails(
      page, limit, cityId, extra) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    List<AdsList> list = [];
    Map data = {
      'page': page.toString(),
      'limit': limit,
      'category_id': "",
      'sub_category_id': "",
      'customer_id': _pref.getString("user_id"),
      'city_id': cityId != null ? cityId : "",
      'search_text': "",
    };
    if (extra != "") data.addAll(extra);

    print(data);
    var map = Map<String, dynamic>();

    var response = await http.post(Uri.parse(api_url + "/ads"), body: data);
    //  print(jsonDecode(response.body));
    if (jsonDecode(response.body) == "false") {
      list[0].id = 0;
      return list;
    } else {
      list = brideResponse(response.body);
      return list;
    }
  }

  static List<AdsList> brideResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<AdsList>((json) => AdsList.fromJson(json)).toList();
  }
}
