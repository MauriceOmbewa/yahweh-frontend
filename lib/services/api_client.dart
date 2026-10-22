// ============================================================
// FILE: lib/services/api_client.dart
//
// PURPOSE: The single HTTP client used by every service.
//
// WHAT IT DOES:
//   - Automatically attaches "Authorization: Bearer <token>" to
//     every request that needs authentication.
//   - Automatically retries once with a token refresh when a
//     request gets a 401 (token expired).
//   - Throws ApiException with a human-readable message on errors.
//   - Handles JSON encoding/decoding.
//
// USAGE (in a service):
//   final client = ApiClient(storage: _storage);
//   final data = await client.get(ApiConfig.getFeed);
//   final post = await client.post(ApiConfig.createPost, body: {...});
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';
import 'api_config.dart';

// ── Custom exception ──────────────────────────────────────────
// Thrown when the server returns an error status code.
class ApiException implements Exception {
  final int    statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final TokenStorage _storage;

  ApiClient({required TokenStorage storage}) : _storage = storage;

  // ── Base headers ─────────────────────────────────────────
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept':       'application/json',
    };
    if (auth) {
      final token = await _storage.accessToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── GET ───────────────────────────────────────────────────
  Future<dynamic> get(
    String url, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    final uri = queryParams != null
        ? Uri.parse(url).replace(queryParameters: queryParams)
        : Uri.parse(url);

    var response = await http.get(uri, headers: await _headers(auth: auth));

    // Auto-refresh on 401
    if (response.statusCode == 401 && auth) {
      await _refresh();
      response = await http.get(uri, headers: await _headers(auth: auth));
    }

    return _handleResponse(response);
  }

  // ── POST ──────────────────────────────────────────────────
  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse(url);
    var response = await http.post(
      uri,
      headers: await _headers(auth: auth),
      body:    body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401 && auth) {
      await _refresh();
      response = await http.post(
        uri,
        headers: await _headers(auth: auth),
        body:    body != null ? jsonEncode(body) : null,
      );
    }

    return _handleResponse(response);
  }

  // ── PUT ───────────────────────────────────────────────────
  Future<dynamic> put(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse(url);
    var response = await http.put(
      uri,
      headers: await _headers(auth: auth),
      body:    body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401 && auth) {
      await _refresh();
      response = await http.put(
        uri,
        headers: await _headers(auth: auth),
        body:    body != null ? jsonEncode(body) : null,
      );
    }

    return _handleResponse(response);
  }

  // ── PATCH ─────────────────────────────────────────────────
  Future<dynamic> patch(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse(url);
    var response = await http.patch(
      uri,
      headers: await _headers(auth: auth),
      body:    body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401 && auth) {
      await _refresh();
      response = await http.patch(
        uri,
        headers: await _headers(auth: auth),
        body:    body != null ? jsonEncode(body) : null,
      );
    }

    return _handleResponse(response);
  }

  // ── DELETE ────────────────────────────────────────────────
  Future<dynamic> delete(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse(url);
    var response = await http.delete(
      uri,
      headers: await _headers(auth: auth),
      body:    body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401 && auth) {
      await _refresh();
      response = await http.delete(
        uri,
        headers: await _headers(auth: auth),
        body:    body != null ? jsonEncode(body) : null,
      );
    }

    return _handleResponse(response);
  }

  // ── Response handler ──────────────────────────────────────
  dynamic _handleResponse(http.Response response) {
    final body = response.body;
    final status = response.statusCode;

    // 204 No Content — success with no body
    if (status == 204) return null;

    // Try to parse JSON
    dynamic parsed;
    if (body.isNotEmpty) {
      try {
        parsed = jsonDecode(body);
      } catch (_) {
        parsed = body; // plain text response
      }
    }

    if (status >= 200 && status < 300) {
      return parsed;
    }

    // Extract error message from Spring Boot's error response format:
    // { "message": "...", "error": "...", "status": 400 }
    String errorMsg = 'Something went wrong. Please try again.';
    if (parsed is Map) {
      errorMsg = parsed['message']?.toString() ??
                 parsed['error']?.toString() ??
                 errorMsg;
    }

    throw ApiException(status, errorMsg);
  }

  // ── Refresh token ─────────────────────────────────────────
  // Called automatically when we get a 401. Gets a new access
  // token using the refresh token and saves it.
  Future<void> _refresh() async {
    final refreshToken = await _storage.refreshToken;
    if (refreshToken == null) {
      throw const ApiException(401, 'Session expired. Please log in again.');
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.refresh),
        headers: {'Content-Type': 'application/json'},
        body:    jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.updateAccessToken(data['accessToken'] as String);
      } else {
        // Refresh token is also expired — force logout
        await _storage.clear();
        throw const ApiException(401, 'Session expired. Please log in again.');
      }
    } catch (e) {
      await _storage.clear();
      rethrow;
    }
  }
}
