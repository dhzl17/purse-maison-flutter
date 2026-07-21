import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository<T> {
  FirestoreRepository({
    required String collectionPath,
    required this.fromMap,
    required this.toMap,
    this.orderBy,
  }) : _collection = FirebaseFirestore.instance.collection(collectionPath);

  final CollectionReference<Map<String, dynamic>> _collection;
  final T Function(String id, Map<String, dynamic> data) fromMap;
  final Map<String, dynamic> Function(T item) toMap;
  final String? orderBy;

  Stream<List<T>> watchAll() {
    Query<Map<String, dynamic>> query = _collection;
    if (orderBy != null) query = query.orderBy(orderBy!);
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> add(T item, {String? id}) async {
    if (id != null) {
      await _collection.doc(id).set(toMap(item));
    } else {
      await _collection.add(toMap(item));
    }
  }

  Future<void> update(String id, T item) async {
    await _collection.doc(id).update(toMap(item));
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
