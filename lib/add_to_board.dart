import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  GoogleMapController _controller;
  LocationData _currentPosition;
  String _address;
  GoogleMapController mapController;
  Location _location = Location();

  final _controllerName = TextEditingController();
  final _controllerPrice = TextEditingController();
  final _controllerDescription = TextEditingController();
  final _controllerPrecaution = TextEditingController();

  File _image;
  final picker = ImagePicker();
  String _path;

  String docId;
  double latitude, longitude;

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
      'email': FirebaseAuth.instance.currentUser.email,
      'latitude': latitude,
      'longitude': longitude,
      'address': _address,
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
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
          SafeArea(
            child: Container(
              child: Center(
                child: Column(
                children: [Container(
                height:  MediaQuery.of(context).size.height/2.5,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: _initialcameraposition,
                      zoom: 15),
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
          ),),
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
          SizedBox(height: 8),
        ],
      ),
    );
  }

  getLoc() async{
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
    _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);
    _location.onLocationChanged.listen((LocationData currentLocation) {
      print('${currentLocation.longitude} : ${currentLocation.longitude}');
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);

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
  Future<List<Address>> getPlaceAddress(double lat, double lng) async{
    final coordinates = new Coordinates(lat, lng);
    List<Address> add = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }
}
