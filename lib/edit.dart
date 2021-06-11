import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:treeplanet/board.dart';

Future<void> uploadFile(String _path, String filePath) async {
  File file = File(_path);

  await firebase_storage.FirebaseStorage.instance.ref(filePath).putFile(file);
}

class EditScreen extends StatefulWidget {
  EditScreen({
    this.downloadImageURL,
  });

  final Future<String> downloadImageURL;

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _controllerName = TextEditingController();
  final _controllerPrice = TextEditingController();
  final _controllerPrecaution = TextEditingController();
  final _controllerDescription = TextEditingController();

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  LocationData _currentPosition;
  GoogleMapController mapController;
  Location _location = Location();
  GoogleMapController _controller;

  File _image;
  final picker = ImagePicker();
  String _path;

  String name;
  String price;
  String description;
  String precaution;
  String update;
  double latitude, longitude;
  String _address;

  int sw1 = 0;
  int sw2 = 0;
  int sw3 = 0;
  int sw4 = 0;

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

  void getData(String docId) async {
    final documentsObj =
        await FirebaseFirestore.instance.collection('product').doc(docId).get();

    name = documentsObj['이름'];
    price = documentsObj['가격'].toString();
    precaution = documentsObj['주의사항'];
    description = documentsObj['description'];
    update = documentsObj['updateDate'].toDate().toString();
  }

  void updateProduct(String docId, String name, int price, String precaution,
      String description) {
    FirebaseFirestore.instance.collection('product').doc(docId).update({
      '이름': name,
      '가격': price,
      '주의사항': precaution,
      'description': description,
      'updateDate': FieldValue.serverTimestamp(),
      'latitude': latitude,
      'longitude': longitude,
      'address': _address,
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
  }

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

      latitude = l.latitude;
      longitude = l.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DocumentReference product = ModalRoute.of(context).settings.arguments;

    getData(product.id);
    if (_controllerName.text.length == 0) {
      if (sw1 == 0) _controllerName.text = name;
    }
    if (_controllerPrice.text.length == 0) {
      if (sw2 == 0) _controllerPrice.text = price;
    }
    if (_controllerPrecaution.text.length == 0) {
      if (sw3 == 0) _controllerPrecaution.text = precaution;
    }
    if (_controllerDescription.text.length == 0) {
      if (sw4 == 0) _controllerDescription.text = description;
    }

    return FutureBuilder(
        future: product.get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.data == null)
            return Center(child: CircularProgressIndicator());
          return Scaffold(
            appBar: AppBar(
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
              title: Text('수정'),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    updateProduct(
                      product.id,
                      _controllerName.text,
                      int.parse(_controllerPrice.text),
                      _controllerPrecaution.text,
                      _controllerDescription.text,
                    );
                    uploadFile(_path, product.id + '.jpg');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoardPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Save",
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
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.active:
                            case ConnectionState.waiting:
                              return AspectRatio(
                                aspectRatio: 20 / 11,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            case ConnectionState.done:
                              return AspectRatio(
                                aspectRatio: 20 / 11,
                                child: Image.network(
                                  snapshot.data.toString(),
                                  fit: BoxFit.cover,
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
                SafeArea(
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 2.5,
                            width: MediaQuery.of(context).size.width,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                  target: _initialcameraposition, zoom: 15),
                              mapType: MapType.normal,
                              onMapCreated: _onMapCreated,
                              myLocationEnabled: true,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          if (_address != null)
                            Text(
                              "주소: $_address",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 50, right: 50),
                  child: Focus(
                    child: TextFormField(
                      controller: _controllerName,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        _controllerName.selection = TextSelection.fromPosition(
                            TextPosition(offset: _controllerName.text.length));
                        sw1 = 1;
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 50, right: 50),
                  child: Focus(
                    child: TextFormField(
                      controller: _controllerPrice,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                      ),
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
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        _controllerPrice.selection = TextSelection.fromPosition(
                            TextPosition(offset: _controllerPrice.text.length));
                        sw2 = 1;
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 50, right: 50),
                  child: Focus(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _controllerPrecaution,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: Colors.blue,
                            ),
                            hintText: '주의사항',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter precaution to continue';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        _controllerPrecaution.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: _controllerPrecaution.text.length));
                        sw3 = 1;
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 50, right: 50),
                  child: Focus(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _controllerDescription,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 15,
                          ),
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
                      ],
                    ),
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        _controllerDescription.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: _controllerDescription.text.length));
                        sw4 = 1;
                      }
                    },
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          );
        });
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await _location.getLocation();
    _initialcameraposition =
        LatLng(_currentPosition.latitude, _currentPosition.longitude);
    _location.onLocationChanged.listen((LocationData currentLocation) {
      print('${currentLocation.longitude} : ${currentLocation.longitude}');
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition =
            LatLng(_currentPosition.latitude, _currentPosition.longitude);

        // DateTime now = DateTime.now();
        // _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
        getPlaceAddress(_currentPosition.latitude, _currentPosition.longitude)
            .then((value) {
          setState(() {
            _address = '${value.first.addressLine}';
          });
        });
      });
    });
  }

  Future<List<Address>> getPlaceAddress(double lat, double lng) async {
    final coordinates = new Coordinates(lat, lng);
    List<Address> add =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }
}
