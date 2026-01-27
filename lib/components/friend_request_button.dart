import 'package:flutter/material.dart';
import 'package:nyc_parks/models/logged_in_user.dart';
import 'package:nyc_parks/models/user.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/screens/user_screen.dart';
import 'package:nyc_parks/services/friend_services.dart';
import 'package:nyc_parks/styles/styles.dart';
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
  final bool useWhiteStyle;

  const FriendRequestButton({
    super.key,
    required this.friend,
    this.useWhiteStyle = false,
  });

  @override
  State<FriendRequestButton> createState() => _FriendRequestButtonState();
}

class _FriendRequestButtonState extends State<FriendRequestButton> {
  final FriendService friendService = FriendService();
  FriendRequestStatus friendRequestStatus = FriendRequestStatus.none;
  int? requestSenderId; // Track who sent the friend request

  @override
  void initState() {
    super.initState();
    friendRequestStatus = FriendRequestStatus.fromString(widget.friend['friendRequestStatus'] ?? 'none');
    // Try both field names - backend might use 'senderId' or 'userId' to indicate who sent the request
    requestSenderId = (widget.friend['senderId'] ?? widget.friend['userId']) as int?;
  }

  void createFriendRequest(LoggedInUser loggedInUser) async {
    if (await friendService.createFriendRequest(userId: loggedInUser.id, friendId: widget.friend['id'])) {
      setState(() {
        friendRequestStatus = FriendRequestStatus.pending;
        requestSenderId = loggedInUser.id; // You sent it
      });
    }
  }

  void acceptFriendRequest(LoggedInUser loggedInUser) async {
    if (await friendService.acceptFriendRequest(userId: loggedInUser.id, friendId: widget.friend['id'])) {
      setState(() => friendRequestStatus = FriendRequestStatus.accepted);
    }
  }

  void cancelFriendRequest(LoggedInUser loggedInUser) async {
    if (await friendService.cancelFriendRequest(userId: loggedInUser.id, friendId: widget.friend['id'])) {
      setState(() {
        friendRequestStatus = FriendRequestStatus.none;
        requestSenderId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoggedInUser loggedInUser = Provider.of<LoggedInUserProvider>(context).user;
    final isWhiteStyle = widget.useWhiteStyle;

    // Pending
    if (friendRequestStatus == FriendRequestStatus.pending) {
      // Cancel if you made it (requestSenderId is the sender)
      if (requestSenderId == loggedInUser.id) {
        return OutlinedButton.icon(
          onPressed: () => cancelFriendRequest(loggedInUser),
          icon: Icon(Icons.close, size: isWhiteStyle ? 20 : 16),
          label: const Text('Cancel Request'),
          style: OutlinedButton.styleFrom(
            foregroundColor: isWhiteStyle ? Colors.white : AppColors.textSecondary,
            side: BorderSide(
              color: isWhiteStyle
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.textSecondary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            minimumSize: Size(0, isWhiteStyle ? AppSizes.buttonHeightMedium : AppSizes.buttonHeightSmall),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: isWhiteStyle ? 0 : AppSizes.spacing8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.medium,
            ),
          ),
        );
      } else {
        // Accept if other person made it
        return OutlinedButton.icon(
          onPressed: () => acceptFriendRequest(loggedInUser),
          icon: Icon(Icons.check, size: isWhiteStyle ? 20 : 16),
          label: const Text('Accept Request'),
          style: OutlinedButton.styleFrom(
            foregroundColor: isWhiteStyle ? Colors.white : AppColors.success,
            side: BorderSide(
              color: isWhiteStyle
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.success.withValues(alpha: 0.5),
              width: 1.5,
            ),
            minimumSize: Size(0, isWhiteStyle ? AppSizes.buttonHeightMedium : AppSizes.buttonHeightSmall),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: isWhiteStyle ? 0 : AppSizes.spacing8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.medium,
            ),
          ),
        );
      }
    }

    // Accepted -- Cancel to remove
    if (friendRequestStatus == FriendRequestStatus.accepted) {
      return OutlinedButton.icon(
        onPressed: () => cancelFriendRequest(loggedInUser),
        icon: Icon(Icons.person_remove_outlined, size: isWhiteStyle ? 20 : 16),
        label: const Text('Remove Friend'),
        style: OutlinedButton.styleFrom(
          foregroundColor: isWhiteStyle ? Colors.white : AppColors.error,
          side: BorderSide(
            color: isWhiteStyle
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.error.withValues(alpha: 0.5),
            width: 1.5,
          ),
          minimumSize: Size(0, isWhiteStyle ? AppSizes.buttonHeightMedium : AppSizes.buttonHeightSmall),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.spacing12,
            vertical: isWhiteStyle ? 0 : AppSizes.spacing8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium,
          ),
        ),
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
    return OutlinedButton.icon(
      onPressed: () => createFriendRequest(loggedInUser),
      icon: Icon(Icons.person_add_outlined, size: isWhiteStyle ? 20 : 16),
      label: const Text('Add Friend'),
      style: OutlinedButton.styleFrom(
        foregroundColor: isWhiteStyle ? Colors.white : AppColors.primary,
        side: BorderSide(
          color: isWhiteStyle
              ? Colors.white.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        minimumSize: Size(0, isWhiteStyle ? AppSizes.buttonHeightMedium : AppSizes.buttonHeightSmall),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacing12,
          vertical: isWhiteStyle ? 0 : AppSizes.spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.medium,
        ),
      ),
    );
  }
}