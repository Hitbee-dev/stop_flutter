import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_ip/get_ip.dart';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:location/location.dart';
import 'package:stop_app/bottom_button.dart';
import 'package:stop_app/model/kickboard_data.dart';
import 'package:stop_app/Socket/Protocol.dart';
import 'package:stop_app/Socket/PacketCreator.dart';
import 'package:stop_app/user_account.dart';

class GoogleMaps extends StatefulWidget {
  @override
  State<GoogleMaps> createState() => GoogleMapsState();
}

class GoogleMapsState extends State<GoogleMaps> {
  @override
  void initState() {
    super.initState();
    setCustomMarker();
    setPolygons();
    setCircles();
    print("latitude :${RealLats} + longitude :${RealLngs}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      connectToServer();
    });
    getIP();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey scaffoldKey = GlobalKey();
  Completer _completerController = Completer();
  Set<Marker> markers = HashSet<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Circle> _circles = HashSet<Circle>();
  BitmapDescriptor mapMarker;
  static ScanResult scanResult;
  Location location = new Location();

  static Socket stopSocket;
  Uint8List bytes = Uint8List(0);
  String localIP = "";
  String serverIP = "203.247.41.152";
  int port = 50002;
  int serverCheck = 0;
  List<MessageItem> items = [];

  String qrcode_name = "QR SCAN";
  double RealLats = 36.356289;
  double RealLngs = 127.419470;
  int qrIndex = 0;
  int qrFlag = 1;
  int dlSize = 0;
  int krent = 0;
  int kreturn = 0;
  String rescount = "";
  static String Qrdatas = "";
  static String UserQr = "";
  static var QrList = "";

  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _cancelController = TextEditingController(text: 'Cancel');

  var markersIds = markerIds;
  var latitudes = lats;
  var longitudes = lngs;
  var _aspectTolerance = 0.00;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  @override
  Widget build(BuildContext context) {
    qrButton();
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: Scaffold(
        key: scaffoldKey,
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initialLocation,
          polygons: _polygons,
          circles: _circles,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onMapCreated: _onMapCreated,
          markers: markers,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _qrChange,
          backgroundColor: Colors.black,
          label: Text(qrcode_name),
          icon: Icon(Icons.qr_code_scanner),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  static final CameraPosition initialLocation = CameraPosition(
    // bearing: 192.8334901395799,
    // tilt: 59.440717697143555,
    ///?????? target??? ?????? ????????? ???????????? ????????? ????????? ?????? ????????? ?????????
    target: LatLng(36.353918, 127.422101),
    zoom: 15,
  );

  Widget _qrChange() {
    setState(() {
      if (UserAccountState.loginStatus == true) {
        if (qrIndex == 0) {
          _scan();
        } else if (qrIndex == 1) {
          if (qrFlag == 0) {
            returnMessage();
            normalProgress(context);
            qrIndex = 2;
          }
        }
      } else {
        showSnackBarWithKey("????????? ??? ??????????????????.");
      }
    });
  }

  void qrRent(int res) {
    qrIndex = 0;
    if (res == 2) {
      qrIndex = 1;
      qrFlag = 0;
      showSnackBarWithKey("?????? ??????! ????????? ?????? : ${Qrdatas}");
      qrcode_name = "????????????";
    } else if (res == 1) {
      showSnackBarWithKey("???????????? ?????? ????????? ?????????.");
    } else {
      showSnackBarWithKey("?????? ????????? ?????????.");
    }
  }

  void qrReturn(int res) {
    if (res == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarWithKey("?????? ??????! ????????? ?????? : ${Qrdatas}");
      });
      UserQr = "??????";
      qrcode_name = "QR SCAN";
      // QrList = "";
      qrFlag = 1;
      qrIndex = 0;
    } else if (res == 1) {
      showSnackBarWithKey("?????? ????????? ??????????????????.");
    } else {
      showSnackBarWithKey("?????? ??????????????????.");
    }
  }

  void qrButton() {
    var scanResults = scanResult;
    if (scanResult != null) {
      Qrdatas = scanResults.rawContent;
      UserQr = scanResults.rawContent;
      (stopSocket != null) ? submitMessage() : null;
      scanResult = null;
      qrIndex = 2;
      QrList = Qrdatas;
    }
  }

