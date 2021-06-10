import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'add_to_board.dart';
import 'detail.dart';

// ignore: non_constant_identifier_names
var COLORS = [
  Color(0xFFEF7A85),
  Color(0xFFFF90B3),
  Color(0xFFFFC2E2),
  Color(0xFFB892FF),
  Color(0xFFB892FF)
];

Future<String> downloadURL(String filePath) async {
  return await firebase_storage.FirebaseStorage.instance
      .ref(filePath)
      .getDownloadURL();
}

class BoardPage extends StatefulWidget {
  final String title = "";

  BoardPage({Key key, title}) : super(key: key);
  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  Query products = FirebaseFirestore.instance
      .collection('product')
      .orderBy('updateDate', descending: true);
  int _selectedIndex = 2;

  // var data = [
  //   {
  //     "title": "트리플래닛 해충제거제, 벌레가 안나와서 처분합니다.",
  //     "content": "7000원",
  //     "color": COLORS[new Random().nextInt(5)],
  //     "image": "https://cdn.imweb.me/thumbnail/20210517/579d440e07383.jpg"
  //   },
  //   {
  //     "title": "벌레퇴치제, 두번 썼습니다 거의 새거",
  //     "content": "5000원",
  //     "color": COLORS[new Random().nextInt(5)],
  //     "image": "https://cdn.imweb.me/thumbnail/20201222/00d3693b9465c.jpg"
  //   },
  //   {
  //     "title": "흙 10kg, 필요한 만큼 구매가능합니다",
  //     "content": "1kg당 1000원",
  //     "color": COLORS[new Random().nextInt(5)],
  //     "image": "https://cdn.imweb.me/thumbnail/20200706/5ef7d11cb0715.jpg"
  //   },
  //   {
  //     "title": "관엽식물 거래합니다 쿨거시 관리키트 드림",
  //     "content": "12000원",
  //     "color": COLORS[new Random().nextInt(5)],
  //     "image": "https://image2.xplant.co.kr/data/thumb/item/160x160-2/1621964107"
  //   },
  //   {
  //     "title": "이사가서 꽃 화분 처분합니다",
  //     "content": "10000원",
  //     "color": COLORS[new Random().nextInt(5)],
  //     "image": "https://image2.xplant.co.kr/data/thumb/item/160x160-2/1621947330"
  //   }
  // ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: new Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPage(
                    downloadImageURL: downloadURL('/logo.jpg'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white70,
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
                Navigator.pushNamed(context, '/product');
                break;
              case 2:
                Navigator.pushNamed(context, '/board');
                break;
              case 3:
                Navigator.pushNamed(context, '/chat');
                break;
              case 4:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: '상품',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: '중고거래',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: <Widget>[
                new Transform.translate(
                  offset: new Offset(
                      0.0, MediaQuery.of(context).size.height * 0.1050),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: products.snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.data == null)
                        return Center(child: CircularProgressIndicator());
                      return ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0.0),
                        scrollDirection: Axis.vertical,
                        primary: true,
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                          return FutureBuilder(
                            future: downloadURL(document.data()['filePath']),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> s) {
                              switch (s.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                default:
                                  return s.hasData
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailBoardPage(),
                                                settings: RouteSettings(
                                                  arguments:
                                                      document.data()['docId'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: AwesomeListItem(
                                            title: document.data()['이름'],
                                            price: document.data()['가격'],
                                            color:
                                                COLORS[new Random().nextInt(5)],
                                            image: s.data.toString(),
                                          ),
                                        )
                                      : Center(
                                          child: CircularProgressIndicator(),
                                        );
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                new Transform.translate(
                  offset: Offset(0.0, -56.0),
                  child: new Container(
                    child: new ClipPath(
                      clipper: new MyClipper(),
                      child: new Stack(
                        children: [
                          new Image.network(
                            "https://picsum.photos/800/400?random",
                            fit: BoxFit.cover,
                          ),
                          new Opacity(
                            opacity: 0.2,
                            child: new Container(color: COLORS[0]),
                          ),
                          new Transform.translate(
                            offset: Offset(0.0, 50.0),
                            child: new ListTile(
                              leading: new CircleAvatar(
                                child: new Container(
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                          "https://cdn.imweb.me/thumbnail/20201209/72087a59e649e.jpg"),
                                    ),
                                  ),
                                ),
                              ),
                              title: new Text(
                                "반려식물입양처",
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    letterSpacing: 2.0),
                              ),
                              subtitle: new Text(
                                "주변의 이웃과 반려식물의 기쁨을 나누세요",
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    letterSpacing: 2.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 90.0),
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height / 4.75);
    p.lineTo(0.0, size.height / 3.75);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

// ignore: must_be_immutable
class AwesomeListItem extends StatefulWidget {
  String title;
  int price;
  Color color;
  String image;

  AwesomeListItem({this.title, this.price, this.color, this.image});

  @override
  _AwesomeListItemState createState() => new _AwesomeListItemState();
}

class _AwesomeListItemState extends State<AwesomeListItem> {
  final formatCurrency = new NumberFormat.simpleCurrency(
    locale: "ko_KR",
    name: "",
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Container(width: 10.0, height: 190.0, color: widget.color),
        new Expanded(
          child: new Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  widget.title,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: new Text(
                    formatCurrency.format(widget.price) + "원",
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        new Container(
          height: 150.0,
          width: 150.0,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              new Transform.translate(
                offset: new Offset(50.0, 0.0),
                child: new Container(
                  height: 100.0,
                  width: 100.0,
                  color: widget.color,
                ),
              ),
              new Transform.translate(
                offset: Offset(10.0, 20.0),
                child: new Card(
                  elevation: 20.0,
                  child: new Container(
                    height: 120.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 10.0,
                            color: Colors.white,
                            style: BorderStyle.solid),
                        image: DecorationImage(
                          image: widget.image != null
                              ? NetworkImage(widget.image)
                              : null,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
