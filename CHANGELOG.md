## [1.25.0] - 2022-10-22

* Updated `firebase_core` to 2.1.0
* Updated `cloud_firestore` to 4.0.2

## [1.24.0] - 2022-07-29

* Updated `firebase_core` to 1.20.0
* Updated `firebase_core_platform_interface` to 4.5.0
* Updated `cloud_firestore` to 3.4.2
* Updated `cloud_firestore_platform_interface` to 5.7.0
* Updated `collection` to 1.16.0

## [1.23.0] - 2022-03-23

* Updated `firebase_core` to 1.13.1
* Updated `firebase_core_platform_interface` to 4.2.5
* Updated `cloud_firestore` to 3.1.10
* Updated `cloud_firestore_platform_interface` to 5.5.1
* Added `<T>` generics support for everything


## [1.22.0] - 2021-11-15

* Updated `firebase_core` to 1.10.0
* Updated `firebase_core_platform_interface` to 4.1.0
* Updated `cloud_firestore` to 3.1.0
* Updated `cloud_firestore_platform_interface` to 5.4.5

## [1.21.0] - 2021-10-18

* Updated `meta` to 1.7.0
* Updated `firebase_core` to 1.7.0
* Updated `firebase_core_platform_interface` to 4.0.1
* Updated `cloud_firestore` to 2.5.3
* Updated `cloud_firestore_platform_interface` to 5.4.1
* Updated `flutter_staggered_grid_view` to 0.4.1
* Updated `collection` to 1.15.0

## [1.20.0] - 2021-04-26

* Updated to null-safety!
* Updated `firebase_core` to 1.1.0
* Updated `cloud_firestore` to 1.0.7

## [1.13.0] - 2021-01-18

* Updated `firebase_core` to 0.7.0
* Updated `cloud_firestore` to 0.16.0

## [1.12.0] - 2020-11-02

* Updated `firebase_core` to 0.5.1
* Updated `cloud_firestore` to 0.14.2
* Updated `dart_sdk` to 2.10+
* Fixed `onError`, now properly shows if `debug: true`
* Fixed `defaultChild` behaviour

## [1.11.0] - 2020-08-19

* Updated `firebase_core` to 0.5.0
* Updated `cloud_firestore` to 0.14.0

## [1.10.0] - 2020-06-15

* **BREAKING CHANGE**: Changed `query` parameter from `Stream<QuerySnapshot>` to the proper `cloud_firestore.Query` type to add support for `didUpdateWidget`; so basically, just remove `.snapshots()`.
* Updated `firebase_core` to 0.4.5
* Updated `cloud_firestore` to 0.13.6

## [1.9.1] - 2020-03-10

* Downgraded `firebase_core` to 0.4.4
* Downgraded `cloud_firestore` to 0.13.4
* Those were causing some [issues](https://github.com/flutter/flutter/issues/35670#issuecomment-592769263) while building, will wait before updating again

## [1.9.0] - 2020-03-09

* Updated `firebase_core` to 0.4.4+2
* Updated `cloud_firestore` to 0.13.4+1
* Added `linear` parameter to everything available, this will change `FirestoreList`'s `onDocumentAdded` call to `.add` instead of `.insert`, which might help if your query doesn't care about order changes

## [1.8.0] - 2020-02-17

* Updated `firebase_core` to 0.4.4
* Updated `cloud_firestore` to 0.13.2+1
* Replaces deprecated method calls in the tests

## [1.7.2] - 2019-09-05

* Added `FirestoreAnimatedGrid` and `FirestoreAnimatedStaggered`!
* Updated `firebase_core` to 0.4.0+9
* Updated `cloud_firestore` to 0.12.9+3
* Added `flutter_staggered_grid_view` on 0.3.0
* Updated `StaggeredTileBuilder` to also have an instance of the referenced `DocumentSnapshot`
* Minor changes to `README.md`!

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
