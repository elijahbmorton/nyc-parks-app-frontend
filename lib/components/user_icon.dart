import 'package:flutter/material.dart';
import 'package:flutter_node_auth/models/person.dart';
import 'package:flutter_node_auth/screens/user_screen.dart';

ProfileImage createProfileImageOptions (Person user) {
  if (user.profileImage == null) {
    // Seeded randomness for profile image
    final seedNumber = user.name.runes.toList().reduce((a, b) => a + b) + (user.createdAt?.runes.toList() ?? List.empty()).reduce((a, b) => a + b);
    user.profileImage = ProfileImage(
      image: ProfileImageImage.values[seedNumber.remainder(ProfileImageImage.values.length)],
      backgroundColor: ProfileImageBackgroundColor.values[seedNumber.remainder(ProfileImageBackgroundColor.values.length)]
    );
  }

  return user.profileImage!;
}

class UserIcon extends StatelessWidget {
  final Person user;
  final VoidCallback? onPressed;

  // 2. Create constructor with named parameters
  const UserIcon({
    Key? key,
    required this.user,
    this.onPressed,
  }) : super(key: key);

  ProfileImage get profileImage => createProfileImageOptions(user);
  String get profileImageUri => 'assets/images/profileImages/${profileImage.image.name}.png';

  @override
  Widget build(BuildContext context) {
    return (
      IconButton(
        icon: CircleAvatar(
          radius: 20, // Size of the circle
          backgroundImage: AssetImage(profileImageUri),
          backgroundColor: colorFromProfileImageBackgroundColor(profileImage.backgroundColor),
        ),
        iconSize: 40,
        onPressed: onPressed,
      )
    );
  }
}