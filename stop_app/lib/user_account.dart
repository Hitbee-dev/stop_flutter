import 'package:flutter/material.dart';

class UserAccount extends StatelessWidget {
  const UserAccount({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "마이페이지",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _paddingline(),
          Row(
            children: [],
          ),
        ],
      ),
    );
  }

  Widget _paddingline() => Center(
          child: Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Container(
          height: 2.0,
          width: 350,
          color: Colors.black,
        ),
      ));
}
