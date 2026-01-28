import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyc_parks/models/user.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/utils/constants.dart';
import 'package:nyc_parks/utils/utils.dart';
import 'package:nyc_parks/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:nyc_parks/services/auth_services.dart';

class UserService {

  Future<Map<String, dynamic>?> getUserInfo({
    required BuildContext context,
    required int userId
  }) async {
    try {
      http.Response res = await getRequest(
        apiPath: '/user/userInfo',
        queryParameters: { 'userId': userId },
      );

      httpErrorHandle(
        response: res,
        onSuccess: () async {},
      );

      return json.decode(res.body);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> updateProfileImage({
    required BuildContext context,
    required ProfileImage profileImage
  }) async {
    try {
      final loggedInUserProvider = Provider.of<LoggedInUserProvider>(context, listen: false);
      final loggedInUser = loggedInUserProvider.user;

      String token = await AuthService.getToken() ?? '';

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/user/updateProfileImage'),
        body: jsonEncode({
          'profileImage': profileImage.toJson(),
          'userId': loggedInUser.id,
        }),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'x-auth-token': token},
      );

      httpErrorHandle(
        response: res,
        onSuccess: () async {
          loggedInUserProvider.setUserProfileImage(profileImage);
          Navigator.pop(context, true);
        },
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
