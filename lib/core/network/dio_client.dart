import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// import '../local/secure_storage_service.dart';

class DioClient {
  final String baseUrl;
  // final SecureStorageService secureStorageService;
  Dio? dio;
  String? token;

  DioClient(this.baseUrl, Dio? dioC) {
    dio = dioC ?? Dio();
    _init();
    updateHeader(authToken: token);
  }

  Future<void> _init() async {
    // token = await secureStorageService.getString('accessToken');
  }

  Future<void> updateHeader({String? authToken}) async {
    dio
      ?..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 60)
      ..options.receiveTimeout = const Duration(seconds: 60)
      ..httpClientAdapter
      ..options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',

        /*'Content-Type': 'application/json; charset=UTF-8',
          'branch-id': '${sharedPreferences.getInt(AppConstants.branch)}',
          'X-localization': sharedPreferences.getString(AppConstants.languageCode)
              ?? AppConstants.languages[0].languageCode,*/
        'Authorization': 'Bearer $authToken',
      };
    dio?.interceptors.add(PrettyDioLogger(requestBody: true));
  }

  Future<Response> getRequest(
    String uri, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      var response = await dio!.get(uri, queryParameters: queryParameters);
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      debugPrint("Network Call Error : $e");
      rethrow;
    }
  }

  Future<dynamic> postRequest(
    String uri, {
    requestBody,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    FormData? formData;
    if (isFormData && requestBody != null) {
      formData = FormData.fromMap(requestBody);
    }

    try {
      var response = await dio!.post(
        uri,
        data: formData ?? requestBody,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (e) {
      debugPrint("Network Call Error : $e");
      rethrow;
    }
  }

  Future<Response> putRequest(
    String uri, {
    requestBody,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    FormData? formData;
    if (isFormData && requestBody != null) {
      formData = FormData.fromMap(requestBody);
    }

    try {
      var response = await dio!.put(
        uri,
        data: formData ?? requestBody,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (e) {
      debugPrint("Network Call Error : $e");
      rethrow;
    }
  }

  Future<Response> makeDeleteRequest(
    String uri, {
    requestBody,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      var response = await dio!.delete(
        uri,
        data: requestBody,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (e) {
      debugPrint("Network Call Error : $e");
      rethrow;
    }
  }

  Future<Response> postRequestWithFileUpload(
    String uri, {
    Map<String, dynamic>? fields,
    Map<String, dynamic>? files,
    Map<String, dynamic>? queryParameters,
  }) async {
    final dataMap = <String, dynamic>{};

    // Add plain fields
    if (fields != null) {
      dataMap.addAll(fields);
    }

    // Add files as MultipartFiles
    if (files != null) {
      for (var entry in files.entries) {
        final fileKey = entry.key;
        final file = entry.value;
        final fileName = file.path.split('/').last;

        dataMap[fileKey] = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
      }
    }

    // If any files exist, use FormData, else send plain JSON
    final data = files != null && files.isNotEmpty
        ? FormData.fromMap(dataMap)
        : dataMap;

    try {
      final response = await dio!.post(
        uri,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (dioError) {
      _handleDioError(dioError);
      rethrow;
    } catch (e) {
      debugPrint("Network Call Error : $e");
      rethrow;
    }
  }

  void _handleDioError(DioException dioError) {
    final response = dioError.response;
    final statusCode = response?.statusCode ?? 0;
    final responseData = response?.data;

    String message = "Something went wrong";

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('error')) {
        message = responseData['error'];
      } else if (responseData.containsKey('message')) {
        message = responseData['message'];
      }
    }

    switch (statusCode) {
      case 400:
        debugPrint("Bad request: $message");
      case 401:
        debugPrint("Unauthorized: $message");
      case 403:
        debugPrint("Forbidden: $message");
      case 404:
        debugPrint("Not found: $message");
      case 500:
        debugPrint("Server error: $message");
      default:
        debugPrint(message);
    }
  }
}
