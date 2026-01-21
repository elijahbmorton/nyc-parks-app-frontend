import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nyc_parks/models/user.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showSnackBar(String text) {
  messengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(text)),
  );
}

void httpErrorHandle({
  required http.Response response,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      showSnackBar(jsonDecode(response.body)['msg']);
      break;
    case 500:
      showSnackBar(jsonDecode(response.body)['error']);
      break;
    default:
      showSnackBar(response.body);
  }
}

bool? toBoolean(String? string) {
  if (string == null) { return null; }
  return (string.toLowerCase() == "true" || string.toLowerCase() == "1")
      ? true
      : (string.toLowerCase() == "false" || string.toLowerCase() == "0"
          ? false
          : null);
}

AssetImage profileImageUri (ProfileImageImage image) => AssetImage('assets/images/profileImages/${image.name}.png');

String toTitleCase(String s) => s.split(' ').map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}').join(' ');