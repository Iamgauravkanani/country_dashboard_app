import 'package:cloud_firestore/cloud_firestore.dart';

class CustomCountry {
  final String id;
  final String name;
  final String capital;
  final String region;
  final int population;

  CustomCountry({
    required this.id,
    required this.name,
    required this.capital,
    required this.region,
    required this.population,
  });

  factory CustomCountry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CustomCountry(
      id: doc.id,
      name: data['name'] ?? '',
      capital: data['capital'] ?? '',
      region: data['region'] ?? '',
      population: data['population'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'capital': capital, 'region': region, 'population': population};
  }
}
