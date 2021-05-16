import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stop_app/informations.dart';
import 'package:stop_app/qr_scaning.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class GoogleMaps extends StatefulWidget {
  @override
  State<GoogleMaps> createState() => GoogleMapsState();

}

class GoogleMapsState extends State<GoogleMaps> {
  Set<Marker> _markers = {};
  BitmapDescriptor mapMarker;
  ScanResult scanResult;

  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _cancelController = TextEditingController(text: 'Cancel');

  var _aspectTolerance = 0.00;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];
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
      //공대 36.3562174,127.4173272
      _markers.add(
        Marker(
            markerId: MarkerId('1'),
            position: LatLng(36.3544591, 127.4189559),
            icon: mapMarker,
            infoWindow: InfoWindow(
              title: "한남대학교",
              snippet: "학생회관"
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
    final scanResult = this.scanResult;
    if(scanResult != null) {
      qrcode_name = scanResult.rawContent;
      qrIndex++;
    }
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
        _scan();
      } else {
        qrcode_name = qrcode_name2;
        qrIndex--;
      }
    });
  }

  Future<void> _scan() async {
    try {
      final result = await BarcodeScanner.scan(
        options: ScanOptions(
          strings: {
            'cancel': _cancelController.text,
            'flash_on': _flashOnController.text,
            'flash_off': _flashOffController.text,
          },
          restrictFormat: selectedFormats,
          useCamera: _selectedCamera,
          autoEnableFlash: _autoEnableFlash,
          android: AndroidOptions(
            aspectTolerance: _aspectTolerance,
            useAutoFocus: _useAutoFocus,
          ),
        ),
      );
      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      setState(() {
        scanResult = ScanResult(
          type: ResultType.Error,
          format: BarcodeFormat.unknown,
          rawContent: e.code == BarcodeScanner.cameraAccessDenied
              ? 'The user did not grant the camera permission!'
              : 'Unknown error: $e',
        );

      });
    }
  }
}

// setState(() {
//   Navigator.push(context,
//       MaterialPageRoute<void>(builder: (BuildContext context) {
//         return QrScaning();
//       }));
// });