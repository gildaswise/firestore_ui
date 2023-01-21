// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firestore_ui/firestore_ui.dart';
import 'package:firestore_ui_example/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final String title = 'firestore_ui example';

typedef OnSnapshot = Function(DocumentSnapshot<Map<String, dynamic>>?);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      title: title,
      home: MyHomePage(firestore: FirebaseFirestore.instance),
    ),
  );
}

@immutable
class Movie {
  Movie({
    required this.genre,
    required this.likes,
    required this.poster,
    required this.rated,
    required this.runtime,
    required this.title,
    required this.year,
  });

  Movie.fromJson(Map<String, Object?> json)
      : this(
    genre: (json['genre']! as List).cast<String>(),
    likes: json['likes']! as int,
    poster: json['poster']! as String,
    rated: json['rated']! as String,
    runtime: json['runtime']! as String,
    title: json['title']! as String,
    year: json['year']! as int,
  );

  final String poster;
  final int likes;
  final String title;
  final int year;
  final String runtime;
  final String rated;
  final List<String> genre;

  Map<String, Object?> toJson() {
    return {
      'genre': genre,
      'likes': likes,
      'poster': poster,
      'rated': rated,
      'runtime': runtime,
      'title': title,
      'year': year,
    };
  }
}

class MovieListTile extends StatelessWidget {
  final int index;
  final DocumentSnapshot<Movie>? document;

  const MovieListTile({
    Key? key,
    required this.index,
    required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = 'No movie retrieved!';
    if (document != null && document!.exists) {
      final receivedMessage = document!.data()?.title;
      if (receivedMessage != null) title = receivedMessage;
    }

    return ListTile(
      title: Text(title),
      subtitle: Text('Item ${this.index + 1}'),
    );
  }
}

class MessageGridTile extends StatelessWidget {
  final int index;
  final DocumentSnapshot<Movie>? document;

  const MessageGridTile({
    Key? key,
    required this.index,
    required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text('${this.index + 1}'),
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
  final PageController _controller = PageController(initialPage: 0, keepPage: true);

  int _currentIndex = 0;

  void _updateIndex(int value) {
    if (mounted) {
      setState(() => _currentIndex = value);
      _controller.jumpToPage(_currentIndex);
    }
  }

  /// Feel free to experiment here with query parameters, upon calling `setState` or hot reloading
  /// the query will automatically update what's on the list. The easiest way to test this is to
  /// change the limit below, or remove it. The example collection has 500+ elements.
  Query<Movie> get query => widget.firestore.collection('firestore-example-app').withConverter<Movie>(
    fromFirestore: (snapshots, _) => Movie.fromJson(snapshots.data()!),
    toFirestore: (movie, _) => movie.toJson(),
  ).limit(20);

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
      body: PageView(
        controller: _controller,
        children: <Widget>[
          FirestoreAnimatedList<Movie>(
            debug: false,
            key: ValueKey("list"),
            query: query,
            onLoaded: (snapshot) => print("Received on list: ${snapshot.docs.length}"),
            itemBuilder: (
              BuildContext context,
              snapshot,
              Animation<double> animation,
              int index,
            ) =>
                FadeTransition(
              opacity: animation,
              child: MovieListTile(
                index: index,
                document: snapshot,
              ),
            ),
          ),
          FirestoreAnimatedGrid<Movie>(
            key: ValueKey("grid"),
            query: query,
            onLoaded: (snapshot) => print("Received on grid: ${snapshot.docs.length}"),
            crossAxisCount: 2,
            itemBuilder: (
              BuildContext context,
              snapshot,
              Animation<double> animation,
              int index,
            ) {
              return FadeTransition(
                opacity: animation,
                child: MessageGridTile(
                  index: index,
                  document: snapshot,
                ),
              );
            },
          ),
          FirestoreAnimatedStaggered<Movie>(
            key: ValueKey("staggered"),
            onLoaded: (snapshot) => print("Received on staggered: ${snapshot.docs.length}"),
            staggeredTileBuilder: (int index, DocumentSnapshot? snapshot) => StaggeredTile.count(2, index.isEven ? 2 : 1),
            crossAxisCount: 4,
            query: query,
            itemBuilder: (
              BuildContext context,
              snapshot,
              Animation<double> animation,
              int index,
            ) {
              return FadeTransition(
                opacity: animation,
                child: MessageGridTile(
                  index: index,
                  document: snapshot,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
