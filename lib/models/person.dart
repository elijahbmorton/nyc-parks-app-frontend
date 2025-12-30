import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_node_auth/utils/utils.dart';

enum ProfileImageImage { canada_anemone, common_milkweed, great_blue_lobelia, joe_pye_weed, northern_blue_flag, smooth_blue_aster, smooth_white_beardtongue, sneezeweed, trumpet_honeysuckle, wild_bergamot }
enum ProfileImageBackgroundColor { blue, purple, green, yellow, orange, red, brown }

Color colorFromProfileImageBackgroundColor(ProfileImageBackgroundColor input) {
  switch (input) {
    case ProfileImageBackgroundColor.blue:
      return Colors.blue;
    case ProfileImageBackgroundColor.purple:
      return Colors.purple;
    case ProfileImageBackgroundColor.green:
      return Colors.green;
    case ProfileImageBackgroundColor.yellow:
      return Colors.yellow;
    case ProfileImageBackgroundColor.orange:
      return Colors.orange;
    case ProfileImageBackgroundColor.red:
      return Colors.red;
    case ProfileImageBackgroundColor.brown:
      return Colors.brown;
    // Not needed but whatever
    default:
      return Colors.purple;
  }
}

class ProfileImage {
  final ProfileImageImage image;
  final ProfileImageBackgroundColor backgroundColor;

  ProfileImage({required this.image, required this.backgroundColor});
  
  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'backgroundColor': backgroundColor,
    };
  }

  factory ProfileImage.fromMap(Map<String, dynamic> map) {
    if (map['image'] == null || map['backgroundColor'] == null) {
      throw ArgumentError('Invalid ProfileImage data: both fields must be non-null.');
    }

    return ProfileImage(
      image: ProfileImageImage.values.byName(map['image']),
      backgroundColor: ProfileImageBackgroundColor.values.byName(map['backgroundColor']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileImage.fromJson(String source) => ProfileImage.fromMap(json.decode(source));
}

class Person {
  final int id;
  final String name;
  ProfileImage? profileImage;
  final bool? friendsWithActiveUser;
  final String? createdAt;
  Person({required this.id, required this.name, this.profileImage, this.friendsWithActiveUser, this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage?.toMap(),
      'friendsWithActiveUser': friendsWithActiveUser,
      'createdAt': createdAt,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name'] ?? '',
      profileImage: map['profileImage'] != null
          ? ProfileImage.fromMap(map['profileImage'])
          : null,
      friendsWithActiveUser: toBoolean(map['friendsWithActiveUser']),
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Person.fromJson(String source) => Person.fromMap(json.decode(source));
}