import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyc_parks/main.dart';
import 'package:nyc_parks/models/logged_in_user.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/screens/login_screen.dart';
import 'package:nyc_parks/screens/signup_screen.dart';
import 'package:nyc_parks/utils/constants.dart';
import 'package:nyc_parks/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Secure storage instance for token persistence
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  
  static const _tokenKey = 'x-auth-token';

  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        showSnackBar("Please supply a valid email, password, and name");
        return;
      }

    try {
      LoggedInUser user = LoggedInUser(
        id: 0,
        name: name,
        password: password,
        email: email,
        token: '',
        createdAt: '',
      );

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/auth/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) {
        return;
      }

      httpErrorHandle(
        response: res,
        onSuccess: () {
          showSnackBar(
            'Account created! Login with the same credentials.',
          );
          // Navigate to login screen after successful signup
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
      );
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        showSnackBar("Please supply a valid username and password");
        return;
      }

      var loggedInUserProvider = Provider.of<LoggedInUserProvider>(context, listen: false);

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/auth/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) {
        return;
      }

      httpErrorHandle(
        response: res,
        onSuccess: () async {
          loggedInUserProvider.setUser(res.body);
          // Store token securely
          final token = jsonDecode(res.body)['token'];
          await _storage.write(
            key: _tokenKey,
            value: token,
          );
          // Verify it was saved
          final savedToken = await _storage.read(key: _tokenKey);
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AppShell()),
              (route) => false,
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // get user data
  Future<void> getUserData(
    BuildContext context,
  ) async {
    var loggedInUserProvider = Provider.of<LoggedInUserProvider>(context, listen: false);
    String? token = await _storage.read(key: _tokenKey);


    if (token == null || token.isEmpty) {
      loggedInUserProvider.setChecking(false);
      return;
    }

    try {
      var tokenRes = await http.post(
        Uri.parse('${Constants.uri}/auth/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('${Constants.uri}/auth/getToken'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8', 
            'x-auth-token': token,
          },
        );

        loggedInUserProvider.setUser(userRes.body);

        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AppShell()),
            (route) => false,
          );
        }
      } else {
        // Token invalid, clear it
        await _storage.delete(key: _tokenKey);
        loggedInUserProvider.setChecking(false);
      }
    } catch (e) {
      // Network error or other issue
      loggedInUserProvider.setChecking(false);
    }
  }

  void signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    // Clear secure storage
    await _storage.delete(key: _tokenKey);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
      (route) => false,
    );
  }
}
