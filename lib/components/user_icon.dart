import 'package:flutter/material.dart';
import 'package:nyc_parks/models/user.dart';
import 'package:nyc_parks/screens/user_screen.dart';

ProfileImage createProfileImageOptions (User user) {
  if (user.profileImage == null) {
    var seedNumber = 0;
    // Seeded randomness for profile image
    try {
      seedNumber = user.name.runes.toList().reduce((a, b) => a + b) + (user.createdAt?.runes.toList() ?? List.empty()).reduce((a, b) => a + b);
    } catch (e) {
      print(e);
    }
    user.profileImage = ProfileImage(
      image: ProfileImageImage.values[seedNumber.remainder(ProfileImageImage.values.length)],
      backgroundColor: ProfileImageBackgroundColor.values[seedNumber.remainder(ProfileImageBackgroundColor.values.length)]
    );
  }

  return user.profileImage!;
}

class UserIcon extends StatelessWidget {
  final User user;
  final VoidCallback? onPressed;
  final double iconSize;

  // 2. Create constructor with named parameters
  const UserIcon({
    Key? key,
    required this.user,
    this.onPressed,
    this.iconSize = 40,
  }) : super(key: key);

  ProfileImage get profileImage => createProfileImageOptions(user);
  String get profileImageUri => 'assets/images/profileImages/${profileImage.image.name}.png';

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: (iconSize / 2),
      backgroundImage: AssetImage(profileImageUri),
      backgroundColor: colorFromProfileImageBackgroundColor(profileImage.backgroundColor),
    );

    if (onPressed != null) {
      return GestureDetector(
        onTap: onPressed,
        child: avatar,
      );
    }
    return avatar;
  }
}