import 'dart:convert';

import 'package:nyc_parks/utils/api.dart';
import 'package:nyc_parks/utils/utils.dart';

class FriendService {
  Future<bool> createFriendRequest({
    required int userId,
    required int friendId,
  }) async {
    try {
      final res = await postRequest(
        apiPath: '/friend/createFriendRequest', 
        body: { 'userId': userId, 'friendId': friendId }
      );
      httpErrorHandle(
        response: res,
        onSuccess: () => {}
      );
      return true;
    } catch (e) {
      showSnackBar(e.toString());
      return false;
    }
  }

  Future<bool> acceptFriendRequest({
    required int userId,
    required int friendId,
  }) async {
    try {
      final res = await postRequest(
        apiPath: '/friend/acceptFriendRequest',
        body: { 'userId': userId, 'friendId': friendId }
      );
      httpErrorHandle(
          response: res,
          onSuccess: () => {}
        );
      return true;
    } catch (e) {
      showSnackBar(e.toString());
      return false;
    }
  }

  Future<bool> cancelFriendRequest({
    required int userId,
    required int friendId,
  }) async {
    try {
      final res = await postRequest(
        apiPath: '/friend/cancelFriendRequest',
        body: { 'userId': userId, 'friendId': friendId }
      );
      httpErrorHandle(
        response: res,
        onSuccess: () => {}
      );
      return true;
    } catch (e) {
      showSnackBar(e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>?> getFriendRequest({
    required int userId,
    required int friendId,
  }) async {
    // try {
      final res = await getRequest(apiPath: '/friend/getFriendRequest', queryParameters: { 'userId': userId, 'friendId': friendId });
      httpErrorHandle(
        response: res,
        onSuccess: () => {}
      );
      return json.decode(res.body);
    // } catch (e) {
    //   showSnackBar(e.toString());
    //   return null;
    // }
  }

  Future<Map<String, dynamic>?> getFriendsParks({
    required int userId,
  }) async {
    try {
      final res = await getRequest(
        apiPath: '/friend/friendsParks',
        queryParameters: { 'userId': userId }
      );
      
      httpErrorHandle(
        response: res,
        onSuccess: () => {}
      );
      
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      return null;
    } catch (e) {
      print('Error fetching friends parks: $e');
      return null;
    }
  }
}