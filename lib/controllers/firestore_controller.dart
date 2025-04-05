import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/custom_country_model.dart';
import 'package:flutter/material.dart';

class FirestoreController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<CustomCountry> customCountries = <CustomCountry>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  Stream<QuerySnapshot>? _countriesStream;

  @override
  void onInit() {
    super.onInit();
    setupCountriesStream();
    // Also fetch initial data
    fetchInitialCountries();
  }

  void setupCountriesStream() {
    try {
      print('Setting up countries stream...');
      _countriesStream = _firestore
          .collection('custom_countries')
          .orderBy('name')
          .snapshots()
          .handleError((error) {
            print('Stream error: $error');
            this.error.value = 'Error fetching countries: ${error.toString()}';
            Get.snackbar(
              'Error',
              this.error.value,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error,
              colorText: Colors.white,
            );
            return Stream.empty();
          });
      
      // Add a listener to debug the stream
      _countriesStream?.listen(
        (snapshot) {
          print('Received ${snapshot.docs.length} countries from Firestore');
          if (snapshot.docs.isEmpty) {
            print('No countries found in Firestore');
          } else {
            print('First country: ${snapshot.docs.first.data()}');
          }
          
          // Update the customCountries list
          customCountries.value = snapshot.docs
              .map((doc) => CustomCountry.fromFirestore(doc))
              .toList();
        },
        onError: (error) {
          print('Stream listener error: $error');
        },
      );
    } catch (e) {
      print('Exception in setupCountriesStream: $e');
      error.value = 'Failed to setup stream: ${e.toString()}';
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    }
  }

  // Fetch initial data to ensure we have data even if stream fails
  Future<void> fetchInitialCountries() async {
    try {
      print('Fetching initial countries...');
      isLoading.value = true;
      
      final snapshot = await _firestore
          .collection('custom_countries')
          .orderBy('name')
          .get();
      
      print('Fetched ${snapshot.docs.length} countries initially');
      
      customCountries.value = snapshot.docs
          .map((doc) => CustomCountry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching initial countries: $e');
      error.value = 'Failed to fetch initial countries: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Stream<QuerySnapshot> get countriesStream {
    if (_countriesStream == null) {
      setupCountriesStream();
    }
    return _countriesStream!;
  }

  Future<void> addCountry(CustomCountry country) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Validate the country data
      if (country.name.isEmpty || country.capital.isEmpty || country.region.isEmpty) {
        throw Exception('Please fill in all required fields');
      }

      // Check if country with same name already exists
      final existingDocs = await _firestore
          .collection('custom_countries')
          .where('name', isEqualTo: country.name)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        throw Exception('A country with this name already exists');
      }

      print('Adding country to Firestore: ${country.toMap()}');
      final docRef = await _firestore.collection('custom_countries').add(country.toMap());
      print('Country added with ID: ${docRef.id}');
      
      // Don't add to local list - the stream will update it automatically
      
      Get.snackbar(
        'Success',
        'Country added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding country: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add country: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCountry(String id, CustomCountry country) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Validate the country data
      if (country.name.isEmpty || country.capital.isEmpty || country.region.isEmpty) {
        throw Exception('Please fill in all required fields');
      }

      // Check if another country with same name exists
      final existingDocs = await _firestore
          .collection('custom_countries')
          .where('name', isEqualTo: country.name)
          .where(FieldPath.documentId, isNotEqualTo: id)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        throw Exception('Another country with this name already exists');
      }

      print('Updating country with ID $id: ${country.toMap()}');
      await _firestore.collection('custom_countries').doc(id).update(country.toMap());
      print('Country updated successfully');
      
      // Update local list immediately
      final index = customCountries.indexWhere((c) => c.id == id);
      if (index != -1) {
        customCountries[index] = CustomCountry(
          id: id,
          name: country.name,
          capital: country.capital,
          region: country.region,
          population: country.population,
        );
      }
      
      Get.snackbar(
        'Success',
        'Country updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating country: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update country: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCountry(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      print('Deleting country with ID: $id');
      await _firestore.collection('custom_countries').doc(id).delete();
      print('Country deleted successfully');
      
      // Remove from local list immediately
      customCountries.removeWhere((c) => c.id == id);
      
      Get.snackbar(
        'Success',
        'Country deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting country: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete country: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
