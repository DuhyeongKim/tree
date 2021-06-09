import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          )
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
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                FirebaseAuth.instance.currentUser.uid,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          logoutButton(),
        ],
      ),
    );
  }

  Widget logoutButton() {
    return InkWell(
      onTap: () async {
        await googleSignIn.signOut();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      },
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
