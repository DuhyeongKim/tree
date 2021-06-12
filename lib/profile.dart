import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treeplanet/payment.dart';

import 'login.dart';
import 'product.dart';
import 'products_repository.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  BuildContext context;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;
  int total = 0;

  Future<bool> docExist() async {
    FirebaseFirestore cart = FirebaseFirestore.instance;

    var a = await cart
        .collection('addToCart')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();

    return a.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/plant.png'),
            fit: BoxFit.cover
          )),

      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
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
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                FirebaseAuth.instance.currentUser.email,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cart',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: docExist(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('addToCart')
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        List<dynamic> ids = snapshot.data['saved'];
                        List<Product> products =
                            ProductsRepository.loadProducts(Category.all);

                        return Expanded(

                          child: ListView(

                            shrinkWrap: true,
                            padding: const EdgeInsets.all(0.0),
                            scrollDirection: Axis.vertical,

                            children: ids
                                .map(
                                  (e) => Container(

                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage('images/groom.jpg'),
                                            fit: BoxFit.cover
                                        )),
                                    alignment: Alignment.center,
                                    child:
                                      Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(10.0),
                                            child: Padding(
                                              padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            products[e].name,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),

                                  ),


                                    SizedBox(width: 10.0),
                                       Divider(),
                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: <Widget>[

                                           Text(
                                             products[e].price.toString(),
                                             style: TextStyle(
                                               fontSize: 20.0,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.white,
                                             ),
                                           ),
                                          SizedBox(width: 20.0,),


                                        //    Container(
                                        //        width: 20.0,
                                        //        height: 20.0,
                                        //        decoration: BoxDecoration(
                                        //          color: Colors.blue[300],
                                        //          borderRadius: BorderRadius.circular(4.0),),
                                        //        child: Icon(
                                        //          Icons.add,
                                        //          color: Colors.white,
                                        //          size: 15.0,
                                        //        )
                                        //    ),
                                        //
                                        //    Padding(
                                        //      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        //        child: Text(
                                        //          "1",
                                        //          style: TextStyle(
                                        //            fontSize: 18.0,
                                        //            fontWeight: FontWeight.bold,
                                        //            color: Colors.black,
                                        //          ),
                                        //        ),
                                        //    ),
                                        //
                                        //
                                        // Container(
                                        //   width: 20.0,
                                        //   height: 20.0,
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.grey[300],
                                        //     borderRadius: BorderRadius.circular(4.0),),
                                        //   child: Icon(
                                        //     Icons.remove,
                                        //     color: Colors.white,
                                        //     size: 15.0,
                                        //   )
                                        // ),


                                       ]),


                                    ]),


                                  )).toList(),

                          ),

                        );
                      }
                    },
                  );
                } else {
                  return Container(height: 800);
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),

        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Total",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              total.toString(),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainCard()),
                );
              },
              elevation: 0.5,
              color: Colors.cyan,
              child: Center(
                child: Text(
                  'Pay Now',
                ),
              ),
            ),
          ),
          logoutButton(),
        ],
      ),
    ),);
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
          color: Colors.indigoAccent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
