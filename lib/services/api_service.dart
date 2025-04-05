import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../model/country_model.dart';

class ApiService {
  final Dio _dio = Dio();
  // Using the correct API endpoint
  final String _baseUrl = 'https://restcountries.com/v3.1';
  final int _maxRetries = 3;
  final Duration _retryDelay = Duration(seconds: 2);

  ApiService() {
    // Configure Dio with better timeout settings
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    _dio.options.sendTimeout = Duration(seconds: 30);
    
    // Add interceptors for better error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        debugPrint('Dio error: ${e.type} - ${e.message}');
        return handler.next(e);
      },
    ));
  }

  Future<List<Country>> getCountries({int page = 1, int limit = 20}) async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries) {
      try {
        debugPrint('🔍 Fetching countries from API: $_baseUrl/all (attempt ${retryCount + 1})');
        
        // Use the correct endpoint
        String endpoint = '$_baseUrl/all';
            
        debugPrint('🔗 Complete API URL: $endpoint');
        debugPrint('📝 Request Headers: ${_dio.options.headers}');
            
        final response = await _dio.get(
          endpoint,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'CountryDashboard/1.0',
            },
            validateStatus: (status) => status! < 500,
          ),
        );
        
        if (response.statusCode != 200) {
          debugPrint('❌ API error: ${response.statusCode} - ${response.statusMessage}');
          throw Exception('API returned status code ${response.statusCode}');
        }
        
        List<dynamic> data = response.data;
        debugPrint('✅ Received ${data.length} countries from API');

        int start = (page - 1) * limit;
        if (start >= data.length) {
          debugPrint('⚠️ No more countries to fetch (start: $start, total: ${data.length})');
          return [];
        }

        int end = start + limit;
        end = end > data.length ? data.length : end;
        
        debugPrint('📊 Processing countries from index $start to $end');
        
        final countries = data.sublist(start, end).map((json) {
          try {
            return Country.fromJson(json);
          } catch (e) {
            debugPrint('❌ Error parsing country: $e\nJSON: $json');
            return null;
          }
        }).whereType<Country>().toList();
        
        debugPrint('✅ Returning ${countries.length} countries for page $page');
        return countries;
      } catch (e) {
        retryCount++;
        debugPrint('❌ API error (attempt $retryCount): $e');
        
        if (retryCount >= _maxRetries) {
          debugPrint('❌ Max retries reached. Giving up.');
          throw Exception('Failed to load countries after $_maxRetries attempts: $e');
        }
        
        debugPrint('⏳ Retrying in ${_retryDelay.inSeconds} seconds...');
        await Future.delayed(_retryDelay);
      }
    }
    
    throw Exception('Failed to load countries: Unknown error');
  }
  
  // Fallback method to get countries from a different endpoint
  Future<List<Country>> getCountriesFallback({int page = 1, int limit = 20}) async {
    try {
      debugPrint('Using fallback API endpoint');
      final response = await _dio.get(
        'https://restcountries.com/v2/all',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'CountryDashboard/1.0',
          },
        ),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Fallback API returned status code ${response.statusCode}');
      }
      
      List<dynamic> data = response.data;
      debugPrint('Received ${data.length} countries from fallback API');
      
      // Implement pagination
      int start = (page - 1) * limit;
      if (start >= data.length) {
        return [];
      }
      
      int end = start + limit;
      end = end > data.length ? data.length : end;
      
      final countries = data.sublist(start, end).map((json) {
        try {
          return Country.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing country from fallback: $e');
          return null;
        }
      }).whereType<Country>().toList();
      
      return countries;
    } catch (e) {
      debugPrint('Fallback API error: $e');
      throw Exception('Failed to load countries from fallback API: $e');
    }
  }
}
