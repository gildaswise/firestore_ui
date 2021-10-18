// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final String title = 'firestore_ui example';

typedef OnSnapshot = Function(DocumentSnapshot?);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      title: title, home: MyHomePage(firestore: FirebaseFirestore.instance)));
}

class MessageListTile extends StatelessWidget {
  final int index;
  final DocumentSnapshot? document;
  final OnSnapshot? onTap;

  const MessageListTile({
    Key? key,
    required this.index,
    required this.document,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message = 'No message retrieved!';
    if (document != null) {
      final data = document!.data();
      if (data != null) {
        final receivedMessage = (data as Map)['message'];
        if (receivedMessage != null) message = receivedMessage;
      }
    }

    return ListTile(
      title: Text(message),
      subtitle: Text('Message ${this.index + 1}'),
      onTap: document != null && onTap != null
          ? () => onTap!.call(this.document!)
          : null,
    );
  }
}

class MessageGridTile extends StatelessWidget {
  final int index;
  final DocumentSnapshot? document;
  final OnSnapshot? onTap;

  const MessageGridTile({
    Key? key,
    required this.index,
    required this.document,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: document != null && onTap != null
          ? () => onTap!.call(this.document!)
          : null,
      child: Container(
        color: Colors.green,
        child: Center(
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text('${this.index + 1}'),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final FirebaseFirestore firestore;

  MyHomePage({Key? key, required this.firestore}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _controller =
      PageController(initialPage: 0, keepPage: true);

  int _currentIndex = 0;

  CollectionReference get messages => widget.firestore.collection('messages');

  _addMessage() => messages.doc().set(<String, dynamic>{
        'message': 'Hello world!',
      });

  _removeMessage(DocumentSnapshot? snapshot) {
    if (snapshot != null)
      widget.firestore.runTransaction((transaction) async {
        transaction.delete(snapshot.reference);
      }).catchError((exception, stacktrace) {
        print("Couldn't remove item: $exception");
      });
  }

  void _updateIndex(int value) {
    if (mounted) {
      setState(() => _currentIndex = value);
      _controller.jumpToPage(_currentIndex);
    }
  }

  /// Feel free to experiment here with query parameters, upon calling `setState` or hot reloading
  /// the query will automatically update what's on the list. The easiest way to test this is to
  /// change the limit below, or remove it. The example collection has 500+ elements.
  Query get query => widget.firestore.collection('messages').limit(20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _updateIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_1),
            label: "List",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_2),
            label: "Grid",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_3),
            label: "Staggered",
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      body: PageView(
        controller: _controller,
        children: <Widget>[
          FirestoreAnimatedList(
            debug: false,
            key: ValueKey("list"),
            query: query,
            onLoaded: (snapshot) =>
                print("Received on list: ${snapshot.docs.length}"),
            itemBuilder: (
              BuildContext context,
              DocumentSnapshot? snapshot,
              Animation<double> animation,
              int index,
            ) =>
                FadeTransition(
              opacity: animation,
              child: MessageListTile(
                index: index,
                document: snapshot,
                onTap: _removeMessage,
              ),
            ),
          ),
          FirestoreAnimatedGrid(
            key: ValueKey("grid"),
            query: query,
            onLoaded: (snapshot) =>
                print("Received on grid: ${snapshot.docs.length}"),
            crossAxisCount: 2,
            itemBuilder: (
              BuildContext context,
              DocumentSnapshot? snapshot,
              Animation<double> animation,
              int index,
            ) {
              return FadeTransition(
                opacity: animation,
                child: MessageGridTile(
                  index: index,
                  document: snapshot,
                  onTap: _removeMessage,
                ),
              );
            },
          ),
          FirestoreAnimatedStaggered(
            key: ValueKey("staggered"),
            onLoaded: (snapshot) =>
                print("Received on staggered: ${snapshot.docs.length}"),
            staggeredTileBuilder: (int index, DocumentSnapshot? snapshot) =>
                StaggeredTile.count(2, index.isEven ? 2 : 1),
            crossAxisCount: 4,
            query: query,
            itemBuilder: (
              BuildContext context,
              DocumentSnapshot? snapshot,
              Animation<double> animation,
              int index,
            ) {
              return FadeTransition(
                opacity: animation,
                child: MessageGridTile(
                  index: index,
                  document: snapshot,
                  onTap: _removeMessage,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
