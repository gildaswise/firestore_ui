// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/stream_subscriber_mixin.dart';
import 'package:flutter/foundation.dart';

typedef void DocumentCallback<T>(int index, DocumentSnapshot<T> snapshot);
typedef bool FilterCallback<T>(DocumentSnapshot<T> snapshot);
typedef void ValueCallback<T>(DocumentSnapshot<T> snapshot);
typedef void QueryCallback<T>(QuerySnapshot<T> querySnapshot);
typedef void ErrorCallback(Exception error);

/// Handles [DocumentChange] events, errors and streaming
class FirestoreList<T> extends ListBase<DocumentSnapshot<T>?>
    with StreamSubscriberMixin<QuerySnapshot<T>> {
  FirestoreList({
    required this.query,
    this.onDocumentAdded,
    this.onDocumentRemoved,
    this.onDocumentChanged,
    this.onLoaded,
    this.onValue,
    this.onError,
    this.filter,
    this.linear = false,
    this.debug = false,
  }) {
    listen(
      query.snapshots(),
      _onData,
      onError: (Object error) => _onError(error as Exception),
    );
  }

  /// Firestore query used to populate the list
  final Query<T> query;

  /// Whether or not to show debug logs
  final bool debug;

  /// This will change `onDocumentAdded` call to `.add` instead of `.insert`,
  /// which might help if your query doesn't care about order changes
  final bool linear;

  static const String TAG = "FIRESTORE_LIST";

  /// Called before any operation with a DocumentSnapshot;
  /// If it returns `true`, then dismisses that DocumentSnapshot from the list
  final FilterCallback<T>? filter;

  /// Called when the Document has been added
  final DocumentCallback<T>? onDocumentAdded;

  /// Called when the Document has been removed
  final DocumentCallback<T>? onDocumentRemoved;

  /// Called when the Document has changed
  final DocumentCallback<T>? onDocumentChanged;

  /// Called when the data of the list has finished loading
  final ValueCallback<T>? onValue;

  /// Called when the full list has been loaded
  final QueryCallback<T>? onLoaded;

  /// Called when an error is reported (e.g. permission denied)
  final ErrorCallback? onError;

  // ListBase implementation
  final List<DocumentSnapshot<T>> _snapshots = <DocumentSnapshot<T>>[];

  @override
  int get length => _snapshots.length;

  @override
  set length(int value) {
    throw UnsupportedError("List cannot be modified.");
  }

  @override
  DocumentSnapshot<T>? operator [](int index) =>
      _snapshots.isEmpty || index < 0 || index >= length
          ? null
          : _snapshots[index];

  @override
  void operator []=(int index, DocumentSnapshot<T>? value) {
    throw UnsupportedError("List cannot be modified.");
  }

  @override
  void clear() {
    cancelSubscriptions();
    // Do not call super.clear(), it will set the length, it's unsupported.
  }

  void log(String message) {
    if (debug) print("[$TAG] $message");
  }

  int _indexForKey(String key) {
    assert(key.isNotEmpty);
    return _snapshots.indexWhere((DocumentSnapshot<T> item) => item.id == key);
  }

  void _onChange(List<DocumentChange<T>> documentChanges) {
    if (documentChanges.isNotEmpty) {
      for (DocumentChange<T> change in documentChanges) {
        final isHidden = filter?.call(change.doc) ?? false;
        log("Document ${change.doc.id} is hidden: $isHidden");
        if (isHidden) {
          log("Document ${change.doc.id} filtered out of list");
        } else {
          switch (change.type) {
            case DocumentChangeType.added:
              _onDocumentAdded(change);
              break;
            case DocumentChangeType.modified:
              _onDocumentChanged(change);
              break;
            case DocumentChangeType.removed:
              _onDocumentRemoved(change);
              break;
          }
          _onValue(change.doc);
        }
      }
    } else {
      log("Got null or empty list of DocumentChange, nothing to do.");
    }
  }

  void _onData(QuerySnapshot<T> snapshot) {
    log("Calling _onData for a new QuerySnapshot");
    log("QuerySnapshot.documents: ${snapshot.docs.length}");
    log("QuerySnapshot.documentChanges: ${snapshot.docChanges.length}");
    onLoaded?.call(snapshot);
    _onChange(snapshot.docChanges);
  }

  void _onDocumentAdded(DocumentChange<T> event) {
    try {
      log("Calling _onDocumentAdded for document on index ${event.newIndex}");
      if (linear) {
        _snapshots.add(event.doc);
        onDocumentAdded?.call(_snapshots.length - 1, event.doc);
      } else {
        final index = event.newIndex >= length ? length : event.newIndex;
        _snapshots.insert(index, event.doc);
        onDocumentAdded?.call(index, event.doc);
      }
    } catch (error) {
      log("Failed on adding item on index ${event.newIndex}");
    }
  }

  void _onDocumentRemoved(DocumentChange<T> event) {
    try {
      log("Calling _onDocumentRemoved for document on index ${event.oldIndex}");
      final index = _indexForKey(event.doc.id);
      if (index > -1) {
        _snapshots.removeAt(index);
        onDocumentRemoved?.call(index, event.doc);
      } else {
        log("Failed on removing item on index $index");
      }
    } catch (error) {
      log("Failed on removing item on index ${event.oldIndex}");
    }
  }

  void _onDocumentChanged(DocumentChange<T> event) {
    final int index = _indexForKey(event.doc.id);
    if (index > -1) {
      log("Calling _onDocumentChanged for document on index ${event.newIndex}");
      _snapshots[index] = event.doc;
      onDocumentChanged?.call(index, event.doc);
    }
  }

  DocumentSnapshot<T> _onValue(DocumentSnapshot<T> document) {
    log("Calling onValue for document ${document.id}");
    onValue?.call(document);
    return document;
  }

  void _onError(Exception exception) {
    onError?.call(exception);
    if (debug) debugPrint(exception.toString());
  }
}
