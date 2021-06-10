import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets.dart';

class DirectMessage extends StatefulWidget {
  @override
  _DirectMessageState createState() => _DirectMessageState();
}

class _DirectMessageState extends State<DirectMessage> {
  @override
  Widget build(BuildContext context) {
    final String docId = ModalRoute.of(context).settings.arguments;
    Query m = FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(docId)
        .collection('chats')
        .orderBy("creationDate", descending: false);
    final _formKey = GlobalKey<FormState>(debugLabel: '_DirectMessageState');
    final _controller = TextEditingController();

    Future<String> sendMessage(String content) {
      DocumentReference dm =
          FirebaseFirestore.instance.collection('chatRoom').doc(docId);

      dm.set({
        'sellerId': docId.split("_")[0],
        'purchaserId': FirebaseAuth.instance.currentUser.uid,
      });

      final future = dm.collection('chats').add({
        'creationDate': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser.uid,
        'content': content,
      }).then((value) async {
        dm.collection('chats').doc(value.id).set({
          'docId': value.id,
        }, SetOptions(merge: true));

        return value.id;
      });

      return future;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: m.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null)
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              scrollDirection: Axis.vertical,
              children: [
                SizedBox(height: 150.0),
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
                              await sendMessage(_controller.text);
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
              ],
            );
          else {
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              scrollDirection: Axis.vertical,
              children: [
                Column(
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    return Align(
                      alignment: document.data()['userId'] ==
                              FirebaseAuth.instance.currentUser.uid
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 14,
                          right: 14,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: document.data()['userId'] ==
                                      FirebaseAuth.instance.currentUser.uid
                                  ? Colors.green
                                  : Colors.yellow),
                          padding: EdgeInsets.all(16),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          child: Text(
                            document.data()['content'],
                            style: TextStyle(
                                fontSize: 15.0,
                                color: document.data()['userId'] ==
                                        FirebaseAuth.instance.currentUser.uid
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
                              await sendMessage(_controller.text);
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
              ],
            );
          }
        },
      ),
    );
  }
}
