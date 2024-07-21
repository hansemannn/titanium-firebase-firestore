/**
 * titanium-firebase-firestore
 *
 * Created by Hans Knöchel
 */

#import "FirebaseFirestoreModule.h"
#import "TiBase.h"
#import "TiFirestoreUtils.h"
#import "TiHost.h"
#import "TiUtils.h"

#import <FirebaseFirestore/FirebaseFirestore.h>

@implementation FirebaseFirestoreModule

#pragma mark Internal

- (id)moduleGUID
{
  return @"01ba870c-6842-4b23-a8db-eb1eaffebf3f";
}

- (NSString *)moduleId
{
  return @"firebase.firestore";
}

- (void)addListener:(id)params
{
  ENSURE_SINGLE_ARG(params, NSDictionary);

  NSString *collection = params[@"collection"];
  NSString *subcollection = params[@"subcollection"];
  NSString *document = params[@"document"];

  FIRCollectionReference *fireCollection = [FIRFirestore.firestore collectionWithPath:collection];
  
  if (subcollection != nil && document != nil) {
    fireCollection = [[fireCollection documentWithPath:document] collectionWithPath:subcollection];
  }

  [fireCollection addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
    if (snapshot == nil) {
      return;
    }
    
    NSMutableArray<NSDictionary<NSString *, id> *> *documents = [NSMutableArray arrayWithCapacity:snapshot.documentChanges.count];

    for (FIRDocumentChange *documentChange in snapshot.documentChanges) {
      [documents addObject:@{
        @"document": documentChange.document.documentID,
        @"items": [TiFirestoreUtils mappedFirestoreDocument:documentChange.document]
      }];
    }
    
    [self fireEvent:@"change" withObject:@{ @"documents": documents, @"collection": collection }];
  }];
}

- (void)addDocument:(id)params
{
  ENSURE_SINGLE_ARG(params, NSDictionary);

  KrollCallback *callback = params[@"callback"];
  NSString *collection = params[@"collection"];
  NSString *document = params[@"document"];
  NSDictionary *data = params[@"data"]; // TODO: Parse "FIRFieldValue" proxy types

  if (document != nil) {
      [[[FIRFirestore.firestore collectionWithPath:collection]  documentWithPath:document] setData:data
                                                                                        completion:^(NSError * _Nullable error) {
        if (error != nil) {
          [callback call:@[@{ @"success": @(NO), @"error": error.localizedDescription }] thisObject:self];
          return;
        }
        
        [callback call:@[@{ @"success": @(YES), @"documentID": document, @"documentPath": document }] thisObject:self];
      }];
  } else {
    __block FIRDocumentReference *ref = [[FIRFirestore.firestore collectionWithPath:collection] addDocumentWithData:data
                                                                                                         completion:^(NSError * _Nullable error) {
      if (error != nil) {
        [callback call:@[@{ @"success": @(NO), @"error": error.localizedDescription }] thisObject:self];
        return;
      }
      
      [callback call:@[@{ @"success": @(YES), @"documentID": NULL_IF_NIL(ref.documentID), @"documentPath": NULL_IF_NIL(ref.path) }] thisObject:self];
    }];
  }
}

- (void)queryDocuments:(id)params
{
    ENSURE_SINGLE_ARG(params, NSDictionary);
    KrollCallback *callback = params[@"callback"];
    NSString *collection = params[@"collection"];
    NSString *document = params[@"document"];
    
    FIRCollectionReference *ref = [FIRFirestore.firestore collectionWithPath:collection];
    FIRDocumentReference *documentReference = [[FIRFirestore.firestore collectionWithPath:collection] documentWithPath:document];
    FIRQuery *query = [FIRFirestore.firestore collectionWithPath:params[@"path"]];
    
    NSDictionary *parameters = params[@"parameters"];
    NSArray *whereConditions = params[@"where"];
    
    for (id item in whereConditions) {
        NSArray *condition = item;
        NSString *fieldName = condition[0];
        NSString *op = condition[1];
        id value = condition[2];
        if ([op isEqualToString:@"=="]) {
            query = [query queryWhereField:fieldName isEqualTo:value];
        } else if ([op isEqualToString:@"<"]) {
            query = [query queryWhereField:fieldName isLessThan:value];
        } else if ([op isEqualToString:@"<="]) {
            query = [query queryWhereField:fieldName isLessThanOrEqualTo:value];
        } else if ([op isEqualToString:@">"]) {
            query = [query queryWhereField:fieldName isGreaterThan:value];
        } else if ([op isEqualToString:@">="]) {
            query = [query queryWhereField:fieldName isGreaterThanOrEqualTo:value];
        } else if ([op isEqualToString:@"array-contains"]) {
            query = [query queryWhereField:fieldName arrayContains:value];
        } else {
            NSLog(@"[ERROR] Unhandled operator \"%@\" on field \"%@\"", op, fieldName);
            // Unsupported operator
        }
    }
    
    id limit = parameters[@"limit"];
    if (limit) {
        NSNumber *length = limit;
        query = [query queryLimitedTo:[length intValue]];
    }
    
    NSArray *orderBy = parameters[@"orderBy"];
    if (orderBy) {
        for (id item in orderBy) {
            NSArray *orderByParameters = item;
            NSString *fieldName = orderByParameters[0];
            NSNumber *descending = orderByParameters[1];
            query = [query queryOrderedByField:fieldName descending:[descending boolValue]];
        }
    }
    
    id startAt = parameters[@"startAt"];
    if (startAt) {
        NSArray *startAtValues = startAt;
        query = [query queryStartingAtValues:startAtValues];
    }
    
    id startAfter = parameters[@"startAfter"];
    if (startAfter) {
        NSArray *startAfterValues = startAfter;
        query = [query queryStartingAfterValues:startAfterValues];
    }
    
    id endAt = parameters[@"endAt"];
    if (endAt) {
        NSArray *endAtValues = endAt;
        query = [query queryEndingAtValues:endAtValues];
    }
    
    id endBefore = parameters[@"endBefore"];
    if (endBefore) {
        NSArray *endBeforeValues = endBefore;
        query = [query queryEndingBeforeValues:endBeforeValues];
    }
    
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
        if (error != nil) {
            [callback call:@[ @{
                                  @"success" : @(NO),
                                  @"error" : error.localizedDescription
                                  } ]
                thisObject:self];
            return;
        }
        
        NSMutableArray<NSDictionary<NSString *, id> *> *documents = [NSMutableArray arrayWithCapacity:snapshot.documents.count];
        
        // Map the documents to make sure it's a bridgeable type
        [snapshot.documents enumerateObjectsUsingBlock:^(FIRQueryDocumentSnapshot *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [documents addObject:[TiFirestoreUtils mappedFirestoreDocument:obj]];
        }];
        [callback call:@[ @{
                              @"success" : @(YES),
                              @"documents" : documents
                              } ]
            thisObject:self];
    }];
}

