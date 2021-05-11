import 'package:flutter/material.dart';
import 'package:stop_app/google_maps.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BottomNavigationBarItem> btmNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.map), label: "지도"),
    BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "주차 안내"),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "내 정보"),
  ];

  int _selectedIndex = 0;

  static List<Widget> _screens = <Widget> [
    GoogleMaps(),
    Container(color: Colors.green),
    Container(color: Colors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: btmNavItems,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black87,
          currentIndex: _selectedIndex,
          onTap: _onBtmItemClick,
        )
    );
  }

  void _onBtmItemClick(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}