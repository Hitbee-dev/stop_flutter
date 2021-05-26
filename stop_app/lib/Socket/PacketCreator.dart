import 'package:stop_app/Socket/Protocol.dart';

class PacketCreator {
  static final int KICKBOARD_CODE = 100;
  static final int USER_LOGIN = 101;
  static final int USER_MEMBER = 102;

  static String sendKickboardCode(String code) {
    Map data = new Map();
    data["part"] = KICKBOARD_CODE;
    data["code"] = code;
    return Protocol.Encoder(data);
  }

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
}
