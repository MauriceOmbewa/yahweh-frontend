// ============================================================
// FILE: lib/services/notification_service.dart
// PURPOSE: Fetch, mark read, mark all read.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';

class NotificationService {
  final ApiClient _client;
  NotificationService({required ApiClient client}) : _client = client;

  Future<Map<String, dynamic>> getNotifications(
      {int page = 0, int size = 30}) async {
    return await _client.get(ApiConfig.getNotifications,
        queryParams: {'page': '$page', 'size': '$size'})
        as Map<String, dynamic>;
  }

  Future<int> getUnreadCount() async {
    final data = await _client.get(ApiConfig.unreadCount);
    if (data is int) return data;
    if (data is Map) return (data['count'] as int?) ?? 0;
    return 0;
  }

  Future<void> markRead(String notificationId) async {
    await _client.put(ApiConfig.markRead(notificationId));
  }

  Future<void> markAllRead() async {
    await _client.put(ApiConfig.markAllRead);
  }
}