- (void)getDocuments:(id)params
{
  ENSURE_SINGLE_ARG(params, NSDictionary);

  KrollCallback *callback = params[@"callback"];
  NSString *collection = params[@"collection"];
  
  if ([TiUtils boolValue:@"addListeners" properties:params def:NO]) {
    [self addListener:params];
  }

  [[FIRFirestore.firestore collectionWithPath:collection] getDocumentsWithCompletion:^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
    if (error != nil) {
      [callback call:@[ @{@"success" : @(NO),
        @"error" : error.localizedDescription} ]
          thisObject:self];
      return;
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *documents = [NSMutableArray arrayWithCapacity:snapshot.documents.count];

    [snapshot.documents enumerateObjectsUsingBlock:^(FIRQueryDocumentSnapshot *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      [documents addObject:[TiFirestoreUtils mappedFirestoreDocument:obj]];
    }];

    [callback call:@[ @{@"success" : @(YES),
      @"documents" : documents} ]
        thisObject:self];
  }];
}

- (void)getSingleDocument:(id)params
{
  ENSURE_SINGLE_ARG(params, NSDictionary);

  KrollCallback *callback = params[@"callback"];
  NSString *collection = params[@"collection"];
  NSString *document = params[@"document"];

  FIRDocumentReference *documentReference = [[FIRFirestore.firestore collectionWithPath:collection] documentWithPath:document];

  [documentReference getDocumentWithCompletion:^(FIRDocumentSnapshot *_Nullable snapshot, NSError *_Nullable error) {
    if (error != nil) {
      [callback call:@[ @{@"success" : @(NO),
        @"error" : error.localizedDescription} ]
          thisObject:self];
      return;
    }

    if ([snapshot data] != nil) {
      [callback call:@[@{ @"success": @(YES), @"document": [TiFirestoreUtils mappedFirestoreDocument:snapshot] }] thisObject:self];
    } else {
      [callback call:@[@{ @"success": @(YES) }] thisObject:self];
    }
  }];
}

- (void)getDocument:(id)params
{
  [self getSingleDocument:params];
}

- (void)updateDocument:(id)params
{
  ENSURE_SINGLE_ARG(params, NSDictionary);
  
  KrollCallback *callback = params[@"callback"];
  NSString *collection = params[@"collection"];
  NSDictionary *data = params[@"data"]; // TODO: Parse "FIRFieldValue" proxy types
  NSString *document = params[@"document"];

  [[[FIRFirestore.firestore collectionWithPath:collection] documentWithPath:document] updateData:data
                                                                                      completion:^(NSError *_Nullable error) {
                                                                                        if (error != nil) {
                                                                                          [callback call:@[ @{@"success" : @(NO),
                                                                                            @"error" : error.localizedDescription} ]
                                                                                              thisObject:self];
                                                                                          return;
                                                                                        }

                                                                                        [callback call:@[ @{@"success" : @(YES)} ] thisObject:self];
                                                                                      }];
}

- (void)deleteDocument:(id)params
{
  ENSURE_SINGLE_ARG(params, NSDictionary);

  KrollCallback *callback = params[@"callback"];
  NSString *collection = params[@"collection"];
  NSDictionary *data = params[@"data"];
  NSString *document = params[@"document"];

  [[[FIRFirestore.firestore collectionWithPath:collection] documentWithPath:document] deleteDocumentWithCompletion:^(NSError *_Nullable error) {
    if (error != nil) {
      [callback call:@[ @{@"success" : @(NO),
        @"error" : error.localizedDescription} ]
          thisObject:self];
      return;
    }

    [callback call:@[ @{@"success" : @(YES)} ] thisObject:self];
  }];
}

- (FirebaseFirestoreFieldValueProxy *)increment:(id)value
{
  ENSURE_SINGLE_ARG(value, NSNumber);

  FIRFieldValue *fieldValue = [FIRFieldValue fieldValueForIntegerIncrement:[TiUtils intValue:value]];
  return [[FirebaseFirestoreFieldValueProxy alloc] _initWithPageContext:pageContext andFieldValue:fieldValue];
}

@end
