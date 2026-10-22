// ============================================================
// FILE: lib/services/wrapped_service.dart
// PURPOSE: Weekly Wrapped — latest, history, generate.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';

class WrappedService {
  final ApiClient _client;
  WrappedService({required ApiClient client}) : _client = client;

  Future<Map<String, dynamic>> getLatest() async {
    return await _client.get(ApiConfig.latestWrapped) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getHistory() async {
    final data = await _client.get(ApiConfig.wrappedHistory);
    if (data is Map) return (data['content'] as List?) ?? [];
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> generate() async {
    return await _client.post(ApiConfig.generateWrapped)
        as Map<String, dynamic>;
  }
}
