import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyc_parks/models/review.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:provider/provider.dart';

class ReviewProvider extends ChangeNotifier {
  List<Review?> _reviews = [];
  Review? _review;
  int? _averageRating;

  Review? get review => _review;
  List<Review?> get reviews => _reviews;
  int? get averageRating => _averageRating;

  /// Clears all review state - call before loading a new park's reviews
  void clearReviews() {
    _reviews = [];
    _review = null;
    _averageRating = null;
    notifyListeners();
  }

  void setReview(String review) {
    _review = Review.fromJson(review);
    notifyListeners();
  }

  void setReviewFromModel(Review review) {
    _review = review;
    notifyListeners();
  }

  void setReviews({required BuildContext context, required String reviews}) {
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
        'createdAt': review['createdAt'],
      }));
    }
    // Set average rating
    _averageRating = _reviews.isNotEmpty
        ? _reviews.fold<int>(0, (sum, r) => sum + (r?.rating ?? 0)) ~/ _reviews.length
        : null;
    // Set review to the logged in user's review (if they have one)
    final loggedInUser = Provider.of<LoggedInUserProvider>(context, listen: false).user;
    _review = _reviews.cast<Review?>().firstWhere(
      (r) => r?.author.id == loggedInUser.id,
      orElse: () => null,
    );
    
    notifyListeners();
  }

  void setReviewsFromModel(List<Review> reviews) {
    _reviews = reviews;
    notifyListeners();
  }
}