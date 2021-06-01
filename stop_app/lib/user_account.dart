import 'package:flutter/material.dart';
import 'package:stop_app/Socket/PacketCreator.dart';
import 'package:stop_app/google_maps.dart' as google_maps;
import 'model/kickboard_data.dart';

class UserAccount extends StatefulWidget {
  @override
  UserAccountState createState() => UserAccountState();
}

class UserAccountState extends State<UserAccount> {
  final GlobalKey scaffoldKey = GlobalKey();
  TextEditingController loginId;
  TextEditingController loginPw;
  String accountloginId = "";
  String accountloginPw = "";
  static bool loginStatus = false;
  bool loginVisible = true;
  bool memberVisible = false;
  bool accountVisible = false;
  static String realTimeKickboard = "없음";

  @override
  void initState() {
    super.initState();
    this.loginId = new TextEditingController();
    this.loginPw = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    RTKickboard();
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "마이페이지",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.autorenew, color: Colors.black),
              onPressed: updating),
          SizedBox(width: 20)
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque, // 키보드 올라왔을 때 화면터치로 내리기
          onTap: () {
            FocusScope.of(context).unfocus(); // 키보드 올라왔을 때 화면터치로 내리기
          },
          child: Column(
            children: [
              _paddingline(),
              Visibility(
                  maintainSize: loginVisible,
                  maintainAnimation: loginVisible,
                  maintainState: loginVisible,
                  visible: loginVisible,
                  child: Column(
                    children: [
                      _topPaddingAdd(),
                      _loginIdTextField(),
                      _topPaddingAdd(),
                      _loginPwTextField(),
                      _topPaddingAdd(),
                      _loginButton(),
                      _membershipJoinButton()
                    ],
                  )),
              Visibility(
                  maintainSize: memberVisible,
                  maintainAnimation: memberVisible,
                  maintainState: memberVisible,
                  visible: memberVisible,
                  child: Column(
                    children: [
                      _topPaddingAdd(),
                      _loginIdTextField(),
                      _topPaddingAdd(),
                      _loginPwTextField(),
                      _topPaddingAdd(),
                      _membershipButton()
                    ],
                  )),
              Visibility(
                  maintainSize: accountVisible,
                  maintainAnimation: accountVisible,
                  maintainState: accountVisible,
                  visible: accountVisible,
                  child: accountLoginPage()),
            ],
          ),
        ),
      ),
    );
  }

  void loginShowWidget() {
    setState(() {
      loginVisible = true;
      memberVisible = false;
      accountVisible = false;
    });
  }

  void memberShowWidget() {
    setState(() {
      loginVisible = false;
      memberVisible = true;
      accountVisible = false;
    });
  }

  void loginWidget() {
    setState(() {
      loginVisible = false;
      memberVisible = false;
      accountVisible = true;
    });
  }

  Widget _paddingline() {
    return Center(
        child: Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Container(
        height: 2.0,
        width: 350,
        color: Colors.black,
      ),
    ));
  }

  Widget _loginIdTextField() {
    return Container(
      alignment: Alignment.center,
      height: 50,
      width: 300,
      child: TextFormField(
        style: TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0)),
          labelText: "아이디를 입력해주세요.",
          labelStyle: TextStyle(fontSize: 14, color: Colors.black),
        ),
        keyboardType: TextInputType.text,
        onSaved: (String value) {
          accountloginId = value;
        },
        controller: this.loginId,
      ),
    );
  }

  Widget _loginPwTextField() {
    return Container(
      alignment: Alignment.center,
      height: 50,
      width: 300,
      child: TextFormField(
        style: TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0)),
          labelText: "비밀번호를 입력해주세요.",
          labelStyle: TextStyle(fontSize: 14, color: Colors.black),
        ),
        keyboardType: TextInputType.text,
        onSaved: (String value) {
          accountloginPw = value;
        },
        controller: this.loginPw,
      ),
    );
  }

  Widget _topPaddingAdd() {
    return Padding(padding: EdgeInsets.only(top: 30));
  }

  Widget _loginButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            if (loginId.text != "") {
              google_maps.GoogleMapsState.stopSocket
                  .write(PacketCreator.userLogin(loginId.text, loginPw.text));
              accountloginId = loginId.text;
              accountloginPw = loginPw.text;
              loginId.text = "";
              loginPw.text = "";
              loginWidget();
              showSnackBarWithKey("로그인 성공!");
              loginStatus = true;
            } else {
              showSnackBarWithKey("로그인 실패!");
              loginStatus = false;
            }
          });
        },
        child: Text("로그인",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)));
  }

  Widget _membershipJoinButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            memberShowWidget();
          });
        },
        child: Text.rich(TextSpan(
            text: "회원가입",
            style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey))));
  }

  Widget _membershipButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            if (loginId.text + loginPw.text != "") {
              google_maps.GoogleMapsState.stopSocket
                  .write(PacketCreator.userMember(loginId.text, loginPw.text));
              loginId.text = "";
              loginPw.text = "";
              loginShowWidget();
              showSnackBarWithKey("회원가입 성공!");
            } else {
              loginShowWidget();
            }
          });
        },
        child: Text("회원가입",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)));
  }

  void updating() {
    RTKickboard();
  }

  void RTKickboard() {
    setState(() {
      if (google_maps.GoogleMapsState.UserQr == "") {
        realTimeKickboard = "없음";
      } else {
        realTimeKickboard = google_maps.GoogleMapsState.UserQr;
      }
    });
  }

  Widget accountLoginPage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topPaddingAdd(),
          Center(
            // padding: EdgeInsets.only(left: 50),
            child: Text(
              "${accountloginId}님 반가워요!",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          _topPaddingAdd(),
          Text(
            "대여중인 킥보드",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          _paddingline(),
          _topPaddingAdd(),
          Center(
            child: Text(
              "현재 이용중인 킥보드 : ${realTimeKickboard}",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
            ),
          ),
          _topPaddingAdd(),
          Text(
            "사용 이력",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          _paddingline(),
          _topPaddingAdd(),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "대여 횟수 : ${usedKickboard.length}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              itemCount: usedKickboard.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {},
                        leading: Icon(Icons.qr_code_scanner,
                            color: Colors.black, size: 25),
                        title: Text(
                          "킥보드 고유 번호 : ${usedKickboard[index]}",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            ),
          ),
          _topPaddingAdd(),
          // Expanded(flex: 0, child: Container()), //맨 밑으로 보내기 위한 빈 공간 채우기
          Center(
            child: TextButton(
                onPressed: () {
                  setState(() {
                    loginShowWidget();
                  });
                },
                child: Text.rich(TextSpan(
                    text: "로그아웃",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)))),
          )
        ],
      ),
    );
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
}
