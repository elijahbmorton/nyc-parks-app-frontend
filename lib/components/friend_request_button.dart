import 'package:flutter/material.dart';
import 'package:nyc_parks/models/logged_in_user.dart';
import 'package:nyc_parks/models/user.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/screens/user_screen.dart';
import 'package:nyc_parks/services/friend_services.dart';
import 'package:nyc_parks/utils/utils.dart';
import 'package:provider/provider.dart';

enum FriendRequestStatus { 
  pending, accepted, blocked, none;
  
  // Tweaked from Google AI Overview
  static FriendRequestStatus fromString(String s) {
    switch(s) {
      case "pending": 
        return pending;
      case "accepted":
        return accepted;
      case "blocked":
        return blocked;
      case "none":
        return none;
      default:
        return none;
    }
  }
}

class FriendRequestButton extends StatefulWidget {
  final Map<String, dynamic> friend;

  const FriendRequestButton({
    super.key,
    required this.friend,
  });

  @override
  State<FriendRequestButton> createState() => _FriendRequestButtonState();
}

class _FriendRequestButtonState extends State<FriendRequestButton> {
  final FriendService friendService = FriendService();
  FriendRequestStatus friendRequestStatus = FriendRequestStatus.none;

  @override
  void initState() {
    super.initState();
    friendRequestStatus = FriendRequestStatus.fromString(widget.friend['friendRequestStatus'] ?? 'none');
  }

  void createFriendRequest(LoggedInUser loggedInUser) async {
    if (await friendService.createFriendRequest(userId: loggedInUser.id, friendId: widget.friend['id'])) {
      setState(() => friendRequestStatus = FriendRequestStatus.pending);
    }
  }

  void acceptFriendRequest(LoggedInUser loggedInUser) async {
    if (await friendService.acceptFriendRequest(userId: loggedInUser.id, friendId: widget.friend['id'])) {
      setState(() => friendRequestStatus = FriendRequestStatus.accepted);
    }
  }

  void cancelFriendRequest(LoggedInUser loggedInUser) async {
    if (await friendService.cancelFriendRequest(userId: loggedInUser.id, friendId: widget.friend['id'])) {
      setState(() => friendRequestStatus = FriendRequestStatus.none);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoggedInUser loggedInUser = Provider.of<LoggedInUserProvider>(context).user;

    // Pending
    if (friendRequestStatus == FriendRequestStatus.pending) {
      // Cancel if you made it
      if (widget.friend['id'] == loggedInUser.id || widget.friend['userId'] == loggedInUser.id) {
        return (
          TextButton(
            onPressed: () => cancelFriendRequest(loggedInUser), 
            child: const Text("Cancel Friend Request"),
          )
        );
      } else {
        // Accept if other person made it
        return (
          TextButton(
            onPressed: () => acceptFriendRequest(loggedInUser), 
            child: const Text("Accept Friend Request"),
          )
        );
      }
    }

    // Accepted -- Cancel to remove
    if (friendRequestStatus == FriendRequestStatus.accepted) {
      return (
        TextButton(
          onPressed: () => cancelFriendRequest(loggedInUser), 
          child: const Text("Remove Friend"),
        )
      );
    }

    // I think for now we'll just remove the friend request if the friendship is denied
    // if (friendRequestStatus == FriendRequestStatus.blocked) {
    //   return (
    //     TextButton(
    //       onPressed: () => setState(() => friendRequestStatus = FriendRequestStatus.none), 
    //       child: const Text("Unblock Friend"),
    //     )
    //   );
    // }

    // Default to add friend
    return (
      TextButton(
        onPressed: () => createFriendRequest(loggedInUser), 
        child: const Text("Add Friend"),
      )
    );
  }
}