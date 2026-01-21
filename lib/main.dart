import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/providers/review_provider.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/screens/map_screen.dart';
import 'package:nyc_parks/screens/signup_screen.dart';
import 'package:nyc_parks/services/auth_services.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Important: set checking true before starting (in case)
      context.read<LoggedInUserProvider>().setChecking(true);

      try {
        await authService.getUserData(context);
      } catch (e) {
        context.read<LoggedInUserProvider>().clearUser();
        showSnackBar(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<LoggedInUserProvider>(context);

    return MaterialApp(
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
