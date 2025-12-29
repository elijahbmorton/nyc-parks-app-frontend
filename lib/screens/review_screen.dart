import 'package:flutter/material.dart';
import 'package:flutter_node_auth/custom_textfield.dart';
import 'package:flutter_node_auth/models/person.dart';
import 'package:flutter_node_auth/models/review.dart';
import 'package:flutter_node_auth/providers/park_provider.dart';
import 'package:flutter_node_auth/providers/review_provider.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:flutter_node_auth/screens/map_screen.dart';
import 'package:flutter_node_auth/services/auth_services.dart';
import 'package:flutter_node_auth/services/map_services.dart';
import 'package:flutter_node_auth/services/review_services.dart';
import 'package:flutter_node_auth/utils/utils.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewService reviewService = ReviewService();

  bool _isFavorited = false;
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  
  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  void submitReview() {
    Review? review;

    // TODO: Add a function that verifies everything is filled out right
    try {
      review = reviewService.validateAndCreateReview(
        context,
        commentsController.text,
        ratingController.text,
        _isFavorited,
      );
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
    
    // Idk why I'm doing this instead of passing the param
    // I guess it makes the review more accessible to other pages
    Provider.of<ReviewProvider>(context, listen: false).setReviewFromModel(review);

    reviewService.addReview(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final park = Provider.of<ParksProvider>(context).activePark;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(park.SIGNNAME ?? '', style: TextStyle(color: Colors.black),),
          // Favorite
          Container(
            padding: const EdgeInsets.all(0),
            child: IconButton(
              padding: const EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: (_isFavorited
                  ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_border)),
              color: Colors.red[500],
              onPressed: _toggleFavorite,
            ),
          ),
          // Comments
          // TODO: Make this a multi line text
          CustomTextField(
            controller: commentsController,
            hintText: 'Comments',
          ),
          // Rating
          // TODO: Make this validate only numbers 
          // In fact make a better UI
          CustomTextField(
            controller: ratingController,
            hintText: '1-10',
          ),
          // Submit
          ElevatedButton(
            onPressed: submitReview,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              textStyle: MaterialStateProperty.all(
                const TextStyle(color: Colors.white),
              ),
              minimumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 2.5, 50),
              ),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
