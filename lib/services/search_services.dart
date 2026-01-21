import 'dart:convert';

import 'package:nyc_parks/utils/api.dart';
import 'package:nyc_parks/utils/utils.dart';

class SearchService {
  Future<List<Map<String, dynamic>>> search({
    required String query,
    int? loggedInUserId,
  }) async {
    try {
      final queryParams = {
        'query': query,
        if (loggedInUserId != null) 'loggedInUserId': loggedInUserId,
      };

      final res = await getRequest(
        apiPath: '/search',
        queryParameters: queryParams,
      );

      httpErrorHandle(
        response: res,
        onSuccess: () {},
      );

      if (res.statusCode == 200) {
        final List<dynamic> results = json.decode(res.body);
        return results.map((item) => item as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Search error: $e');
      showSnackBar('Failed to search');
      return [];
    }
  }
}

