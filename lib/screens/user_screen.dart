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
import 'package:flutter_node_auth/services/user_services.dart';
import 'package:flutter_node_auth/utils/utils.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService userService = UserService();
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      setState(() {
        isLoading = true;
      });

      var fetchedUserInfo = await userService.getUserInfo(context: context);

      setState(() {
        userInfo = fetchedUserInfo!; // Correctly update the state variable
        isLoading = false;
      });
    } catch (e) {
      showSnackBar("Failed to fetch user");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Info"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: "Reviews"),
                      Tab(text: "Friends"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Reviews Tab
                        ListView.builder(
                          itemCount: userInfo['Reviews']?.length ?? 0,
                          itemBuilder: (context, index) {
                            final review = userInfo['Reviews'][index];
                            return ListTile(
                              title: Text(review['parkId'] ?? "No Title"),
                              subtitle: Text(review['comments'] ?? "No Comments"),
                            );
                          },
                        ),

                        // Friends Tab
                        ListView.builder(
                          itemCount: userInfo['friends']?.length ?? 0,
                          itemBuilder: (context, index) {
                            final friend = userInfo['friends'][index];
                            return ListTile(
                              title: Text(friend['name'] ?? "No Name"),
                              subtitle: Text(friend['friendRequestStatus'] ?? ''),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
