import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stop_app/informations.dart';

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
}

Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(String path, int width) async {
  final Uint8List imageData = await getBytesFromAsset(path, width);
  return BitmapDescriptor.fromBytes(imageData);
}

class GoogleMaps extends StatefulWidget {
  @override
  State<GoogleMaps> createState() => GoogleMapsState();

}

class GoogleMapsState extends State<GoogleMaps> {
  Set<Marker> _markers = {};
  BitmapDescriptor mapMarker;

  @override
  void initState(){
    super.initState();
    setCustomMarker();
  }

  void setCustomMarker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        "assets/images/kickboard_icon.png");
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId('1'),
            position: LatLng(36.3544591, 127.4189559),
            icon: mapMarker,
            infoWindow: InfoWindow(
              title: "한남대학교 공과대학",
              snippet: "CU"
          )
        )
      );
    });
  }

  static final CameraPosition initialLocation = CameraPosition(
      // bearing: 192.8334901395799,
      // tilt: 59.440717697143555,
      target: LatLng(36.3544591, 127.4189559),
      zoom: 16,
  );

  String qrcode_name = "QR SCAN";
  String qrcode_name1 = "운행 종료";
  String qrcode_name2 = "QR SCAN";
  int qrIndex = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        markers: _markers,
        onMapCreated: _onMapCreated
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