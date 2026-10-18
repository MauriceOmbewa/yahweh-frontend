// ============================================================
// FILE: lib/data/mock_data.dart
//
// PURPOSE: Fake/sample data that powers every screen in the app
//          until a real backend API is connected.
//
// WHY WE DO THIS: It lets us build and test every screen without
// needing a server. All the data matches exactly what you see
// in the UI designs (same names, verses, reactions, etc.)
//
// HOW TO USE: Import this file and access data like:
//   MockData.currentUser       → the logged-in user (Maurice)
//   MockData.feedPosts         → list of posts for the Feed
//   MockData.notifications     → list of notifications
// ============================================================

import '../models/user.dart';
import '../models/bible_verse.dart';
import '../models/post.dart';
import '../models/bookmark.dart';
import '../models/app_notification.dart';
import '../models/message.dart';
import '../models/streak_buddy.dart';
import '../core/theme/app_colors.dart';

class MockData {
  MockData._(); // Private — never instantiate this class

  // ── Current Logged-In User ───────────────────────────────────
  // This is "Maurice" — the user whose profile we see in the designs.
  static final User currentUser = User(
    id:             'user_ma',
    displayName:    'Maurice',
    email:          'maurice@example.com',
    initials:       'MA',
    currentStreak:  12,
    longestStreak:  21,
    chaptersRead:   128,
    timezone:       'Nairobi',
    joinedAt:       DateTime(2026, 1, 1),
    hasReadToday:   true,
    statusVerse:    'Your word is a lamp for my feet, a light on my path.',
    statusVerseRef: 'Psalm 119:105 · NIV',
  );

  // ── Other Users (Friends & Buddies) ─────────────────────────
  static final User aminaNjeri = User(
    id:             'user_an',
    displayName:    'Amina Njeri',
    email:          'amina@example.com',
    initials:       'AN',
    currentStreak:  12,
    longestStreak:  15,
    chaptersRead:   98,
    timezone:       'Nairobi',
    joinedAt:       DateTime(2026, 3, 1),
    hasReadToday:   false, // Hasn't read today — streak at risk
    statusVerse:    'The Lord is my shepherd; I shall not want.',
    statusVerseRef: 'Psalm 23:1 · NIV',
  );

  static final User joelKamau = User(
    id:             'user_jk',
    displayName:    'Joel Kamau',
    email:          'joel@example.com',
    initials:       'JK',
    currentStreak:  9,
    longestStreak:  14,
    chaptersRead:   72,
    timezone:       'Nairobi',
    joinedAt:       DateTime(2026, 2, 15),
    hasReadToday:   false, // Nudge already sent
  );

  static final User samOtieno = User(
    id:             'user_so',
    displayName:    'Sam Otieno',
    email:          'sam@example.com',
    initials:       'SO',
    currentStreak:  4,
    longestStreak:  9,
    chaptersRead:   44,
    timezone:       'Lagos',
    joinedAt:       DateTime(2026, 4, 10),
    hasReadToday:   true, // Both read today — streak safe
  );

  static final User mwangiWeru = User(
    id:             'user_mw',
    displayName:    'Mwangi Weru',
    email:          'mwangi@example.com',
    initials:       'MW',
    currentStreak:  4,
    longestStreak:  7,
    chaptersRead:   31,
    timezone:       'Nairobi',
    joinedAt:       DateTime(2026, 3, 20),
    hasReadToday:   true,
  );

  static final User tabithaBett = User(
    id:             'user_tb',
    displayName:    'Tabitha Bett',
    email:          'tabitha@example.com',
    initials:       'TB',
    currentStreak:  1,
    longestStreak:  5,
    chaptersRead:   12,
    timezone:       'Nairobi',
    joinedAt:       DateTime(2026, 5, 1),
    hasReadToday:   false,
  );

  // Convenience list — used for the story circles row at the top of Feed.
  static List<User> get friends => [
    aminaNjeri,
    joelKamau,
    mwangiWeru,
    samOtieno,
    tabithaBett,
  ];

  // ── Bible Verses ─────────────────────────────────────────────
  static const BibleVerse psalm23v1 = BibleVerse(
    book:        'Psalm',
    chapter:     23,
    startVerse:  1,
    endVerse:    2,
    text:        'The Lord is my shepherd; I shall not want. He makes me lie down in green pastures.',
    translation: 'NIV',
  );

  static const BibleVerse philippians4v6 = BibleVerse(
    book:        'Philippians',
    chapter:     4,
    startVerse:  6,
    text:        'Do not be anxious about anything, but in every situation, by prayer and petition, present your requests to God.',
    translation: 'NIV',
  );

  static const BibleVerse john3v16 = BibleVerse(
    book:        'John',
    chapter:     3,
    startVerse:  16,
    text:        'For God so loved the world that he gave his one and only Son.',
    translation: 'NIV',
  );

