import 'dart:convert';

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Model/location_model.dart';
import 'dart:async';
import 'dart:ui';
import 'api.dart';
import 'constand.dart';

Future<List<Location>> get_locationData(city) async {
  try {
    Map data = {
      'city_name': city,
    };
    print(data);
    print('--------------NK------------');
    print(Uri.parse(api_url + "/city"));

    var response = await http.post(Uri.parse(api_url + "/city"), body: data);
    var locationDatas = List<Location>();
    print(json.decode(response.body));

    if (response.statusCode == 200) {
      var locationDatasJson = (json.decode(response.body));

      print(locationDatasJson);

      for (var locationDataJson in locationDatasJson) {
        locationDatas.add(Location.fromJson(locationDataJson));
      }
    }
    return locationDatas;
  } catch (e) {
    print("Error getting location.");
  }
}

Widget list(Location location) {
  return SingleChildScrollView(
    child: ListTile(
      title: Text(location.city_name),
      // subtitle: Text(location.id),
    ),
  );
}
