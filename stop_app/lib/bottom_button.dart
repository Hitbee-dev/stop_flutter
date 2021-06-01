import 'package:flutter/material.dart';
import 'package:stop_app/google_maps.dart';
import 'package:stop_app/informations.dart';
import 'package:stop_app/user_account.dart';

class BottomButton extends StatefulWidget {
  BottomButton({
    Key key,
  }) : super(key: key);

  @override
  BottomButtonState createState() => BottomButtonState();
}

class BottomButtonState extends State<BottomButton> {
  @override
  void initState() {
    super.initState();
  }

  List<BottomNavigationBarItem> btmNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.map), label: "지도"),
    BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "주차 안내"),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "내 정보"),
  ];

  int _selectedIndex = 0;

  static List<Widget> screens = <Widget>[
    GoogleMaps(),
    Informations(),
    UserAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: btmNavItems,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black87,
          currentIndex: _selectedIndex,
          onTap: _onBtmItemClick,
        ));
  }

  void _onBtmItemClick(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
