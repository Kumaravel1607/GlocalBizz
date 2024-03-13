import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

Future<void> saveFav(adID) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Map data = {
    'customer_id': sharedPreferences.getString("user_id"),
    'ads_id': adID,
  };
  print(data);
  var jsonResponse;
  var response =
      await http.post(Uri.parse(api_url + "/save_favorite"), body: data);
  if (response.statusCode == 200) {
    jsonResponse = json.decode(response.body);
    print(jsonResponse);
  } else {
    print("error");
    print(json.decode(response.body));
  }
}

Future<void> deleteFav(adID) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Map data = {
    'customer_id': sharedPreferences.getString("user_id"),
    'ads_id': adID,
  };
  print(data);
  var jsonResponse;
  var response =
      await http.post(Uri.parse(api_url + "/delete_favorite"), body: data);
  if (response.statusCode == 200) {
    jsonResponse = json.decode(response.body);
    print(jsonResponse);
  } else {
    print("error");
    print(json.decode(response.body));
  }
}
