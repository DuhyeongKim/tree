import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:treeplanet/board.dart';

Future<void> uploadFile(String _path, String filePath) async {
  File file = File(_path);

  await firebase_storage.FirebaseStorage.instance.ref(filePath).putFile(file);
}

class AddPage extends StatefulWidget {
  AddPage({
    this.downloadImageURL,
  });

  final Future<String> downloadImageURL;

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _controllerName = TextEditingController();
  final _controllerPrice = TextEditingController();
  final _controllerDescription = TextEditingController();
  final _controllerPrecaution = TextEditingController();

  File _image;
  final picker = ImagePicker();
  String _path;

  String docId;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _path = pickedFile.path;
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> addProduct(
      String name, int price, String precaution, String description) {
    FirebaseFirestore product = FirebaseFirestore.instance;
    final future = product.collection('product').add({
      '이름': name,
      '가격': price,
      '주의사항': precaution,
      'description': description,
      'creationDate': FieldValue.serverTimestamp(),
      'updateDate': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser.uid,
    }).then((value) async {
      product.collection('product').doc(value.id).set({
        'docId': value.id,
        'filePath': value.id + '.jpg',
      }, SetOptions(merge: true));

      return value.id;
    });

    return future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        centerTitle: true,
        leading: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.black,
          ),
          child: Text(
            "취소",
            style: TextStyle(fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 100,
        title: Text('게시'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
            ),
            onPressed: () async {
              docId = await addProduct(
                _controllerName.text,
                int.parse(_controllerPrice.text),
                _controllerPrecaution.text,
                _controllerDescription.text,
              );
              uploadFile(_path, docId + '.jpg');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BoardPage(),
                ),
              );
            },
            child: Text(
              "저장",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _image == null
              ? FutureBuilder<String>(
                  future: widget.downloadImageURL,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return AspectRatio(
                          aspectRatio: 20 / 11,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      case ConnectionState.done:
                        return AspectRatio(
                          aspectRatio: 20 / 11,
                          child: Image.network(
                            snapshot.data.toString(),
                          ),
                        );
                    }
                    return null;
                  },
                )
              : AspectRatio(
                  aspectRatio: 20 / 11,
                  child: Image.file(
                    _image,
                    fit: BoxFit.cover,
                  ),
                ),
          Container(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
              ),
              onPressed: () {
                getImage();
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50),
            child: TextFormField(
              controller: _controllerName,
              decoration: InputDecoration(
                hintText: 'Product Name',
                hintStyle: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter name to continue';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 8),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50),
            child: TextFormField(
              controller: _controllerPrice,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.blue,
                ),
                hintText: 'Price',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter price to continue';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 8),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50),
            child: TextFormField(
              controller: _controllerPrecaution,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.blue,
                ),
                hintText: 'Precaution',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter precaution to continue';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 8),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50),
            child: TextFormField(
              maxLines: null,
              minLines: 5,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.multiline,
              controller: _controllerDescription,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.blue,
                ),
                hintText: 'Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter description to continue';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
