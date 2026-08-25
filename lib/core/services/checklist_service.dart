import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ChecklistService {
  final Dio _dio = Dio();
  
  String get _baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  Future<bool> createChecklistFromDocument({
    required String documentType,
    required String title,
    required List<String> items,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/checklists/from-document',
        data: {
          'document_type': documentType,
          'title': title,
          'items': items,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to create checklist: $e');
      return false;
    }
  }
}
