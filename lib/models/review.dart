import 'dart:convert';

import 'package:nyc_parks/models/user.dart';

class Review {
  final int id;
  final String parkId;
  final String? comments;
  final int rating;
  final bool favorite;
  final User author;
  final String? createdAt;
  Review({required this.id, required this.parkId, this.comments, required this.rating, required this.favorite, required this.author, this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parkId': parkId,
      'comments': comments,
      'rating': rating,
      'favorite': favorite,
      'author': author,
      'createdAt': createdAt,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      parkId: map['parkId'],
      comments: map['comments'] ?? '',
      rating: map['rating'],
      favorite: map['favorite'],
      author: User.fromMap(map['author']),
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Review.fromJson(String source) => Review.fromMap(json.decode(source));
}