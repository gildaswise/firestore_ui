// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart'
    show FirebaseApp, FirebaseOptions;
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final String title = 'firestore_ui example';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class MessageListTile extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;
  final Function(DocumentSnapshot) onTap;

  const MessageListTile({
    Key key,
    this.index,
    this.document,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          document != null ? "${document['message']}" : 'No message retrieved'),
      subtitle: Text('Message ${this.index + 1}'),
      onTap: () => onTap(this.document),
    );
  }
}

class MessageGridTile extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;
  final Function(DocumentSnapshot) onTap;

  const MessageGridTile({
    Key key,
    this.index,
    this.document,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(document),
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
  final Firestore firestore;

  MyHomePage({Key key, this.firestore}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _controller =
      PageController(initialPage: 0, keepPage: true);

  int _currentIndex = 0;

  CollectionReference get messages => widget.firestore.collection('messages');

  Future<void> _addMessage() async =>
      await messages.document().setData(<String, dynamic>{
        'message': 'Hello world!',
      });

  Future<void> _removeMessage(DocumentSnapshot snapshot) async =>
      await widget.firestore.runTransaction((transaction) async {
        await transaction.delete(snapshot.reference).catchError(
            (exception, stacktrace) =>
                print("Couldn't remove item: $exception"));
      });

  void _updateIndex(int value) {
    if (mounted) {
      setState(() => _currentIndex = value);
      _controller.jumpToPage(_currentIndex);
    }
  }

  /// Feel free to experiment here with query parameters, upon calling `setState` or hot reloading
  /// the query will automatically update what's on the list. The easiest way to test this is to
  /// change the limit below, or remove it. The example collection has 500+ elements.
  Query get query => widget.firestore.collection('messages').limit(15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _updateIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_1),
            title: Text("List"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_2),
            title: Text("Grid"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_3),
            title: Text("Staggered"),
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
                print("Received on list: ${snapshot.documents.length}"),
            itemBuilder: (
              BuildContext context,
              DocumentSnapshot snapshot,
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
                print("Received on grid: ${snapshot.documents.length}"),
            crossAxisCount: 2,
            itemBuilder: (
              BuildContext context,
              DocumentSnapshot snapshot,
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
                print("Received on staggered: ${snapshot.documents.length}"),
            staggeredTileBuilder: (int index, DocumentSnapshot snapshot) =>
                StaggeredTile.count(2, index.isEven ? 2 : 1),
            crossAxisCount: 4,
            query: query,
            itemBuilder: (
              BuildContext context,
              DocumentSnapshot snapshot,
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
