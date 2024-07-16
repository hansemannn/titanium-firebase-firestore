package firebase.firestore

import com.google.firebase.Timestamp
import com.google.firebase.firestore.DocumentReference
import com.google.firebase.firestore.ListenerRegistration
import org.appcelerator.kroll.KrollDict
import org.appcelerator.kroll.KrollFunction
import org.appcelerator.kroll.KrollProxy
import org.appcelerator.kroll.annotations.Kroll
import org.appcelerator.kroll.common.TiConfig

@Kroll.proxy(creatableInModule = TitaniumFirebaseFirestoreModule::class)
class FirebaseDocumentProxy(param: DocumentReference, doc: String, col: String) : KrollProxy() {
    init {
        docRef = param
        docName = doc
        colName = col
    }

    companion object {
        private const val LCAT = "DocumentProxy"
        private val DBG = TiConfig.LOGD
        private lateinit var docRef: DocumentReference
        private lateinit var docName: String
        private lateinit var colName: String
        private lateinit var realtimeListener: ListenerRegistration
    }

    @Kroll.method
    fun update(params: KrollDict) {
        val callback = params["callback"] as KrollFunction
        val data = params.getKrollDict("data")

        docRef
            .update(data)
            .addOnSuccessListener {
                val event = KrollDict()
                event["success"] = true

                callback.callAsync(getKrollObject(), event)
            }
            .addOnFailureListener { error ->
                val event = KrollDict()
                event["success"] = false
                event["error"] = error.localizedMessage

                callback.callAsync(getKrollObject(), event)
            }
    }

    @Kroll.method
    fun deleteDocument(params: KrollDict) {
        val callback = params["callback"] as KrollFunction

        docRef.delete()
            .addOnSuccessListener {
                val event = KrollDict()
                event["success"] = true

                callback.callAsync(getKrollObject(), event)
            }
            .addOnFailureListener { error ->
                val event = KrollDict()
                event["success"] = false
                event["error"] = error.localizedMessage

                callback.callAsync(getKrollObject(), event)
            }
    }

    @Kroll.method
    fun get(params: KrollDict) {
        val callback = params["callback"] as KrollFunction
        docRef.get()
            .addOnSuccessListener { it ->

                val event = KrollDict()
                if (it != null && it.data != null) {
                    val d = KrollDict()

                    // map entries
                    it.data!!.toMap().forEach {
                        if ((it.value is Timestamp)) {
                            val ts: Timestamp = it.value as Timestamp
                            d[it.key] = ts.seconds
                        } else if (it.value is ArrayList<*>) {
                            val convertedList = mutableListOf<Any>()
                            for (item in it.value as ArrayList<*>) {
                                if (item is Map<*, *>) {
                                    convertedList.add(item.toMutableMap())
                                } else {
                                    // Convert any ArrayList<*> elements to a JavaScript array
                                    convertedList.add(
                                        (item as? ArrayList<*>)?.toTypedArray() ?: item
                                    )
                                }
                            }
                            d[it.key] = convertedList.toTypedArray()
                        } else {
                            d[it.key] = it.value
                        }
                    }

                    d["_id"] = it.id
                    event["document"] = d
                } else {
                    event["document"] = ""
                }

                event["success"] = true

                callback.callAsync(getKrollObject(), event)
            }
            .addOnFailureListener { error ->
                val event = KrollDict()
                event["success"] = false
                event["error"] = error.localizedMessage

                callback.callAsync(getKrollObject(), event)
            }
    }

    @Kroll.method
    fun addRealtimeEvents() {
        realtimeListener = docRef.addSnapshotListener { snapshot, e ->
            if (e != null) {
                return@addSnapshotListener
            }

            if (snapshot != null && snapshot.exists()) {

                val kd = KrollDict()
                snapshot.data!!.toMap().forEach {
                    if ((it.value is Timestamp)) {
                        val ts: Timestamp = it.value as Timestamp
                        kd[it.key] = ts.seconds
                    }  else if (it.value is ArrayList<*>) {
                        val convertedList = mutableListOf<Any>()
                        for (item in it.value as ArrayList<*>) {
                            if (item is Map<*, *>) {
                                convertedList.add(item.toMutableMap())
                            } else {
                                // Convert any ArrayList<*> elements to a JavaScript array
                                convertedList.add(
                                    (item as? ArrayList<*>)?.toTypedArray() ?: item
                                )
                            }
                        }
                        kd[it.key] = convertedList.toTypedArray()
                    } else {
                        kd[it.key] = it.value
                    }
                }
                kd["document"] = docName
                kd["collection"] = colName
                fireEvent("change", kd)
            } else {
                // null
            }
        }
    }

    @Kroll.method
    fun removeRealtimeEvents() {
        realtimeListener.remove()
    }
}