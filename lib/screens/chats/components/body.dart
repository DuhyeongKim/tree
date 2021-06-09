import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:treeplanet/direct_message.dart';

class Body extends StatelessWidget {
  Query messages = FirebaseFirestore.instance
      .collection('chatRoom')
      .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messages.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator());
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          scrollDirection: Axis.vertical,
          primary: true,
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                alignment: Alignment.center,
                child: OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      document.data()['purchaserId'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DirectMessage(),
                        settings: RouteSettings(
                          arguments: document.id
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
