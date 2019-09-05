## [1.7.0] - 2019-09-05

* Added `FirestoreAnimatedGrid` and `FirestoreAnimatedStaggered`!
* Updated `firebase_core` to 0.4.0+9
* Updated `cloud_firestore` to 0.12.9+3
* Added `flutter_staggered_grid_view` on 0.3.0

## [1.6.0] - 2019-06-04

* Updates to the `filter` mechanism, it would hide items due to an index mismanagement
* Updated cloud_firestore to 0.12.2

## [1.5.0] - 2019-05-09

* Added `filter` parameter that takes out data if it returns true for that `DocumentSnapshot`
* Updated cloud_firestore to 0.12.0

## [1.4.0] - 2019-05-09

* Changed dependency requirements

## [1.3.0] - 2019-04-30

* Added `onLoaded` method for when you need to interact directly with the `QuerySnapshot` that came from the stream
* Bump cloud_firestore dependency version to 0.10.0

## [1.2.0] - 2019-02-08

* Bump cloud_firestore dependency version to 0.9.0

## [1.1.1] - 2019-01-14

* Updated `setState` calls, should be faster to show values

## [1.1.0] - 2019-01-03

* Added onLoaded callback to FirestoreList
* Fixed flashing of `emptyChild` when setted
* Minor general fixes, better debugging if `debug` is set true

## [1.0.1] - 2018-10-09

* Fixed some errors on the README and package description

## [1.0.0] - 2018-10-09

* Initial release, coming from [cloud_firestore](https://github.com/flutter/plugins/pull/757)'s pull request #757
