import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'dart:convert';

import '../model/country_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://restcountries.com/v3.1';
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 2);
  // final Connectivity _connectivity = Connectivity();

  ApiService() {
    // Configure Dio with optimized settings
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60), // Increased for large responses
      sendTimeout: const Duration(seconds: 30),
      followRedirects: true,
      maxRedirects: 5,
      receiveDataWhenStatusError: true,
      headers: {'Accept': 'application/json', 'Accept-Encoding': 'gzip', 'User-Agent': 'CountryDashboard/1.0'},
    );

    // Add transformer for better large response handling
    _dio.transformer = BackgroundTransformer()..jsonDecodeCallback = parseJson;

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('🌐 Sending request to ${options.uri}');
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          debugPrint('❌ Dio error: ${e.type} - ${e.message}');
          debugPrint('📡 Response: ${e.response?.statusCode} - ${e.response?.data}');

          if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
            debugPrint('⏳ Adding small delay before retry...');
            await Future.delayed(const Duration(milliseconds: 500));
          }

          return handler.next(e);
        },
      ),
    );
  }

  // Custom JSON parser to handle large responses
  static dynamic parseJson(String text) {
    return compute(_parseAndDecode, text);
  }

  static dynamic _parseAndDecode(String response) {
    return jsonDecode(response);
  }

  Future<List<Country>> getCountries({int page = 1, int limit = 20}) async {
    int retryCount = 0;

    // Check connectivity first
    // final connectivityResult = await _connectivity.checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    //   throw Exception('No internet connection');
    // }

    while (retryCount < _maxRetries) {
      try {
        debugPrint('🔍 Fetching countries (attempt ${retryCount + 1}/$_maxRetries)');

        // Request only needed fields to reduce payload size
        final response = await _dio.get(
          '$_baseUrl/all?fields=name,flags,capital,population,region,cca2',
          options: Options(validateStatus: (status) => status! < 500),
        );

        if (response.statusCode != 200) {
          debugPrint('❌ API error: ${response.statusCode} - ${response.statusMessage}');
          throw Exception('API returned status code ${response.statusCode}');
        }

        List<dynamic> data = response.data;
        debugPrint('✅ Received ${data.length} countries (${response.data.toString().length} bytes)');

        // Implement pagination
        int start = (page - 1) * limit;
        if (start >= data.length) {
          debugPrint('⚠️ No more countries to fetch (start: $start, total: ${data.length})');
          return [];
        }

        int end = start + limit;
        end = end > data.length ? data.length : end;

        debugPrint('📊 Processing countries $start to $end');

        final countries = await compute(_parseCountries, data.sublist(start, end));

        debugPrint('🎉 Successfully parsed ${countries.length} countries');
        return countries;
      } on DioException catch (e) {
        retryCount++;
        debugPrint('⚠️ Attempt $retryCount failed: ${e.message}');

        if (retryCount >= _maxRetries) {
          debugPrint('❌ Max retries reached. Trying fallback API...');
          return await getCountriesFallback(page: page, limit: limit);
        }

        debugPrint('⏳ Retrying in ${_retryDelay.inSeconds}s...');
        await Future.delayed(_retryDelay);
      } catch (e) {
        debugPrint('❌ Unexpected error: $e');
        rethrow;
      }
    }

    throw Exception('Failed to load countries after $_maxRetries attempts');
  }

  // Helper function to parse countries in isolate
  static List<Country> _parseCountries(List<dynamic> countryData) {
    return countryData
        .map((json) {
          try {
            return Country.fromJson(json);
          } catch (e) {
            debugPrint('❌ Error parsing country: $e\nJSON: $json');
            return null;
          }
        })
        .whereType<Country>()
        .toList();
  }

  // Fallback method with improved error handling
  Future<List<Country>> getCountriesFallback({int page = 1, int limit = 20}) async {
    try {
      debugPrint('🔄 Trying fallback API endpoint (v2)');
      final response = await _dio.get(
        'https://restcountries.com/v2/all?fields=name,flags,capital,population,region,alpha2Code',
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode != 200) {
        throw Exception('Fallback API returned status code ${response.statusCode}');
      }

      List<dynamic> data = response.data;
      debugPrint('📥 Received ${data.length} countries from fallback API');

      int start = (page - 1) * limit;
      if (start >= data.length) return [];

      int end = start + limit;
      end = end > data.length ? data.length : end;

      return await compute(_parseCountries, data.sublist(start, end));
    } catch (e) {
      debugPrint('❌ Fallback API failed: $e');
      throw Exception('Failed to load countries from fallback API: $e');
    }
  }
}
