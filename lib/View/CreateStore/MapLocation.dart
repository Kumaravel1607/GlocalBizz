import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetShopLocation extends StatefulWidget {
  final double lat;
  final double long;
  GetShopLocation({this.lat, this.long}) : super();

  @override
  GetShopLocationState createState() => GetShopLocationState();
}

class GetShopLocationState extends State<GetShopLocation> {
  Position position;
  SharedPreferences prefs;

  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(28.644800, 77.216721);
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;

  String username;
  String userImg;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  Future getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != PermissionStatus.granted) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != PermissionStatus.granted) getLocation();
      return;
    }
    getLocation();
  }

  void getLocation() async {
    Position res = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      position = res;
    });
    print("------------------Nandhu---------------");
    print(position.latitude);
    print(position.longitude);
    _onAddMarkerButtonPressed();
    getAddress();
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed() async {
    final CameraPosition _position1 = CameraPosition(
      bearing: 192.833,
      target: LatLng(position.latitude, position.longitude),
      tilt: 59.440,
      zoom: 11.0,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("My Location"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
            title: 'My current location',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      mini: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Color(0xFF188D3D),
      child: Icon(
        icon,
      ),
    );
  }

  // String featureName;
  String addressLine;
  // String pincode;
  // String areaname;

  void getAddress() async {
    prefs = await SharedPreferences.getInstance();
    final coordinates = new Coordinates(
        double.parse(position.latitude.toString()),
        double.parse(position.longitude.toString()));
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    setState(() {
      // featureName = first.featureName.toString();
      addressLine = first.addressLine.toString();
      // pincode = first.postalCode.toString();
      // areaname = first.locality.toString();
    });
    await prefs.setString('userAddress', addressLine);
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Store Location"),
          backgroundColor: primaryColor,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.lat, widget.long),
                zoom: 11.0,
              ),
              mapType: _currentMapType,
              markers: _markers,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    button(_onMapTypeButtonPressed, Icons.map),
                    SizedBox(
                      height: 16.0,
                    ),
                    button(_onAddMarkerButtonPressed, Icons.location_pin),
                    SizedBox(
                      height: 16.0,
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: Container(
            //         width: MediaQuery.of(context).size.width * 0.35,
            //         child: ElevatedButton(
            //           onPressed: submitButton,
            //           child: Text(
            //             "Next Page",
            //             style: TextStyle(fontSize: 16, color: Colors.white),
            //           ),
            //           style: ElevatedButton.styleFrom(
            //               elevation: 7,
            //               shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(25)),
            //               primary: primaryColor,
            //               padding: EdgeInsets.all(10),
            //               textStyle: TextStyle(
            //                   fontSize: 16, fontWeight: FontWeight.w500)),
            //         )),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
