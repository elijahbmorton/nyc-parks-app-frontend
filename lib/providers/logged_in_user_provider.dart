import 'package:flutter/material.dart';
import 'package:nyc_parks/models/logged_in_user.dart';
import 'package:nyc_parks/models/user.dart';

class LoggedInUserProvider extends ChangeNotifier {
  LoggedInUser? _user;
  bool _isCheckingAuth = true;

  LoggedInUser get user => _user!; // safe ONLY in authed branch
  LoggedInUser? get maybeUser => _user;

  bool get isCheckingAuth => _isCheckingAuth;

  bool get isLoggedIn => _user != null && _user!.token.isNotEmpty;

  void setChecking(bool v) {
    _isCheckingAuth = v;
    notifyListeners();
  }

  void setUser(String userJson) {
    _user = LoggedInUser.fromJson(userJson);
    setChecking(false);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _isCheckingAuth = false;
    notifyListeners();
  }

  void setUserProfileImage(ProfileImage profileImage) {
    _user?.profileImage = profileImage;
    notifyListeners();
  }

  void setUserFromModel(LoggedInUser user) {
    _user = user;
    _isCheckingAuth = false;
    notifyListeners();
  }
}