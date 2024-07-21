/**
 * titanium-firebase-firestore
 *
 * Created by Hans Knöchel
 */

#import "FirebaseFirestoreFieldValueProxy.h"
#import "TiModule.h"

@interface FirebaseFirestoreModule : TiModule

/**
 Listens to a document changes. Initially (once) + each time the contents change, an update is fired.
 
 - Parameter collection: The name of the collection.
 - Parameter subcollection: The name of the sub-collection.
 - Parameter document: The name of the document.
 */
- (void)addListener:(id)params;

/**
 Adds a new document to the provided Firestore collection.

 - Parameter callback: The callback to be invoked if either the document was added or an error occurred.
 - Parameter collection: The name of the collection.
 - Parameter data: The data to save in the provided collection.
 */
- (void)addDocument:(id)params;

/**
 Returns a list of documents saved in the provided Firestore collection. Different to `getDocuments`, you can also pass
 filteres here.
 */
- (void)queryDocuments:(id)params;

/**
 Returns a list of documents saved in the provided Firestore collection.

 - Parameter callback: The callback to be invoked if either the documents were fetched or an error occurred.
 - Parameter collection: The name of the collection.
 */
- (void)getDocuments:(id)params;

/**
 Returns a single doc saved in the provided Firestore collection.

 - Parameter callback: The callback to be invoked if either the documents were fetched or an error occurred.
 - Parameter collection: The name of the collection.
 - Parameter document: The name of the document.
 */
- (void)getSingleDocument:(id)params;
- (void)getDocument:(id)params;

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

/**
 Returns a special value  that tells the server to increment the field's current value by the given value.

 - Parameter value: The value to increment.
 */
- (FirebaseFirestoreFieldValueProxy *)increment:(id)value;

@end