  static const BibleVerse psalm119v105 = BibleVerse(
    book:        'Psalm',
    chapter:     119,
    startVerse:  105,
    text:        'Your word is a lamp for my feet, a light on my path.',
    translation: 'NIV',
  );

  static const BibleVerse genesis1v1 = BibleVerse(
    book:        'Genesis',
    chapter:     1,
    startVerse:  1,
    text:        'In the beginning God created the heavens and the earth.',
    translation: 'NIV',
  );

  // ── Full Chapter (Genesis 1) — used in the Bible reader ──────
  // Each verse is its own BibleVerse object.
  static const List<BibleVerse> genesis1Chapter = [
    BibleVerse(
      book: 'Genesis', chapter: 1, startVerse: 1,
      text: 'In the beginning God created the heavens and the earth.',
      translation: 'NIV',
    ),
    BibleVerse(
      book: 'Genesis', chapter: 1, startVerse: 2,
      text: 'Now the earth was formless and empty, darkness was over the surface of the deep, and the Spirit of God was hovering over the waters.',
      translation: 'NIV',
    ),
    BibleVerse(
      book: 'Genesis', chapter: 1, startVerse: 3,
      text: 'And God said, "Let there be light," and there was light.',
      translation: 'NIV',
    ),
    BibleVerse(
      book: 'Genesis', chapter: 1, startVerse: 4,
      text: 'God saw that the light was good, and he separated the light from the darkness.',
      translation: 'NIV',
    ),
    BibleVerse(
      book: 'Genesis', chapter: 1, startVerse: 5,
      text: 'God called the light "day," and the darkness he called "night." And there was evening, and there was morning — the first day.',
      translation: 'NIV',
    ),
  ];

  // ── Feed Posts ────────────────────────────────────────────────
  static final List<Post> feedPosts = [
    Post(
      id:           'post_001',
      author:       aminaNjeri,
      verse:        psalm23v1,
      caption:      'Needed this one after a long week.',
      postedAt:     DateTime.now().subtract(const Duration(hours: 2)),
      visibility:   PostVisibility.public,
      amenCount:    24,
      heartCount:   18,
      fireCount:    9,
      prayCount:    31,
      commentCount: 6,
    ),
    Post(
      id:           'post_002',
      author:       joelKamau,
      verse:        philippians4v6,
      caption:      'Reading this with the Tuesday group.',
      postedAt:     DateTime.now().subtract(const Duration(hours: 5)),
      visibility:   PostVisibility.public,
      amenCount:    12,
      heartCount:   7,
      fireCount:    3,
      prayCount:    15,
      commentCount: 2,
    ),
    Post(
      id:           'post_003',
      author:       currentUser,
      verse:        psalm119v105,
      caption:      'Memorising this one.',
      postedAt:     DateTime.now().subtract(const Duration(days: 1)),
      visibility:   PostVisibility.public,
      amenCount:    14,
      heartCount:   0,
      fireCount:    0,
      prayCount:    8,
      commentCount: 0,
    ),
  ];

