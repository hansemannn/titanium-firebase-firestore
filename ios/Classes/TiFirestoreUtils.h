//
//  TiFirestoreUtils.h
//  titanium-firebase-firestore
//
//  Created by Hans Knöchel on 06.12.22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TiFirestoreUtils : NSObject

+ (NSDictionary *)mappedFirestoreValue:(id)value;

@end

NS_ASSUME_NONNULL_END
