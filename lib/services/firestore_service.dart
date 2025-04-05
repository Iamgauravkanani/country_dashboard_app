import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCustomCountry(Map<String, dynamic> countryData) async {
    await _firestore.collection('custom_countries').add(countryData);
  }

  Future<void> updateCustomCountry(String id, Map<String, dynamic> countryData) async {
    await _firestore.collection('custom_countries').doc(id).update(countryData);
  }

  Future<void> deleteCustomCountry(String id) async {
    await _firestore.collection('custom_countries').doc(id).delete();
  }

  Stream<QuerySnapshot> getCustomCountries() {
    return _firestore.collection('custom_countries').snapshots();
  }
}