  // ── Bookmarks ─────────────────────────────────────────────────
  static final List<Bookmark> bookmarks = [
    Bookmark(
      id:             'bm_001',
      verse:          psalm23v1,
      note:           'read at dawn',
      highlightColor: AppColors.highlightYellow,
      collectionName: 'Peace',
      savedAt:        DateTime.now().subtract(const Duration(days: 3)),
    ),
    Bookmark(
      id:             'bm_002',
      verse:          john3v16,
      highlightColor: AppColors.highlightBlue,
      savedAt:        DateTime.now().subtract(const Duration(days: 5)),
    ),
    Bookmark(
      id:             'bm_003',
      verse:          philippians4v6,
      collectionName: 'Anxiety',
      highlightColor: AppColors.highlightPink,
      savedAt:        DateTime.now().subtract(const Duration(days: 7)),
    ),
    Bookmark(
      id:             'bm_004',
      verse:          psalm119v105,
      collectionName: 'Peace',
      highlightColor: AppColors.highlightGreen,
      savedAt:        DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // ── Bookmark Collections ──────────────────────────────────────
  static List<BookmarkCollection> get bookmarkCollections => [
    BookmarkCollection(
      name:  'Peace',
      bookmarks: bookmarks.where((b) => b.collectionName == 'Peace').toList(),
      previewColors: [
        AppColors.highlightYellow,
        AppColors.highlightBlue,
        AppColors.highlightGreen,
        AppColors.highlightPurple,
      ],
    ),
    BookmarkCollection(
      name:  'Anxiety',
      bookmarks: bookmarks.where((b) => b.collectionName == 'Anxiety').toList(),
      previewColors: [
        AppColors.highlightPink,
        AppColors.highlightOrange,
        AppColors.highlightBlue,
        AppColors.highlightGreen,
      ],
    ),
  ];

  // ── Streak Buddies ────────────────────────────────────────────
  static final List<StreakBuddy> streakBuddies = [
    StreakBuddy(
      id:               'sb_001',
      userId:           'user_ma',
      partnerName:      'Amina Njeri',
      partnerInitials:  'AN',
      myInitials:       'MA',
      sharedStreakDays:  12,
      status:           StreakBuddyStatus.partnerAtRisk,
      nudgeSentToday:   false,
    ),
    StreakBuddy(
      id:               'sb_002',
      userId:           'user_ma',
      partnerName:      'Joel Kamau',
      partnerInitials:  'JK',
      myInitials:       'MA',
      sharedStreakDays:  9,
      status:           StreakBuddyStatus.nudgeSent,
      nudgeSentToday:   true,
    ),
    StreakBuddy(
      id:               'sb_003',
      userId:           'user_ma',
      partnerName:      'Sam Otieno',
      partnerInitials:  'SO',
      myInitials:       'MA',
      sharedStreakDays:  4,
      status:           StreakBuddyStatus.bothRead,
      nudgeSentToday:   false,
    ),
  ];

  // ── Friend Requests ───────────────────────────────────────────
  static final List<User> friendRequests = [tabithaBett];

  // ── Notifications ─────────────────────────────────────────────
  static final List<AppNotification> notifications = [
    AppNotification(
      id:               'notif_001',
      type:             NotificationType.reaction,
      fromUserName:     'Amina',
      fromUserInitials: 'AN',
      fromUserStreak:   12,
      message:          'Amina reacted Amen to your post',
      receivedAt:       DateTime.now().subtract(const Duration(minutes: 5)),
      isRead:           false,
    ),
    AppNotification(
      id:               'notif_002',
      type:             NotificationType.nudge,
      fromUserName:     'Joel',
      fromUserInitials: 'JK',
      fromUserStreak:   9,
      message:          'Joel nudged you: keep your 9 day streak alive',
      receivedAt:       DateTime.now().subtract(const Duration(hours: 1)),
      isRead:           false,
    ),
    AppNotification(
      id:               'notif_003',
      type:             NotificationType.friendAccepted,
      fromUserName:     'Sam',
      fromUserInitials: 'SO',
      fromUserStreak:   4,
      message:          'Sam accepted your friend request',
      receivedAt:       DateTime.now().subtract(const Duration(hours: 3)),
      isRead:           true,
    ),
    AppNotification(
      id:               'notif_004',
      type:             NotificationType.comment,
      fromUserName:     'Tabitha',
      fromUserInitials: 'TB',
      fromUserStreak:   1,
      message:          'Tabitha commented on your post',
      receivedAt:       DateTime.now().subtract(const Duration(days: 1)),
      isRead:           true,
    ),
    AppNotification(
      id:               'notif_005',
      type:             NotificationType.streakMilestone,
      fromUserName:     'Amina',
      fromUserInitials: 'AN',
      fromUserStreak:   12,
      message:          'Amina hit a 7 day streak',
      receivedAt:       DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead:           true,
    ),
  ];

  // ── Conversations (Messages) ──────────────────────────────────
  static final List<Conversation> conversations = [
    Conversation(
      id:                   'conv_001',
      otherUserName:        'Amina Njeri',
      otherUserInitials:    'AN',
      otherUserStreak:      12,
      lastMessagePreview:   'Reading Psalm 23 with you tonight',
      lastMessageAt:        DateTime.now().subtract(const Duration(minutes: 2)),
      hasUnread:            true,
      isStreakBuddy:        true,
      sharedStreakDays:     12,
      messages: [
        Message(
          id:       'msg_001',
          senderId: 'user_an',
          type:     MessageType.text,
          text:     'Did you read today? I am on Psalm 23.',
          sentAt:   DateTime.now().subtract(const Duration(minutes: 10)),
          isFromMe: false,
        ),
        Message(
          id:       'msg_002',
          senderId: 'user_an',
          type:     MessageType.verseShare,
          verse:    psalm23v1,
          sentAt:   DateTime.now().subtract(const Duration(minutes: 9)),
          isFromMe: false,
        ),
        Message(
          id:       'msg_003',
          senderId: 'user_ma',
          type:     MessageType.text,
          text:     'Not yet, doing it now.',
          sentAt:   DateTime.now().subtract(const Duration(minutes: 8)),
          isFromMe: true,
        ),
        Message(
          id:       'msg_004',
          senderId: 'system',
          type:     MessageType.nudge,
          text:     'You nudged Amina to keep the streak alive',
          sentAt:   DateTime.now().subtract(const Duration(minutes: 7)),
          isFromMe: false,
        ),
        Message(
          id:       'msg_005',
          senderId: 'user_an',
          type:     MessageType.text,
          text:     'Done! Streak safe.',
          sentAt:   DateTime.now().subtract(const Duration(minutes: 2)),
          isFromMe: false,
        ),
      ],
    ),
    Conversation(
      id:                   'conv_002',
      otherUserName:        'Joel Kamau',
      otherUserInitials:    'JK',
      otherUserStreak:      9,
      lastMessagePreview:   'Shared a verse: Philippians 4:6',
      lastMessageAt:        DateTime.now().subtract(const Duration(hours: 1)),
      hasUnread:            true,
      isStreakBuddy:        false,
      messages: [
        Message(
          id:       'msg_006',
          senderId: 'user_jk',
          type:     MessageType.verseShare,
          verse:    philippians4v6,
          sentAt:   DateTime.now().subtract(const Duration(hours: 1)),
          isFromMe: false,
        ),
      ],
    ),
    Conversation(
      id:                   'conv_003',
      otherUserName:        'Sam Otieno',
      otherUserInitials:    'SO',
      otherUserStreak:      4,
      lastMessagePreview:   'Haha same, I read at 5am',
      lastMessageAt:        DateTime.now().subtract(const Duration(hours: 3)),
      hasUnread:            false,
      messages: [
        Message(
          id:       'msg_007',
          senderId: 'user_so',
          type:     MessageType.text,
          text:     'Haha same, I read at 5am',
          sentAt:   DateTime.now().subtract(const Duration(hours: 3)),
          isFromMe: false,
        ),
      ],
    ),
    Conversation(
      id:                   'conv_004',
      otherUserName:        'Tabitha Bett',
      otherUserInitials:    'TB',
      otherUserStreak:      1,
      lastMessagePreview:   'Thanks for the nudge!',
      lastMessageAt:        DateTime.now().subtract(const Duration(days: 1)),
      hasUnread:            false,
      messages: [
        Message(
          id:       'msg_008',
          senderId: 'user_tb',
          type:     MessageType.text,
          text:     'Thanks for the nudge!',
          sentAt:   DateTime.now().subtract(const Duration(days: 1)),
          isFromMe: false,
        ),
      ],
    ),
  ];

  // ── Progress Stats ────────────────────────────────────────────
  // Used on the Progress screen.
  static const int chaptersThisWeek  = 11;
  static const double totalHours     = 4.2;
  static const int dailyAvgMinutes   = 36;
  static const int longestSessionMin = 58;
  static const int todayMinutesRead  = 17;
  static const int dailyGoalMinutes  = 25;

  // Reading calendar — 7 columns (days), multiple weeks.
  // Each value is an "intensity" from 0.0 (no reading) to 1.0 (full).
  // Used to render the heatmap grid on the Progress screen.
  static const List<double> calendarIntensity = [
    0.0, 0.6, 0.4, 1.0, 0.3, 0.7, 0.2,
    0.8, 1.0, 0.5, 0.9, 0.0, 0.6, 0.4,
    1.0, 0.3, 0.8, 0.5, 0.9, 0.2, 0.7,
    0.4, 1.0, 0.6, 0.3, 0.8, 0.5, 0.9,
    0.0, 0.7, 0.4, 1.0, 0.6, 0.3, 0.8,
    0.5, 0.9, 0.2, 0.7, 0.4, 1.0, 0.6,
    0.3, 0.8, 0.5, 0.9, 0.0, 0.7, 0.4,
  ];

  // Peak reading hours — 24 values, one per hour of the day (0–23).
  // Used to render the bar chart. Higher = more reading at that hour.
  static const List<double> peakReadingHours = [
    0.0, 0.0, 0.0, 0.0, 0.0, 0.1, // 12am–5am
    0.1, 0.1, 0.2, 0.2, 0.2, 0.2, // 6am–11am
    0.3, 0.2, 0.3, 0.3, 0.3, 0.4, // 12pm–5pm
    0.5, 0.6, 0.8, 1.0, 0.9, 0.6, // 6pm–11pm (peak at 9pm)
  ];

  // ── Achievement Badges ────────────────────────────────────────
  // Used on the Profile screen to show earned badges.
  static const List<Map<String, dynamic>> badges = [
    {'label': '7-day streak', 'icon': 'flame',    'earned': true,  'color': 0xFFF29A38},
    {'label': 'Bookworm',     'icon': 'book',     'earned': true,  'color': 0xFF3D2B82},
    {'label': 'First week',   'icon': 'check',    'earned': true,  'color': 0xFF2E7D32},
    {'label': '30-day streak','icon': 'fire',     'earned': false, 'color': 0xFFF29A38},
    {'label': 'Social',       'icon': 'people',   'earned': false, 'color': 0xFF3D2B82},
  ];
}
