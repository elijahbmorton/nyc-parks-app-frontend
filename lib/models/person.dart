import 'dart:convert';

import 'package:flutter_node_auth/utils/utils.dart';

class Person {
  final int id;
  final String name;
  // TODO: add profile pics? Or choose one from a list?
  // final String profileImage;
  final bool? friendsWithActiveUser;
  Person({required this.id, required this.name, this.friendsWithActiveUser});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'friendsWithActiveUser': friendsWithActiveUser,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      friendsWithActiveUser: toBoolean(map['friendsWithActiveUser']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Person.fromJson(String source) => Person.fromMap(json.decode(source));
}