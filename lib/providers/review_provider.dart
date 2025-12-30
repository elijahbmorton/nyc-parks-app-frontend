import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_node_auth/models/person.dart';
import 'package:flutter_node_auth/models/review.dart';

class ReviewProvider extends ChangeNotifier {
  List<Review?> _reviews = [];
  Review? _review;

  Review? get review => _review;
  List<Review?> get reviews => _reviews;

  void setReview(String review) {
    _review = Review.fromJson(review);
    notifyListeners();
  }

  void setReviewFromModel(Review review) {
    _review = review;
    notifyListeners();
  }

  void setReviews(String reviews) {
    var parsedReviews = json.decode(reviews);
    _reviews.clear();
    for (final review in parsedReviews) {
      _reviews.add(Review.fromMap({
        'id': review['id'],
        'parkId': review['parkId'],
        'comments': review['comments'],
        'rating': review['rating'],
        'favorite': review['favorite'],
        'author': review['User'],
      }));
    }
    notifyListeners();
  }

  void setReviewsFromModel(List<Review> reviews) {
    _reviews = reviews;
    notifyListeners();
  }
}