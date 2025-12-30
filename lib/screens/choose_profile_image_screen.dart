import 'package:flutter/material.dart';
import 'package:flutter_node_auth/components/user_icon.dart';
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

class ChooseProfileImageScreen extends StatefulWidget {
  const ChooseProfileImageScreen({Key? key}) : super(key: key);

  @override
  State<ChooseProfileImageScreen> createState() => _ChooseProfileImageScreenState();
}

class _ChooseProfileImageScreenState extends State<ChooseProfileImageScreen> {
  final UserService userService = UserService();
  Map<String, dynamic> user = {};
  ProfileImageImage? selectedImage;
  ProfileImageBackgroundColor? selectedBackgroundColor;
  
  // Future<void> set() async {
  //   setState(() {
  //     selectedImage = ;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0),
          child: Column(children: [
            //UserIcon(user: user),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: <Widget>[
                for (final image in ProfileImageImage.values.toList()) (
                  IconButton(
                    icon: CircleAvatar(
                      radius: 33,
                      backgroundColor: image == selectedImage ? Colors.lightBlue : Colors.black,
                      child: CircleAvatar(
                          radius: 30, // Size of the circle
                          backgroundImage: profileImageUri(image),
                          backgroundColor: Colors.grey,
                      )
                    ),
                    iconSize: 66,
                    onPressed: () => { setState(() => selectedImage = image) },
                  )
                )
              ],
            ),
            selectedImage == null
              ? Row()
              : Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: <Widget>[
                  for (final color in ProfileImageBackgroundColor.values.toList()) (
                    IconButton(
                      icon: CircleAvatar(
                        radius: 33,
                        backgroundColor: color == selectedBackgroundColor ? Colors.lightBlue : Colors.black,
                        child: CircleAvatar(
                            radius: 30, // Size of the circle
                            backgroundImage: profileImageUri(selectedImage!),
                            backgroundColor: colorFromProfileImageBackgroundColor(color),
                        )
                      ),
                      iconSize: 66,
                      onPressed: () => { setState(() => selectedBackgroundColor = color) },
                    )
                  )
                ]
              ) 
          ])
      )
    );
  }
}