import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.blueGrey,
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
        Container(),

        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30.0),
          Container(
            padding: EdgeInsets.fromLTRB(30.0, 30.0, 0.0, 20.0),
            width: 300.0,
            child: Text(
              "우리는 숲을 만드는\n회사입니다.",
              style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
              maxLines: 2,
            ),
          ),
          SizedBox(height: 50.0),
          Expanded(
            child: ListView(
              children: [
                _buildEventList(
                    "강원 산불피해 복구 숲",
                    "까맣게 타버린 강원의 숲,\n까맣게 잊은 당신에게",
                    Colors.red,
                    "images/home1.jpg",
                    "https://treepla.net/forestfires",
                    CrossAxisAlignment.start),
                _buildEventList(
                    "미세먼지 방지 교실 숲",
                    "미세먼지 없는 교실",
                    Colors.blueAccent,
                    "images/home2.jpg",
                    "https://treepla.net/indoorforest",
                    CrossAxisAlignment.end),
                _buildEventList(
                    "MAKE YOUR FARM",
                    "나무 심는 커피, MYF",
                    Colors.white70,
                    "images/home3.jpg",
                    "https://treepla.net/makeyourfarm",
                    CrossAxisAlignment.start),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _launchURL(String _url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Count not launch $_url';

Padding _buildEventList(String title, String subtitle, Color color,
    String image, String url, CrossAxisAlignment p) {
  return Padding(
    padding: EdgeInsets.all(10.0),
    child: Stack(
      children: <Widget>[
        Container(
          width: 400.0,
          height: 150.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOver,
              ),
            ),
          ),
        ),
        Container(
          width: 400.0,
          height: 150.0,
          child: Column(
            crossAxisAlignment: p,
            children: [
              Padding(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: p == CrossAxisAlignment.start
                    ? EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0)
                    : EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 0.0),
              ),
              Container(
                width: 200.0,
                padding: p == CrossAxisAlignment.start
                    ? EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 0.0)
                    : EdgeInsets.fromLTRB(0.0, 20.0, 30.0, 0.0),
                child: Column(
                  crossAxisAlignment: p,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _launchURL(url),
                      child: Text(
                        "참여하기>",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
