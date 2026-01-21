import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyc_parks/models/user.dart';
import 'package:nyc_parks/models/review.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/providers/review_provider.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/screens/map_screen.dart';
import 'package:nyc_parks/utils/constants.dart';
import 'package:nyc_parks/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:nyc_parks/services/auth_services.dart';

class ReviewService {
  void addReview({
    required BuildContext context,
  }) async {
    try {
      var review = Provider.of<ReviewProvider>(context, listen: false).review;
      var loggedInUser = Provider.of<LoggedInUserProvider>(context, listen: false).user;

      final navigator = Navigator.of(context);
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/review/addReview'),
        body: jsonEncode({
          'review': review,
          'userId': loggedInUser.id,
        }),
        headers: Constants.headers,
      );

      if (!context.mounted) {
        return;
      }

      httpErrorHandle(
        response: res,
        onSuccess: () async {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MapScreen(),
            ),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  void getReviews({
    required BuildContext context,
    required String parkId,
    required int userId,
  }) async {
    if (parkId.isEmpty) {
      print("No GlobalId in getReviews");
      return;
    }
    try {
      final Map<String, String> queryParameters = { 'parkId': parkId, 'userId': userId.toString(), };

      String token = await AuthService.getToken() ?? '';

      // TODO: This might need to be https?? in prod
      // And in other places. Also fix having to put /api here
      var uri = Uri.http(Constants.uriNoProtocol, '/api/review/reviewsFromPark', queryParameters);
      http.Response res = await http.get(
        uri,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'x-auth-token': token},
      );

      if (!context.mounted) {
        print("Context not mounted");
        return;
      }

      Provider.of<ReviewProvider>(context, listen: false).setReviews(context: context, reviews: res.body);
    } catch (e) {
      print(e);
      //showSnackBar(e.toString());
    }
  }

  Review validateAndCreateReview(BuildContext context, String? comments, String? nullableRating, bool favorite) {
    if (nullableRating == null) {
      throw Exception("Missing rating!");
    }
    String rating = nullableRating;
    
    final park = Provider.of<ParksProvider>(context, listen: false).activePark;
    final loggedInUser = Provider.of<LoggedInUserProvider>(context, listen: false).user;

    // Rating int conversion and validation
    int? ratingInt;
    try {
      ratingInt = int.parse(rating.trim());
    } catch (e) {
      throw Exception("Non-integer rating. Please enter a number between 1 and 10.");
    }
    final regExp = RegExp(r'^([1-9]|10)$'); // A number 1-10
    if (!regExp.hasMatch(rating)) { 
      throw Exception("Invalid rating. Please enter a number between 1 and 10."); 
    }

    Review? review;

    try {
      review = Review(
        id: 0, // DB generates id by auto incrememnt. This is placeholder
        parkId: park.GlobalID!,
        comments: comments,
        rating: ratingInt,
        favorite: favorite,
        author: User(id: loggedInUser.id, name: loggedInUser.name),
      );
    } catch (e) {
      throw Exception("Couldn't create the review. $e");
    }

    return review;
  }
}