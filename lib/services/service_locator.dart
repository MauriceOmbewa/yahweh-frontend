// ============================================================
// FILE: lib/services/service_locator.dart
//
// PURPOSE: Creates one instance of every service and makes them
//          available to the whole app.
//
// WHY THIS MATTERS:
//   Without this, every screen that needs PostService would have
//   to create its own instance — wasteful and messy.
//   With this, we create each service ONCE here and pass it
//   through the Provider tree so every screen can use the same
//   instance.
//
// HOW TO USE (in main.dart):
//   final locator = ServiceLocator();
//   runApp(
//     MultiProvider(
//       providers: locator.providers,
//       child: YahwehApp(),
//     )
//   )
//
// HOW TO USE (in a screen):
//   final auth = context.read<AuthService>();
//   final feed = context.read<PostService>();
// ============================================================

import 'package:provider/provider.dart';

import 'api_client.dart';
import 'token_storage.dart';
import 'auth_service.dart';
import 'post_service.dart';
import 'user_service.dart';
import 'friendship_service.dart';
import 'bookmark_service.dart';
import 'reading_service.dart';
import 'notification_service.dart';
import 'bible_service.dart';
import 'wrapped_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();
  factory ServiceLocator() => _instance;

  // ── Shared infrastructure ────────────────────────────────
  final TokenStorage   storage = TokenStorage();
  late  ApiClient      client  = ApiClient(storage: storage);

  // ── Domain services ───────────────────────────────────────
  late final AuthService         auth         = AuthService(client: client, storage: storage);
  late final PostService         posts        = PostService(client: client);
  late final UserService         users        = UserService(client: client);
  late final FriendshipService   friendships  = FriendshipService(client: client);
  late final BookmarkService     bookmarks    = BookmarkService(client: client);
  late final ReadingService      reading      = ReadingService(client: client);
  late final NotificationService notifications = NotificationService(client: client);
  late final BibleService        bible        = BibleService(client: client);
  late final WrappedService      wrapped      = WrappedService(client: client);

  // ── Provider list for MultiProvider in main.dart ─────────
  List<Provider> get providers => [
    Provider.value(value: storage),
    Provider.value(value: client),
    Provider.value(value: auth),
    Provider.value(value: posts),
    Provider.value(value: users),
    Provider.value(value: friendships),
    Provider.value(value: bookmarks),
    Provider.value(value: reading),
    Provider.value(value: notifications),
    Provider.value(value: bible),
    Provider.value(value: wrapped),
  ];
}
