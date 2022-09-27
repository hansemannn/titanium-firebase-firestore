/**
 * Axway Titanium
 * Copyright (c) 2009-present by Axway Appcelerator. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"
#import <FirebaseFirestore/FirebaseFirestore.h>

@interface FirebaseFirestoreFieldValueProxy : TiProxy {
  FIRFieldValue *_fieldValue;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andFieldValue:(FIRFieldValue *)fieldValue;

- (FIRFieldValue *)fieldValue;

@end
