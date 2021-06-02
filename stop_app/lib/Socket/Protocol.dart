class Protocol {
  static final int HEADER_SIZE = 8;
  static Map Decoder(String packet) {
    Map dict = new Map();
    String data = packet.substring(HEADER_SIZE);
    List<String> part = data.split("|");
    // key:value
    for (int i = 0; i < part.length; i++) {
      String e = part[i].toString();
      if (e == "") continue;
      List<String> kv = e.split(":");
      String key = kv[0];
      String value = kv[1];
      if (value.contains("\\i")) {
        value = value.replaceAll("\\i", "");
        dict[key] = int.parse(value);
      } else if (value.contains("\\d")) {
        value = value.replaceAll("\\d", "");
        dict[key] = double.parse(value);
      } else {
        value = value.replaceAll("\\cm", ":");
        value = value.replaceAll("\\v", "|");
        dict[key] = value;
      }
    }
    return dict;
  }

  static String resDecoder(String res) {
    String resorigin = res.substring(res.lastIndexOf("res: "));
    String resdata = resorigin.substring(5, 6);
    return resdata;
  }

  static String Encoder(Map data) {
    String packet = "";
    data.forEach((key, value) {
      packet += key.toString() + ":";
      if (value.runtimeType == int) {
        packet += "\\i" + value.toString();
      } else if (value.runtimeType == double) {
        packet += "\\d" + value.toString();
      } else {
        String v = value.toString();
        v = v.replaceAll("|", "\\v");
        v = v.replaceAll(":", "\\cm");
        packet += v;
      }
      packet += "|";
    });
    String plen = packet.length.toString();
    packet = "0" * (HEADER_SIZE - plen.length) + plen + packet;
    return packet;
  }
}
