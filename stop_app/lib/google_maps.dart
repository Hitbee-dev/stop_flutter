import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_ip/get_ip.dart';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:location/location.dart';
import 'package:stop_app/model/kickboard_data.dart';
import 'package:stop_app/Socket/Protocol.dart';
import 'package:stop_app/Socket/PacketCreator.dart';

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

  final GlobalKey scaffoldKey = GlobalKey();
  Completer _completerController = Completer();
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Circle> _circles = HashSet<Circle>();
  BitmapDescriptor mapMarker;
  ScanResult scanResult;
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
  String Qrdatas = "";

  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _cancelController = TextEditingController(text: 'Cancel');

  var _aspectTolerance = 0.00;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  @override
  Widget build(BuildContext context) {
    qrButton();
    return Scaffold(
      key: scaffoldKey,
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        markers: _markers,
        polygons: _polygons,
        circles: _circles,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
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
      if (qrIndex == 0) {
        _scan();
        qrIndex++;
      } else {
        qrFlag--;
      }
    });
  }

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  static final CameraPosition initialLocation = CameraPosition(
    // bearing: 192.8334901395799,
    // tilt: 59.440717697143555,
    ///아래 target은 초기 위치를 지정하는 것이기 때문에 변수 적용이 불가능
    target: LatLng(36.353918, 127.422101),
    zoom: 15,
  );

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
        label: '확인',
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
      for (int mcounter = 0; mcounter < markerIds.length; mcounter++) {
        _markers.add(
          Marker(
              markerId: markerIds[mcounter],
              position: LatLng(lats[mcounter], lngs[mcounter]),
              icon: mapMarker,
              infoWindow:
                  InfoWindow(title: titles[0], snippet: snippets[mcounter]),
              onTap: () {
                Scaffold.of(scaffoldKey.currentContext).showBottomSheet(
                    (context) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // 키보드 올라왔을 때 화면터치로 내리기
                    onTap: () {
                      FocusScope.of(context).unfocus(); // 키보드 올라왔을 때 화면터치로 내리기
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 80, top: 30),
                      child: getBottomSheet(
                        "${lats[mcounter]} , ${lngs[mcounter]}",
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
                      " |  안심번호",
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

  void qrButton() {
    var scanResults = this.scanResult;
    if (scanResults != null) {
      Qrdatas = scanResults.rawContent;
      print(Qrdatas);
      (stopSocket != null) ? submitMessage() : null;
      this.scanResult = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarWithKey("대여 성공! 킥보드 넘버 : ${Qrdatas}");
      });
      qrcode_name = "반납하기";
    }
    if (qrFlag == 0) {
      qrcode_name = "QR SCAN";
      qrFlag++;
      qrIndex--;
    }
  }

  void submitMessage() {
    setState(() {
      items.insert(0, MessageItem(localIP, Qrdatas));
    });
    // sendMessage(Qrdatas);
    stopSocket.write(PacketCreator.sendKickboardCode(Qrdatas));
  }

  void sendLoginMessage(String id, pw) {
    stopSocket.write(PacketCreator.userLogin(id, pw));
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
          // "Server : ${socket.remoteAddress.address}:${socket.remotePort} 연결되었습니다.");
          "Server : 서버에 연결되었습니다.");
      socket.listen(
        (onData) {
          String packet = String.fromCharCodes(onData).trim();
          print(packet);
          Map data = Protocol.Decoder(packet);
          print(data);
          setState(() {
            items.insert(
                0,
                MessageItem(stopSocket.remoteAddress.address,
                    String.fromCharCodes(onData).trim()));
            Qrdatas = String.fromCharCodes(onData).trim();
            print(items[0]);
          });
        },
        // onDone: onDone,
        // onError: onError,
      );
    }).catchError((e) {
      showSnackBarWithKey(e.toString());
    });
  }

  void onDone() {
    showSnackBarWithKey("서버 연결이 종료되었습니다.");
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
    showSnackBarWithKey("서버 연결이 종료되었습니다.");
    stopSocket.close();
    setState(() {
      stopSocket = null;
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
