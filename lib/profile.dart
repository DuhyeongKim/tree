import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DocumentSnapshot snapshot;

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  BuildContext context;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff090310),
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios),
        elevation: 0,
        backgroundColor: Colors.green,
        actions: <Widget>[
          Padding(padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.more_vert, color: Colors.white,),)
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
                Navigator.pushNamed(context, '/used');
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
      body: ListView(
        children: [
          //for circle avtar image
          _getHeader(),
          SizedBox(
            height: 10,
          ),
          _profileName("Raj Jani"),
          SizedBox(
            height: 14,
          ),
          _heading("Personal Details"),
          SizedBox(
            height: 6,
          ),
          _detailsCard(),
          SizedBox(
            height: 10,
          ),
          _heading("Settings"),
          SizedBox(
            height: 6,
          ),
          _settingsCard(),
          Spacer(),
          logoutButton()
        ],
      ),
    );
  }
  Widget _getHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              //borderRadius: BorderRadius.all(Radius.circular(10.0)),
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        "https://post-phinf.pstatic.net/MjAxNzA0MTBfMjYz/MDAxNDkxODEyODM0NzI2.MqvNBVUVMya9_sMN_C4z2VDEaPPgtaG5-drh2xEIz94g.P4XkLvETgdeugChd64BQSn_JT5WbXH-XrrjH4UIW0JUg.JPEG/%EA%B3%B5%EC%9C%A0_22.JPG?type=w1200"))
              // color: Colors.orange[100],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileName(String name) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80, //80% of width,
      child: Center(
        child: Text(
          name,
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _heading(String heading) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80, //80% of width,
      child: Text(
        heading,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _detailsCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            //row for each deatails
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Something@gmail.com"),
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("1234567890"),
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text("SomeWhere"),
            )
          ],
        ),
      ),
    );
  }

  Widget _settingsCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            //row for each deatails
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.dashboard_customize),
              title: Text("About Us"),
            ),
            Divider(
              height: 0.6,
              color: Colors.black87,
            ),
            ListTile(
              leading: Icon(Icons.topic),
              title: Text("Change Theme"),
            )
          ],
        ),
      ),
    );
  }

  Widget logoutButton() {
    return InkWell(
      onTap: () {},
      child: Container(
          color: Colors.orange,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )
              ],
            ),
          )),
    );
  }
}