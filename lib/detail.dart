import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'product.dart';
import 'productView.dart';
import 'widgets.dart';
import 'direct_message.dart';
import 'edit.dart';

Future<String> downloadURL(String filePath) async {
  return await firebase_storage.FirebaseStorage.instance
      .ref(filePath)
      .getDownloadURL();
}

class DetailProductPage extends StatefulWidget {
  @override
  _DetailProductPageState createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  int _selectedIndex = 1;

  final formatCurrency = new NumberFormat.simpleCurrency(
    locale: "ko_KR",
    name: "",
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
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
          Container(
            height: 300.0,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              product.assetName,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 30.0),
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCurrency.format(product.price) + "원",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    product.description,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.greenAccent,
                      ),
                      onPressed: () async {
                        if (await addToCart(product.id)) {
                          setState(() {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('상품이 이미 존재합니다')));
                          });
                        } else {
                          setState(() {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('장바구니에 담았습니다')));
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                          ),
                          SizedBox(width: 10.0),
                          Text("ADD TO CART"),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBoardPage extends StatefulWidget {
  @override
  _DetailBoardPageState createState() => _DetailBoardPageState();
}

class _DetailBoardPageState extends State<DetailBoardPage> {
  int _selectedIndex = 2;
  List<Marker> customMarkers = [];
  GoogleMapController _controller;
  GoogleMapController mapController;
  Location _location = Location();

  final formatCurrency = new NumberFormat.simpleCurrency(
    locale: "ko_KR",
    name: "",
    decimalDigits: 0,
  );

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 15),
        ),
      );
      // final marker = Marker(
      //   position: LatLng(l.latitude, l.longitude),
      //   infoWindow: InfoWindow(
      //     title: '판매자 위치',
      //   ),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final String docId = ModalRoute.of(context).settings.arguments;
    DocumentReference p =
        FirebaseFirestore.instance.collection('product').doc(docId);
    final _formKey = GlobalKey<FormState>(debugLabel: '_DetailBoardPageState');
    final _controller = TextEditingController();

    Future<String> addQuestion(String content) {
      FirebaseFirestore question = FirebaseFirestore.instance;
      final future = question.collection('question').add({
        'creationDate': FieldValue.serverTimestamp(),
        'updateDate': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser.uid,
        'email': FirebaseAuth.instance.currentUser.email,
        'productId': docId,
        'content': content,
      }).then((value) async {
        question.collection('question').doc(value.id).set({
          'docId': value.id,
        }, SetOptions(merge: true));

        return value.id;
      });

      return future;
    }

    return FutureBuilder(
        future: p.get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.data == null)
            return Center(
              child: CircularProgressIndicator(),
            );
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white70,
              actions: [
                if (snapshot.data['userId'] ==
                    FirebaseAuth.instance.currentUser.uid)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          semanticLabel: 'edit',
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditScreen(
                                downloadImageURL:
                                    downloadURL(snapshot.data['filePath']),
                              ),
                              settings: RouteSettings(arguments: p),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          semanticLabel: 'delete',
                        ),
                        onPressed: () async {
                          await p.delete();
                        },
                      ),
                    ],
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
            body: FutureBuilder(
              future: p.get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.data == null)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                return ListView(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: FutureBuilder<String>(
                        future: downloadURL(snapshot.data['filePath']),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> element) {
                          switch (element.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.active:
                            case ConnectionState.waiting:
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            case ConnectionState.done:
                              return AspectRatio(
                                aspectRatio: 20 / 11,
                                child: Image.network(
                                  element.data.toString(),
                                  fit: BoxFit.cover,
                                ),
                              );
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              snapshot.data['이름'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formatCurrency.format(snapshot.data['가격']) + "원",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              snapshot.data['주의사항'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              snapshot.data['description'],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 15.0),

                          SafeArea(
                            child: Container(
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.5,
                                      width: MediaQuery.of(context).size.width,
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(36.09188893891537, 129.3835571480815),
                                            //(snapshot.data['latitude'], snapshot.data['longitude']),
                                          zoom: 15),

                                        //markers: ,
                                        //onMapCreated: mapCreated,
                                        ),
                                      ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      snapshot.data['address'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30.0),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('question')
                                .where("productId", isEqualTo: docId)
                                .orderBy('updateDate', descending: true)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.data == null)
                                return SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(),
                                );
                              return Container(
                                height: 200.0,
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(0.0),
                                  scrollDirection: Axis.vertical,
                                  primary: true,
                                  children: snapshot.data.docs
                                      .map((DocumentSnapshot document) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: Paragraph(
                                                  '${document.data()['email']}: ${document.data()['content']}'),
                                            ),
                                            if (document.data()['userId'] ==
                                                FirebaseAuth
                                                    .instance.currentUser.uid)
                                              Expanded(
                                                child: IconButton(
                                                    icon: Icon(
                                                        Icons.delete_outline),
                                                    onPressed: () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'question')
                                                          .doc(document
                                                              .data()['docId'])
                                                          .delete();
                                                    }),
                                              )
                                            else
                                              Expanded(
                                                child: SizedBox(),
                                              ),
                                          ],
                                        ),
                                        ParagraphDate(
                                            document.data()['updateDate'] !=
                                                    null
                                                ? document
                                                    .data()['updateDate']
                                                    .toDate()
                                                : null),
                                        SizedBox(height: 8),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 30.0),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formKey,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _controller,
                                      decoration: const InputDecoration(
                                        hintText: 'Leave a message',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter your message to continue';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  StyledButton(
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        await addQuestion(_controller.text);
                                        _controller.clear();
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.send),
                                        SizedBox(width: 4),
                                        Text('SEND'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 50),
                          FutureBuilder<DocumentSnapshot>(
                              future: p.get(),
                              builder: (context, snapshot) {
                                return FloatingActionButton.extended(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DirectMessage(),
                                        settings: RouteSettings(
                                          arguments: snapshot.data['email'] +
                                              "_" +
                                              FirebaseAuth
                                                  .instance.currentUser.email,
                                        ),
                                      ),
                                    );
                                  },
                                  label: Text('DM'),
                                );
                              }),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }
}
