import 'package:flutter/foundation.dart';

class Country {
  final String name;
  final String capital;
  final String region;
  final int population;
  final List<String> languages;
  final String flag;
  final double? area;

  Country({
    required this.name,
    required this.capital,
    required this.region,
    required this.population,
    required this.languages,
    required this.flag,
    this.area,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing country: ${json['name']}');
    
    // Handle name which can be a string or a map
    String countryName = 'Unknown';
    if (json['name'] is Map) {
      countryName = json['name']['common'] ?? json['name']['official'] ?? 'Unknown';
    } else if (json['name'] is String) {
      countryName = json['name'];
    }
    
    // Handle capital which can be a list or a string
    String capitalCity = 'Unknown';
    if (json['capital'] is List) {
      capitalCity = (json['capital'] as List).isNotEmpty 
          ? (json['capital'] as List).first.toString() 
          : 'Unknown';
    } else if (json['capital'] is String) {
      capitalCity = json['capital'];
    }
    
    // Handle languages which can be a Map or a List
    List<String> languagesList = [];
    if (json['languages'] != null) {
      if (json['languages'] is Map) {
        languagesList = (json['languages'] as Map).values
            .where((value) => value != null)
            .map((value) => value.toString())
            .toList();
      } else if (json['languages'] is List) {
        languagesList = (json['languages'] as List)
            .map((lang) => lang['name']?.toString() ?? '')
            .where((lang) => lang.isNotEmpty)
            .toList();
      }
    }
    
    // Handle flag which can be in different formats
    String flagUrl = '';
    if (json['flags'] != null && json['flags'] is Map) {
      flagUrl = json['flags']['png'] ?? json['flags']['svg'] ?? '';
    } else if (json['flag'] != null) {
      flagUrl = json['flag'].toString();
    }

    return Country(
      name: countryName,
      capital: capitalCity,
      region: json['region']?.toString() ?? 'Unknown',
      population: json['population']?.toInt() ?? 0,
      languages: languagesList,
      flag: flagUrl,
      area: json['area']?.toDouble(),
    );
  }
}
