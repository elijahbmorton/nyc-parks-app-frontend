import 'package:flutter/material.dart';
import 'package:flutter_node_auth/providers/park_provider.dart';
import 'package:flutter_node_auth/providers/review_provider.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:flutter_node_auth/screens/map_screen.dart';
import 'package:flutter_node_auth/screens/review_screen.dart';
import 'package:flutter_node_auth/services/auth_services.dart';
import 'package:flutter_node_auth/services/map_services.dart';
import 'package:flutter_node_auth/services/review_services.dart';
import 'package:flutter_node_auth/utils/utils.dart';
import 'package:provider/provider.dart';

class ParkScreen extends StatefulWidget {
  const ParkScreen({Key? key}) : super(key: key);

  @override
  State<ParkScreen> createState() => _ParkScreenState();
}

class _ParkScreenState extends State<ParkScreen> {
  String? _lastFetchedParkId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final park = Provider.of<ParksProvider>(context, listen: false).activePark;
    final user = Provider.of<UserProvider>(context, listen: false).user;

    final parkId = park.GlobalID;
    if (parkId == null || parkId.isEmpty) return;

    // Only fetch when park changes (or first time)
    if (_lastFetchedParkId == parkId) return;
    _lastFetchedParkId = parkId;

    // Do it after this frame to avoid setState/notify during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ReviewService().getReviews(
        context: context,
        parkId: parkId,
        userId: user.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final park = Provider.of<ParksProvider>(context).activePark;
    final reviews = Provider.of<ReviewProvider>(context).reviews;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            park.SIGNNAME ?? '',
            style: TextStyle(color: Colors.black),
          ),
          Text(park.BOROUGH ?? ''),
          Text(park.CLASS ?? ''),
          Text(park.SUBCATEGORY ?? ''),
          ElevatedButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReviewScreen(),
                ),
              ),
            },
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
              "Add Review",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          Text('Reviews:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...reviews.map((review) => review == null
            ? SizedBox()
            : ListTile(
                title: Text(review.comments ?? '', style: TextStyle(color: Colors.black)),
                subtitle: Text('Rating: ${review.rating}'),
            )
          ),
        ],
      ),
    );
  }
}
