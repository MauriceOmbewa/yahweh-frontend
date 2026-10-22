// ============================================================
// FILE: lib/services/api_config.dart
//
// PURPOSE: Single place that holds the backend base URL.
//
// HOW TO SWITCH ENVIRONMENTS:
//   - Development (local):   http://localhost:8080
//   - Android emulator:      http://10.0.2.2:8080
//   - Physical device (USB): http://YOUR_MAC_IP:8080
//   - Production:            https://api.yahweh.app
//
// TO FIND YOUR MAC IP (for physical device testing):
//   Run in terminal: ifconfig | grep "inet " | grep -v 127.0.0.1
//   It will look like: 192.168.1.45
//   Then set baseUrl = 'http://192.168.1.45:8080'
// ============================================================

class ApiConfig {
  ApiConfig._();

  // ── Change this to match your environment ────────────────
  // Use 10.0.2.2 on Android emulator (maps to host machine's localhost)
  // Use your Mac's local IP for physical Android/iOS devices
  static const String baseUrl = 'http://10.0.2.2:8080';

  // ── Full API prefix ───────────────────────────────────────
  static const String api = '$baseUrl/api';

  // ── Auth ──────────────────────────────────────────────────
  static const String register      = '$api/auth/register';
  static const String login         = '$api/auth/login';
  static const String googleSignIn  = '$api/auth/google';
  static const String refresh       = '$api/auth/refresh';
  static const String me            = '$api/auth/me';
  static const String logout        = '$api/auth/logout';
  static const String forgotPassword = '$api/auth/forgot-password';
  static const String resetPassword  = '$api/auth/reset-password';

  // ── Users ─────────────────────────────────────────────────
  static const String updateMe        = '$api/users/me';
  static const String updateTimezone  = '$api/users/me/timezone';
  static const String updateStatus    = '$api/users/me/status';
  static const String deleteStatus    = '$api/users/me/status';
  static String userProfile(String userId) => '$api/users/$userId/profile';
  static const String searchUsers     = '$api/users/search';

  // ── Posts / Feed ──────────────────────────────────────────
  static const String createPost  = '$api/posts';
  static const String getFeed     = '$api/posts/feed';
  static String getPost(String id)          => '$api/posts/$id';
  static String getUserPosts(String userId) => '$api/posts/user/$userId';
  static String deletePost(String id)       => '$api/posts/$id';
  static String reactToPost(String id)      => '$api/posts/$id/reactions';
  static String removeReaction(String id)   => '$api/posts/$id/reactions';
  static String addComment(String id)       => '$api/posts/$id/comments';
  static String getComments(String id)      => '$api/posts/$id/comments';

  // ── Friends ───────────────────────────────────────────────
  static String sendFriendRequest(String userId) =>
      '$api/friends/request/$userId';
  static String acceptFriendRequest(String id)   =>
      '$api/friends/request/$id/accept';
  static String declineFriendRequest(String id)  =>
      '$api/friends/request/$id/decline';
  static const String getFriends          = '$api/friends';
  static const String incomingRequests    = '$api/friends/requests/incoming';
  static const String outgoingRequests    = '$api/friends/requests/outgoing';
  static String removeFriend(String id)   => '$api/friends/$id';

  // ── Bookmarks ─────────────────────────────────────────────
  static String saveBookmark(String bibleId, String verseId) =>
      '$api/bookmarks/$bibleId/$verseId';
  static const String getBookmarks = '$api/bookmarks';
  static String getBookmark(String bibleId, String verseId) =>
      '$api/bookmarks/$bibleId/$verseId';
  static String deleteBookmark(String bibleId, String verseId) =>
      '$api/bookmarks/$bibleId/$verseId';

  // ── Bookmark Collections ──────────────────────────────────
  static const String createCollection  = '$api/bookmark-collections';
  static const String getCollections    = '$api/bookmark-collections';
  static String getCollection(String id)    => '$api/bookmark-collections/$id';
  static String updateCollection(String id) => '$api/bookmark-collections/$id';
  static String deleteCollection(String id) => '$api/bookmark-collections/$id';
  static String addVerseToCollection(String id) =>
      '$api/bookmark-collections/$id/verses';
  static String getCollectionVerses(String id) =>
      '$api/bookmark-collections/$id/verses';
  static String removeVerseFromCollection(String colId, String bmId) =>
      '$api/bookmark-collections/$colId/verses/$bmId';

  // ── Reading Progress ──────────────────────────────────────
  static String markChapterRead(String bibleId, String chapterId) =>
      '$api/reading-progress/$bibleId/chapters/$chapterId';
  static const String getAllProgress   = '$api/reading-progress';
  static const String getProgressCount = '$api/reading-progress/count';
  static String chapterStatus(String bibleId, String chapterId) =>
      '$api/reading-progress/$bibleId/chapters/$chapterId';

  // ── Reading Sessions ──────────────────────────────────────
  static const String startSession  = '$api/reading-sessions/start';
  static const String endSession    = '$api/reading-sessions/end';
  static const String getSessions   = '$api/reading-sessions';
  static const String sessionCount  = '$api/reading-sessions/count';

  // ── Reading Goal ──────────────────────────────────────────
  static const String getGoal         = '$api/reading-goals';
  static const String updateGoal      = '$api/reading-goals';
  static const String goalProgressToday = '$api/reading-goals/progress/today';

  // ── Reading Streak ────────────────────────────────────────
  static const String getStreak       = '$api/reading-streak';
  static const String streakCalendar  = '$api/reading-streak/calendar';

  // ── Reading Statistics ────────────────────────────────────
  static const String getStats           = '$api/reading-statistics';
  static const String dailyStats         = '$api/reading-statistics/daily';
  static const String weeklyStats        = '$api/reading-statistics/weekly';
  static const String monthlyStats       = '$api/reading-statistics/monthly';
  static const String activityByHour     = '$api/reading-statistics/activity-by-hour';
  static const String weeklyActivityByHour = '$api/reading-statistics/weekly/activity-by-hour';

  // ── Notifications ─────────────────────────────────────────
  static const String getNotifications    = '$api/notifications';
  static const String unreadCount         = '$api/notifications/unread-count';
  static String markRead(String id)        => '$api/notifications/$id/read';
  static const String markAllRead          = '$api/notifications/read-all';

  // ── Weekly Wrapped ────────────────────────────────────────
  static const String latestWrapped    = '$api/wrapped/latest';
  static const String wrappedHistory   = '$api/wrapped/history';
  static const String generateWrapped  = '$api/wrapped/generate';

  // ── Bible (API.Bible proxy) ───────────────────────────────
  static const String getBibles       = '$api/bibles';
  static String getPassage(String bibleId, String passageId) =>
      '$api/bibles/$bibleId/passages/$passageId';
  static String searchBible(String bibleId) => '$api/bibles/$bibleId/search';

  // ── Block ─────────────────────────────────────────────────
  static String blockUser(String userId)    => '$api/users/$userId/block';
  static String unblockUser(String userId)  => '$api/users/$userId/block';
  static const String getBlockedUsers       = '$api/users/blocked';
}
