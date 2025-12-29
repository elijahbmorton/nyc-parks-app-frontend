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

class ReviewService {
  void addReview({
    required BuildContext context,
  }) async {
    try {
      var review = Provider.of<ReviewProvider>(context, listen: false).review;
      var user = Provider.of<UserProvider>(context, listen: false).user;

      final navigator = Navigator.of(context);
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/review/addReview'),
        body: jsonEncode({
          'review': review,
          'userId': user.id,
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      // TODO: This might need to be https?? in prod
      // And in other places. Also fix having to put /api here
      var uri = Uri.http(Constants.uriNoProtocol, '/api/review/reviewsFromPark', queryParameters);
      http.Response res = await http.get(
        uri,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'x-auth-token': token!},
      );

      if (!context.mounted) {
        print("Context not mounted");
        return;
      }

      Provider.of<ReviewProvider>(context, listen: false).setReviews(res.body);
    } catch (e) {
      print(e);
      //showSnackBar(e.toString());
    }
  }

  Review validateAndCreateReview(BuildContext context, String? comments, String rating, bool favorite) {
    final park = Provider.of<ParksProvider>(context, listen: false).activePark;
    final user = Provider.of<UserProvider>(context, listen: false).user;

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
        author: Person(id: user.id, name: user.name),
      );
    } catch (e) {
      throw Exception("Couldn't create the review. $e");
    }

    return review;
  }
}