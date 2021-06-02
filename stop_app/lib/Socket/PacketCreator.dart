import 'package:stop_app/Socket/Protocol.dart';

class PacketCreator {
  static final int USER_LOGIN = 101;
  static final int USER_MEMBER = 102;
  static final int KICKBOARD_REQ = 103;
  static final int KICKBOARD_RET = 104;
  static final int LOADING_DIALOG = 300;

  static String userLogin(String id, String pw) {
    Map data = new Map();
    data["part"] = USER_LOGIN;
    data["id"] = id;
    data["pw"] = pw;
    return Protocol.Encoder(data);
  }

  static String userMember(String id, String pw) {
    Map data = new Map();
    data["part"] = USER_MEMBER;
    data["id"] = id;
    data["pw"] = pw;
    return Protocol.Encoder(data);
  }

  static String kickboardReq(String code) {
    Map data = new Map();
    data["part"] = KICKBOARD_REQ;
    data["code"] = code;
    return Protocol.Encoder(data);
  }

  static String kickboardRet(String code) {
    Map data = new Map();
    data["part"] = KICKBOARD_RET;
    data["code"] = code;
    return Protocol.Encoder(data);
  }

  static String dialog(String code) {
    Map data = new Map();
    data["part"] = LOADING_DIALOG;
    data["code"] = code;
    return Protocol.Encoder(data);
  }
}
