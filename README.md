# Firebase Firestore - Titanium Module

Use the native Firebase SDK in Titanium. This repository is part of the [Titanium Firebase](https://github.com/hansemannn/titanium-firebase) project.

## Methods:

* addDocument({callback[function], collection[string], data[object]})
* addDocument({callback[function], collection[string], document[string], data[object]}) <i>Android only</i>
* getDocuments({callback[function], collection[string])
* getDocument({callback[function], collection[string], document[string]) <i>Andorid only</i>
* updateDocument({callback[function], collection[string], document[string], data[object]})
* deleteDocument({callback[function], collection[string], document[string]})

## Supporting this effort

The whole Firebase support in Titanium is developed and maintained by the community (`@hansemannn` and `@m1ga`). To keep
this project maintained and be able to use the latest Firebase SDK's, please see the "Sponsor" button of this repository,
thank you!

## Requirements

-   [x] The [Firebase Core](https://github.com/hansemannn/titanium-firebase-core) module
-   [x] Titanium SDK 9.2.0+

## Example

See the [example/app.js](./example/app.js) for details!

## Build

```js
cd ios
ti build -p ios --build-only
```

## Author

Hans Knöchel

## Legal

This module is Copyright (c) 2022-present by Hans Knöchel, Inc. All Rights Reserved.
