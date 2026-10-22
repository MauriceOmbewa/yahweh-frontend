// ============================================================
// FILE: lib/services/friendship_service.dart
// PURPOSE: Friend requests, accept/decline, list friends.
// ============================================================

import 'api_client.dart';
import 'api_config.dart';

class FriendshipService {
  final ApiClient _client;
  FriendshipService({required ApiClient client}) : _client = client;

  Future<void> sendRequest(String targetUserId) async =>
      _client.post(ApiConfig.sendFriendRequest(targetUserId));

  Future<void> acceptRequest(String friendshipId) async =>
      _client.post(ApiConfig.acceptFriendRequest(friendshipId));

  Future<void> declineRequest(String friendshipId) async =>
      _client.post(ApiConfig.declineFriendRequest(friendshipId));

  Future<List<dynamic>> getFriends() async {
    final data = await _client.get(ApiConfig.getFriends);
    return data is List ? data : (data as Map)['content'] ?? [];
  }

  Future<List<dynamic>> getIncomingRequests() async {
    final data = await _client.get(ApiConfig.incomingRequests);
    return data is List ? data : (data as Map)['content'] ?? [];
  }

  Future<List<dynamic>> getOutgoingRequests() async {
    final data = await _client.get(ApiConfig.outgoingRequests);
    return data is List ? data : (data as Map)['content'] ?? [];
  }

  Future<void> removeFriend(String otherUserId) async =>
      _client.delete(ApiConfig.removeFriend(otherUserId));
}
