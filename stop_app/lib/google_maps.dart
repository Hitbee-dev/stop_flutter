import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stop_app/informations.dart';

class GoogleMaps extends StatefulWidget {
  @override
  State<GoogleMaps> createState() => GoogleMapsState();

}

class GoogleMapsState extends State<GoogleMaps> {

  @override
  initState(){
    super.initState();

  }

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(36.3544591, 127.4189559),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      // bearing: 192.8334901395799,
      // tilt: 59.440717697143555,
      target: LatLng(36.3544591, 127.4189559),
      zoom: 19.151926040649414);

  String qrcode_name = "QR SCAN";
  String qrcode_name1 = "운행 종료";
  String qrcode_name2 = "QR SCAN";
  int qrIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _qrChange,
        backgroundColor: Colors.black,
        label: Text(qrcode_name),
        icon: Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _qrChange() {
    setState(() {
      if(qrIndex == 0) {
        qrcode_name = qrcode_name1;
        qrIndex++;
      } else {
        qrcode_name = qrcode_name2;
        qrIndex--;
      }
    });
  }
}