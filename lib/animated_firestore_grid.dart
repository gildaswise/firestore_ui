// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

part 'animated_grid.dart';

typedef Widget FirestoreAnimatedGridItemBuilder<T>(
  BuildContext context,
  DocumentSnapshot<T>? snapshot,
  Animation<double> animation,
  int index,
);

typedef Widget ErrorChildBuilder(Exception exception);

/// An AnimatedList widget that is bound to a query
class FirestoreAnimatedGrid<T> extends StatefulWidget {
  /// Creates a scrolling container that animates items when they are inserted or removed.
  FirestoreAnimatedGrid({
    Key? key,
    required this.query,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.mainAxisSpacing = 4.0,
    this.crossAxisSpacing = 4.0,
    this.childAspectRatio = 1.0,
    this.onLoaded,
    this.filter,
    this.defaultChild,
    this.errorChild,
    this.emptyChild,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.debug = false,
    this.linear = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.duration = const Duration(milliseconds: 300),
  })  : assert(crossAxisCount > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(childAspectRatio > 0),
        super(key: key);

  /// A Firestore query to use to populate the animated list
  final Query<T> query;

  /// Method that gets called once the stream updates with a new QuerySnapshot
  final Function(QuerySnapshot<T>)? onLoaded;

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// Called before any operation with a DocumentSnapshot;
  /// If it returns `true`, then dismisses that DocumentSnapshot from the list
  final FilterCallback<T>? filter;

  /// This will change `onDocumentAdded` call to `.add` instead of `.insert`,
  /// which might help if your query doesn't care about order changes
  final bool linear;

  /// A widget to display while the query is loading. Defaults to a
  /// centered [CircularProgressIndicator];
  final Widget? defaultChild;

  /// A widget to display if an error ocurred. Defaults to a
  /// centered [Icon] with `Icons.error` and the error itsef;
  final ErrorChildBuilder? errorChild;

  /// A widget to display if the query returns empty. Defaults to a
  /// `Container()`;
  final Widget? emptyChild;

  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  ///
  /// The [DocumentSnapshot] parameter indicates the snapshot that should be used
  /// to build the item.
  ///
  /// Implementations of this callback should assume that [AnimatedList.removeItem]
  /// removes an item immediately.
  final FirestoreAnimatedGridItemBuilder<T> itemBuilder;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Allows for debug messages relating to FirestoreList operations
  /// to be shown on your respective IDE's debug console
  final bool debug;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  /// The duration of the insert and remove animation.
  ///
  /// Defaults to const Duration(milliseconds: 300).
  final Duration duration;

  @override
  FirestoreAnimatedGridState<T> createState() =>
      FirestoreAnimatedGridState<T>();
}

class FirestoreAnimatedGridState<T> extends State<FirestoreAnimatedGrid<T>> {
  final GlobalKey<_AnimatedGridState> _animatedListKey =
      GlobalKey<_AnimatedGridState>();
  FirestoreList<T>? _model;
  Exception? _error;
  bool _loaded = false;

  /// Should only be called without setState, inside @override methods here
  _updateModel() {
    _model?.clear();
    _model = FirestoreList<T>(
      query: widget.query,
      onDocumentAdded: _onDocumentAdded,
      onDocumentRemoved: _onDocumentRemoved,
      onDocumentChanged: _onDocumentChanged,
      onLoaded: _onLoaded,
      onValue: _onValue,
      onError: _onError,
      filter: widget.filter,
      linear: widget.linear,
      debug: widget.debug,
    );
  }

  @override
  void initState() {
    _updateModel();
    super.initState();
  }

  @override
  void didUpdateWidget(FirestoreAnimatedGrid<T> oldWidget) {
    if (!DeepCollectionEquality.unordered().equals(
        oldWidget.query.parameters, widget.query.parameters)) _updateModel();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // Cancel the Firebase stream subscriptions
    _model!.clear();
    super.dispose();
  }

  void _onError(Exception exception) {
    if (mounted) {
      setState(() {
        _error = exception;
      });
    }
  }

  void _onDocumentAdded(int index, DocumentSnapshot<T> snapshot) {
    // if (!_loaded) {
    //   return; // AnimatedList is not created yet
    // }
    try {
      if (mounted) {
        setState(() {
          _animatedListKey.currentState
              ?.insertItem(index, duration: widget.duration);
        });
      }
    } catch (error) {
      _model!.log("Failed to run onDocumentAdded");
    }
  }

  void _onDocumentRemoved(int index, DocumentSnapshot<T> snapshot) {
    // The child should have already been removed from the model by now
    assert(!_model!.contains(snapshot));
    if (mounted) {
      try {
        setState(() {
          _animatedListKey.currentState?.removeItem(
            index,
            (BuildContext context, Animation<double> animation) {
              return widget.itemBuilder(context, snapshot, animation, index);
            },
            duration: widget.duration,
          );
        });
      } catch (error) {
        _model!.log("Failed to remove Widget on index $index");
      }
    }
  }

  // No animation, just update contents
  void _onDocumentChanged(int index, DocumentSnapshot<T> snapshot) {
    if (mounted) {
      setState(() {});
    }
  }

  void _onLoaded(QuerySnapshot<T>? querySnapshot) {
    if (mounted && !_loaded) {
      setState(() {
        _loaded = true;
      });
    }
    if (querySnapshot != null) widget.onLoaded?.call(querySnapshot);
  }

  void _onValue(DocumentSnapshot<T> snapshot) {
    _onLoaded(null);
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return widget.itemBuilder(context, _model![index], animation, index);
  }

  @override
  Widget build(BuildContext context) {
    if (_model!.isEmpty) {
      return _loaded
          ? (widget.emptyChild ?? Container())
          : (widget.defaultChild ??
              const Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return widget.errorChild as Widget? ??
          const Center(child: Icon(Icons.error));
    }

    return _AnimatedGrid(
      key: _animatedListKey,
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing,
      childAspectRatio: widget.childAspectRatio,
      crossAxisSpacing: widget.crossAxisSpacing,
      itemBuilder: _buildItem,
      initialItemCount: _model!.length,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
    );
  }
}
