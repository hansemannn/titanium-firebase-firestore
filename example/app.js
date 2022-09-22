import TiFirebaseCore from 'firebase.core';
import TiFirestore from 'firebase.firestore';


const window = Ti.UI.createWindow();
window.addEventListener('open', () => {
    TiFirebaseCore.configure();
});

const btn = Ti.UI.createButton({ title: 'Perform CRUD!' });
btn.addEventListener('singletap', performCRUD);

window.add(btn);
window.open();

function performCRUD() {
    let documentID;

    console.warn('Saving to Firestore …');
    TiFirestore.addDocument({
        collection: 'users',
        data: { firstName: 'Hans' },
        callback: event => {

            if (!event.success) {
                console.error('Could not save in Firestore:', event.error);
                return;
            }

            documentID = event.documentID;
            console.warn('Saved to Firestore successfully! Document path: ', documentID);

            TiFirestore.updateDocument({
                collection: 'users',
                document: documentID,
                data: { firstName: 'John', lastName: 'Doe' },
                callback: event => {
                    if (!event.success) {
                        console.error('Could not update in Firestore:', event.error);
                        return;
                    }

                    console.warn('Updated in Firestore successfully!');

                    TiFirestore.getDocuments({
                        collection: 'users',
                        callback: event => {
                            if (!event.success) {
                                console.error('Could not read Firestore:', event.error);
                                return;
                            }
        
                            console.warn('Received data from Firestore successfully:');
                            console.warn(JSON.stringify(event.documents, null, 4));

                            TiFirestore.deleteDocument({
                                collection: 'users',
                                document: documentID,
                                callback: event => {
                                    if (!event.success) {
                                        console.error('Could not delete in Firestore:', event.error);
                                        return;
                                    }

                                    console.warn('Document deleted successfully! CRUD test finished!');
                                }
                            });
                        }
                    });
                }
            });
        }
    });
}