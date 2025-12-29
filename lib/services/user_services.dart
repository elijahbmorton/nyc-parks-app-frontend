import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_node_auth/models/person.dart';
import 'package:flutter_node_auth/models/review.dart';
import 'package:flutter_node_auth/models/user.dart';
import 'package:flutter_node_auth/providers/park_provider.dart';
import 'package:flutter_node_auth/providers/review_provider.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:flutter_node_auth/screens/home_screen.dart';
import 'package:flutter_node_auth/screens/map_screen.dart';
import 'package:flutter_node_auth/screens/signup_screen.dart';
import 'package:flutter_node_auth/utils/constants.dart';
import 'package:flutter_node_auth/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {

  Future<Map<String, dynamic>?> getUserInfo({
    required BuildContext context,
  }) async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;

      // TODO: Make custom get and post functions
      // So I don't have to do this bullshit every time
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      // TODO: Fix this uri var
      //var uri = Uri.http(Constants.uriNoProtocol, '/api/user/userInfo', { 'userId': user.id });
      var uri = 'http://localhost:5200/api/user/userInfo?userId=${user.id}';
      http.Response res = await http.get(
        Uri.parse(uri),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'x-auth-token': token!},
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

}