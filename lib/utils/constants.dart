import 'package:flutter/material.dart';

class Constants {
  static String uri = 'http://localhost:5200/api';
  static String uriNoProtocol = 'localhost:5200';
  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static const Map<String, IconData> typeCategoryIcons = {
    // All possible current TYPECATEGORY values
    'Neighborhood Park': Icons.park,
    'Playground': Icons.child_friendly,
    'Recreational Field/Courts': Icons.sports_soccer,
    'Jointly Operated Playground': Icons.groups,
    'Triangle/Plaza': Icons.crop_square,
    'Garden': Icons.local_florist,
    'Strip': Icons.linear_scale,
    'Undeveloped': Icons.terrain,
    'Nature Area': Icons.forest,
    'Parkway': Icons.emoji_transportation,
    'Waterfront Facility': Icons.waves,
    'Community Park': Icons.group_work,
    'Buildings/Institutions': Icons.account_balance,
    'Managed Sites': Icons.settings_suggest,
    'Flagship Park': Icons.star,
    'Historic House Park': Icons.museum,
    'Mall': Icons.shopping_bag,
    'Operations': Icons.build,
    'Cemetery': Icons.church,
    'Lot': Icons.local_parking,
    'Retired N/A': Icons.do_not_disturb_alt,
  };
}