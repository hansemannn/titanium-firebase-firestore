/**
 * titanium-firebase-firestore
 *
 * Created by Hans Knöchel
 */

#import "TiModule.h"

@interface FirebaseFirestoreModule : TiModule

/**
 Adds a new document to the provided Firestore collection.
 
 - Parameter callback: The callback to be invoked if either the document was added or an error occurred.
 - Parameter collection: The name of the collection.
 - Parameter data: The data to save in the provided collection.
 */
- (void)addDocument:(id)params;

/**
 Returns a list of documents saved in the provided Firestore collection.
 
 - Parameter callback: The callback to be invoked if either the documents were fetched or an error occurred.
 - Parameter collection: The name of the collection.
 */
- (void)getDocuments:(id)params;

/**
 Updates an extisting document from the provided Firestore collection.
 
 - Parameter callback: The callback to be invoked if either the document was updated or an error occurred.
 - Parameter collection: The name of the collection.
 - Parameter data: The data to update in the provided collection.
 - Parameter document: The document to update.
 */
- (void)updateDocument:(id)params;

/**
 Removes a new document from the provided Firestore collection.
 
 - Parameter callback: The callback to be invoked if either the document was removed or an error occurred.
 - Parameter collection: The name of the collection.
 - Parameter document: The document to delete.
 */
- (void)deleteDocument:(id)params;

@end
