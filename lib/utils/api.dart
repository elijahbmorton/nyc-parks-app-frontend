import 'dart:convert';

import 'package:nyc_parks/utils/constants.dart';
import 'package:nyc_parks/services/auth_services.dart';
import 'package:http/http.dart' as http;

Future<String> getToken() async {
  return await AuthService.getToken() ?? '';
}

Future<http.Response> getRequest({
  required String apiPath,
  Map<String, dynamic>? queryParameters = const {},
}) async {

  // Convert all query parameter values to strings
  final stringQueryParams = queryParameters?.map(
    (key, value) => MapEntry(key, value.toString()),
  );

  final uri = Uri.https(Constants.uriNoProtocol, '/parksappapi/api$apiPath', stringQueryParams);
  final token = await getToken();

  return await http.get(
    uri,
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'x-auth-token': token},
  );
}

Future<http.Response> postRequest({
  required String apiPath,
  Map<String, dynamic>? queryParameters = const {},
  Map<String, dynamic> body = const {},
}) async {

  // Convert all query parameter values to strings
  final stringQueryParams = queryParameters?.map(
    (key, value) => MapEntry(key, value.toString()),
  );

  final uri = Uri.https(Constants.uriNoProtocol, '/parksappapi/api$apiPath', stringQueryParams);
  final token = await getToken();

  return await http.post(
    uri,
    body: json.encode(body),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'x-auth-token': token},
  );
}
