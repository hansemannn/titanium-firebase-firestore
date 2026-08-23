# Vendored headers

This directory contains **public header files only** (no compiled code, no binaries)
copied verbatim from the official [firebase/firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk)
repository at tag `CocoaPods-12.17.0`:

- `FirebaseFirestore/FirebaseFirestore/*.h` — from `Firestore/Source/Public/FirebaseFirestore/`
- `FirebaseCore/FirebaseCore/FIRTimestamp.h` — from `FirebaseCore/Sources/Public/FirebaseCore/`

They exist solely so this module's Objective-C sources can compile against the
Firebase Firestore API surface. The actual implementation is never bundled with
this module — it is resolved via Swift Package Manager directly from Google's
official repository when an app using this module is built (see `../spm.json`).

Xcode links Swift Package Manager package products directly into any target that
declares them as a dependency, including static libraries. Since this module ships
as a static library that must not embed Firebase's implementation itself (that
would duplicate symbols with the app-level SPM resolution), the package can't be
added to this project directly. These headers are the workaround: they satisfy the
compiler without providing any implementation.

To refresh after a version bump, re-fetch the same files from the new tag.
