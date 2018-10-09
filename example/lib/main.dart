// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_list.dart';

final String title = 'firestore_ui example';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'test',
    options: const FirebaseOptions(
      googleAppID: '1:79601577497:ios:5f2bcc6ba8cecddd',
      gcmSenderID: '79601577497',
      apiKey: 'AIzaSyArgmRGfB5kiQT6CunAOmKRVKEsxKmy6YI-G72PVU',
      projectID: 'flutter-firestore',
    ),
  );
  final Firestore firestore = Firestore(app: app);

  runApp(MaterialApp(title: title, home: MyHomePage(firestore: firestore)));
}

class MessageItem extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;
  final Function(DocumentSnapshot) onTap;

  const MessageItem({
    Key key,
    this.index,
    this.document,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(document['message'] ?? '<No message retrieved>'),
      subtitle: Text('Message ${this.index + 1}'),
      onTap: () => onTap(this.document),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({this.firestore});
  final Firestore firestore;
  CollectionReference get messages => firestore.collection('messages');

  Future<Null> _addMessage() async {
    final DocumentReference document = messages.document();
    document.setData(<String, dynamic>{
      'message': 'Hello world!',
    });
  }

  Future<Null> _removeMessage(DocumentSnapshot snapshot) async {
    await firestore.runTransaction((transaction) async {
      await transaction.delete(snapshot.reference).catchError(
          (exception, stacktrace) => print("Couldn't remove item: $exception"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FirestoreAnimatedList(
        query: firestore.collection('messages').snapshots(),
        itemBuilder: (
          BuildContext context,
          DocumentSnapshot snapshot,
          Animation<double> animation,
          int index,
        ) {
          return FadeTransition(
            opacity: animation,
            child: MessageItem(
              index: index,
              document: snapshot,
              onTap: _removeMessage,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
