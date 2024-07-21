//
//  TiFirestoreUtils.m
//  titanium-firebase-firestore
//
//  Created by Hans Knöchel on 06.12.22.
//

#import "TiFirestoreUtils.h"
#import <FirebaseFirestore/FirebaseFirestore.h>

@implementation TiFirestoreUtils

+ (NSDictionary *)mappedFirestoreDocument:(FIRDocumentSnapshot *)document
{
  NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:@{ @"_id": document.documentID }];

  [document.data enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull value, BOOL *_Nonnull stop) {
    // Handle timestamps as a native type
    if ([value isKindOfClass:[FIRTimestamp class]]) {
      FIRTimestamp *timestamp = (FIRTimestamp *)value;
      result[key] = timestamp.dateValue;
      // Handle nested objects
    } else if ([value isKindOfClass:[FIRGeoPoint class]]) {
      FIRGeoPoint *geoPoint = (FIRGeoPoint *)value;
      result[key] = @{ @"latitude": @(geoPoint.latitude), @"longitude": @(geoPoint.longitude) };
      // Handle all other values directly
    } else {
      result[key] = value;
    }
  }];

  return result;
}

@end
