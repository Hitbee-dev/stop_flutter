import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Informations extends StatefulWidget {
  @override
  _InformationsState createState() => _InformationsState();
}

class _InformationsState extends State<Informations> {
  String _questionText = "";
  TextEditingController _textEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Builder(
        builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              _InfoWidget(context),
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onChanged: (text) {
                        setState(() {
                          _questionText = text;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_search),
                        helperText: '문제점이 있거나, 개선사항이 필요한 경우 문의사항을 이용해주세요.',
                        hintText: '문의사항을 적어주세요.(최대 200자)',
                        hintStyle: TextStyle(fontSize: 15),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 7, vertical: 15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        alignment: Alignment.topLeft,
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("문의사항: $_questionText"),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _questionText = "";
                          _textEditingController.text = "";
                        });
                      },
                      label: Text("문의사항 접수하기",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      icon: Icon(Icons.send, size: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _InfoWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Card(
        elevation: 6,
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Icon(Icons.check_circle_outline,
                      size: 18, color: Colors.green),
                  Text('  주차 안내', style: TextStyle(fontSize: 15)),
                  Spacer(),
                  Icon(Icons.more_vert, size: 18, color: Colors.black54),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 40, right: 40, top: 30, bottom: 10),
              child: Column(
                children: <Widget>[
                  SizedBox(
                      height: 190,
                      child: Text(
                          '1. 주차불가구역\n'
                          '   1) 골목길\n'
                          '   2) 시각장애인용 보도블럭\n'
                          '   3) 차도 및 횡단보도\n\n'
                          '2. 요금안내\n'
                          '   1) 1분당 100원\n\n',
                          style: TextStyle(color: Colors.black54))),
                ],
              ),
            ),
            Divider(height: 2, color: Colors.black26),
            Container(
              child: Row(
                children: <Widget>[
                  Icon(Icons.history, size: 16, color: Colors.black38),
                  Text('  주차안내에 대한 상세정보',
                      style: TextStyle(fontSize: 14, color: Colors.black38)),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 16, color: Colors.black38),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            )
          ],
        ),
      ),
    );
  }
}
