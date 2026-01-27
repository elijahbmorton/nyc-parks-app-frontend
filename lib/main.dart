import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/providers/review_provider.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/screens/map_screen.dart';
import 'package:nyc_parks/screens/signup_screen.dart';
import 'package:nyc_parks/screens/user_screen.dart';
import 'package:nyc_parks/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'styles/styles.dart';
import 'utils/utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // CupertinoApp?
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoggedInUserProvider()),
        ChangeNotifierProvider(create: (_) => ParksProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    // Providers are now at the top level, so just return MapScreen
    return const MapScreen();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Uri? _pendingDeepLink;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Important: set checking true before starting (in case)
      context.read<LoggedInUserProvider>().setChecking(true);

      try {
        await authService.getUserData(context);

        // After auth is complete, handle pending deep link
        if (_pendingDeepLink != null) {
          _handleDeepLink(_pendingDeepLink!);
          _pendingDeepLink = null;
        }
      } catch (e) {
        context.read<LoggedInUserProvider>().clearUser();
        showSnackBar(e.toString());
      }
    });
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('Deep link received: $uri');
      _handleDeepLink(uri);
    });

    // Handle link that opened the app
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        print('Initial deep link: $uri');
        // Store it to handle after auth is done
        _pendingDeepLink = uri;
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    print('Handling deep link: scheme=${uri.scheme}, host=${uri.host}, path=${uri.path}, pathSegments=${uri.pathSegments}');

    if (uri.scheme == 'nycgreen' && uri.host == 'user') {
      // Extract user ID from path
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final userIdStr = pathSegments[0];
        final userId = int.tryParse(userIdStr);
        print('Parsed user ID: $userId');

        if (userId != null) {
          // Use the navigator key to navigate
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.read<LoggedInUserProvider>().isLoggedIn) {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => UserScreen(userId: userId),
                ),
              );
            } else {
              // Store for later if not logged in yet
              _pendingDeepLink = uri;
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<LoggedInUserProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      title: 'NYC Green',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Builder(
        builder: (context) {
          if (auth.isCheckingAuth) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!auth.isLoggedIn) {
            // Auth screens (user is NOT authed)
            return const SignupScreen();
          }

          // App (user is authed)
          return const AppShell();
        },
      ),
    );
  }
}