  void packetHandler(Map data) {
    int part = data["part"];
    if (part == PacketCreator.KICKBOARD_REQ) {
      qrRent(data["res"]);
      krent = data["res"];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshIndicatorKey.currentState.show(); // Google Map ?????? ????????????
      });
      print("packetH : ${krent}");
    }
    if (part == PacketCreator.KICKBOARD_RET) {
      qrReturn(data["res"]);
      kreturn = data["res"];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshIndicatorKey.currentState.show(); // Google Map ?????? ????????????
      });
      print("packetV : ${krent}");
    }
    if (part == PacketCreator.LOADING_DIALOG) {
      qrDialog(data["dialog"]);
      print("dialog : ${data["dialog"]}");
    }
    if (part == PacketCreator.KICKBOARD_DATA) {
      // qrDialog(data["dialog"]);
    }
  }

  void qrDialog(int dialog) {
    setState(() {
      dlSize = dialog;
    });
  }

  void normalProgress(context) async {
    ProgressDialog pd = ProgressDialog(context: context);
    int imageSize = 7000000;

    pd.show(
      max: imageSize,
      msg: '????????? ?????? ?????? ???...',
      progressBgColor: Colors.transparent,
    );
    for (int i = 0; i <= imageSize; i++) {
      pd.update(value: i);
      if (dlSize == 1) {
        i = imageSize;
        dlSize = 0;
        pd.update(value: i);
      } else if (dlSize == 2) {
        i = imageSize;
        pd.update(value: i);
        showSnackBarWithKey("????????? ??? ????????????.");
        dlSize = 0;
        qrIndex = 1;
      } else {
        i++;
      }
      await Future.delayed(Duration(microseconds: 30));
    }
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
          restrictFormat: _possibleFormats,
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

  showSnackBarWithKey(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: '??????',
        onPressed: () {},
      ),
    ));
  }

  void getIP() async {
    var ip = await GetIp.ipAddress;
    setState(() {
      localIP = ip;
    });
  }

  void setCustomMarker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/images/kickboard_icon.png");
  }

  void setPolygons() {
    List<LatLng> polygonbans = [];
    polygonbans.add(LatLng(38.878698, 129.793700));
    polygonbans.add(LatLng(38.723452, 124.503699));
    polygonbans.add(LatLng(32.727438, 124.636503));
    polygonbans.add(LatLng(34.241116, 129.948638));

    List<List<LatLng>> polygonholes = [];
    List<LatLng> polygonLatLngs = [];
    polygonLatLngs.add(LatLng(36.356551, 127.405571));
    polygonLatLngs.add(LatLng(36.357893, 127.410256));
    polygonLatLngs.add(LatLng(36.358909, 127.432150));
    polygonLatLngs.add(LatLng(36.351036, 127.441655));
    polygonLatLngs.add(LatLng(36.347480, 127.431925));
    polygonLatLngs.add(LatLng(36.343525, 127.427059));
    polygonLatLngs.add(LatLng(36.342545, 127.423320));
    polygonholes.add(polygonLatLngs);

    _polygons.add(Polygon(
      polygonId: PolygonId("ban"),
      points: polygonbans,
      holes: polygonholes,
      fillColor: Color(0x8F757575),
      strokeColor: Colors.yellow,
      strokeWidth: 3,
    ));
  }

  void setCircles() {
    _circles.add(Circle(
        circleId: CircleId("1"),
        center: LatLng(36.356315, 127.419878),
        radius: 20,
        fillColor: Color(0x5FB388FF),
        strokeColor: Colors.deepPurpleAccent,
        strokeWidth: 2));
  }

  void _onMapCreated(GoogleMapController googleMapController) {
    _completerController.complete(googleMapController);
    setState(() {
      for (int mcounter = 0; mcounter < markersIds.length; mcounter++) {
        markers.add(
          Marker(
              markerId: markersIds[mcounter],
              position: LatLng(latitudes[mcounter], longitudes[mcounter]),
              icon: mapMarker,
              infoWindow:
                  InfoWindow(title: titles[0], snippet: snippets[mcounter]),
              onTap: () {
                Scaffold.of(scaffoldKey.currentContext).showBottomSheet(
                    (context) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // ????????? ???????????? ??? ??????????????? ?????????
                    onTap: () {
                      FocusScope.of(context).unfocus(); // ????????? ???????????? ??? ??????????????? ?????????
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 80, top: 30),
                      child: getBottomSheet(
                        "${latitudes[mcounter]} , ${longitudes[mcounter]}",
                        "${kickboards[mcounter]}",
                        "${kickboardcodes[mcounter]}",
                        "${safetyphones[mcounter]}",
                      ),
                      height: 250,
                    ),
                  );
                }, backgroundColor: Colors.transparent);
              }),
        );
      }

      location.onLocationChanged.listen((LocationData currentLocation) {
        RealLats = currentLocation.latitude;
        RealLngs = currentLocation.longitude;
      });
    });
  }

  Widget getBottomSheet(
      String location, kickboardName, kickboardCode, safetyPhone) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${kickboardName}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text("98%",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12)),
                            Icon(
                              Icons.battery_charging_full_rounded,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text("${kickboardCode}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14))
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                    Image.asset(
                      "assets/images/kickboard_parking1.png",
                      width: 90,
                      height: 90,
                    )
                  ]),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.map,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("$location", style: TextStyle(color: Colors.white))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.call,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Row(children: [
                    TextButton(
                      child: Text("${safetyPhone}",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {},
                    ),
                    Text(
                      " |  ????????????",
                      style: TextStyle(color: Colors.white),
                    )
                  ])
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  void _storeServerIP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("serverIP", serverIP);
  }

  void connectToServer() async {
    print("Destination Address: ${serverIP}");
    _storeServerIP();

    Socket.connect(serverIP, port, timeout: Duration(seconds: 5))
        .then((socket) {
      setState(() {
        stopSocket = socket;
        serverCheck = 1;
      });

      showSnackBarWithKey(
          // "Server : ${socket.remoteAddress.address}:${socket.remotePort} ?????????????????????.");
          "Server : ????????? ?????????????????????.");
      socket.listen(
        (onData) {
          String packet = String.fromCharCodes(onData).trim();
          // print(packet);
          Map data = Protocol.Decoder(packet);
          print(data);
          packetHandler(data);
          setState(() {
            items.insert(
                0,
                MessageItem(stopSocket.remoteAddress.address,
                    String.fromCharCodes(onData).trim()));
          });
        },
        onDone: onDone,
        // onError: onError,
      );
    }).catchError((e) {
      showSnackBarWithKey(e.toString());
    });
  }

  void onDone() {
    serverCheck = 0;
    disconnectFromServer();
  }

  void onError(e) {
    print("onError: $e");
    showSnackBarWithKey(e.toString());
    disconnectFromServer();
  }

  void disconnectFromServer() {
    print("disconnectFromServer");
    showSnackBarWithKey("?????? ????????? ?????????????????????.");
    stopSocket.close();
    setState(() {
      stopSocket = null;
    });
  }

  void submitMessage() {
    stopSocket.write(PacketCreator.kickboardReq(Qrdatas));
  }

  void returnMessage() {
    stopSocket.write(PacketCreator.kickboardRet(Qrdatas));
  }

  void sendLoginMessage(String id, pw) {
    stopSocket.write(PacketCreator.userLogin(id, pw));
  }

  Future<Null> _onRefresh() async {
    print('refreshing...');
    addMarker();
    removeMarker();
  }

  void addMarker() {
    setState(() {
      if (krent == 3) {
        print("krent of server : ${krent}");
        print("before : ${markersIds}");
        int qrdata = kickboardcodes.indexOf(Qrdatas);
        markers.add(
          Marker(
              markerId: MarkerId("${qrdata}"),
              position: LatLng(RealLats, RealLngs),
              icon: mapMarker,
              infoWindow:
                  InfoWindow(title: titles[0], snippet: snippets[qrdata]),
              onTap: () {
                Scaffold.of(scaffoldKey.currentContext).showBottomSheet(
                    (context) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // ????????? ???????????? ??? ??????????????? ?????????
                    onTap: () {
                      FocusScope.of(context).unfocus(); // ????????? ???????????? ??? ??????????????? ?????????
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 80, top: 30),
                      child: getBottomSheet(
                        "${RealLats} , ${RealLngs}",
                        "${kickboards[qrdata]}",
                        "${Qrdatas}",
                        "${safetyphones[qrdata]}",
                      ),
                      height: 250,
                    ),
                  );
                }, backgroundColor: Colors.transparent);
              }),
        );
        krent = 0;
        markersIds.add(MarkerId("${qrdata}"));
        latitudes.add(RealLats);
        longitudes.add(RealLngs);
        print(latitudes);
        print(longitudes);
        print("after : ${markersIds}");
      }
    });
  }

  void removeMarker() {
    setState(() {
      if (krent == 2) {
        print("krent to server : ${krent}");
        print("before : ${markersIds}");
        int qrdata = kickboardcodes.indexOf(Qrdatas);
        markers.remove(
          Marker(
              markerId: markersIds[qrdata],
              position: LatLng(latitudes[qrdata], longitudes[qrdata]),
              icon: mapMarker,
              infoWindow:
                  InfoWindow(title: titles[0], snippet: snippets[qrdata]),
              onTap: () {
                Scaffold.of(scaffoldKey.currentContext).showBottomSheet(
                    (context) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // ????????? ???????????? ??? ??????????????? ?????????
                    onTap: () {
                      FocusScope.of(context).unfocus(); // ????????? ???????????? ??? ??????????????? ?????????
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 80, top: 30),
                      child: getBottomSheet(
                        "${latitudes[qrdata]} , ${longitudes[qrdata]}",
                        "${kickboards[qrdata]}",
                        "${kickboardcodes[qrdata]}",
                        "${safetyphones[qrdata]}",
                      ),
                      height: 250,
                    ),
                  );
                }, backgroundColor: Colors.transparent);
              }),
        );
        krent = 3;
        markersIds.remove(MarkerId("${qrdata}"));
        latitudes.remove(latitudes[qrdata]);
        longitudes.remove(longitudes[qrdata]);
        print(latitudes);
        print(longitudes);
        print("after : ${markersIds}");
      }
    });
  }
}

class MessageItem {
  String owner;
  String content;

  MessageItem(this.owner, this.content);
}

// setState(() {
//   Navigator.push(context,
//       MaterialPageRoute<void>(builder: (BuildContext context) {
//         return QrScaning();
//       }));
// });
