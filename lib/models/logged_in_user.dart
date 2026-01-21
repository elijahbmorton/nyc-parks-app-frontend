import 'dart:convert';

import 'package:nyc_parks/models/user.dart';

class LoggedInUser extends User {
  final String email;
  final String token;
  final String? password;

  LoggedInUser({
    required int id,
    required String name,
    required this.email,
    required this.token,
    ProfileImage? profileImage,
    String? createdAt,
    bool? friendsWithLoggedInUser,
    this.password,
  }) : super(
          id: id,
          name: name,
          profileImage: profileImage,
          createdAt: createdAt,
          friendsWithLoggedInUser: friendsWithLoggedInUser,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'email': email,
      'token': token,
      'password': password,
    };
  }

  factory LoggedInUser.fromMap(Map<String, dynamic> map) {
    return LoggedInUser(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      profileImage: map['profileImage'] != null ? ProfileImage.fromMap(map['profileImage']) : null,
      createdAt: map['createdAt'],
      friendsWithLoggedInUser: map['friendsWithLoggedInUser'],
      password: map['password'],
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory LoggedInUser.fromJson(String source) => LoggedInUser.fromMap(json.decode(source));
}
