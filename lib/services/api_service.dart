import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mangovault/services/auth_service.dart';

class ApiService {
  final AuthService _authService;

  ApiService(this._authService);

  Future<void> get(
    String endpoint,
    FutureOr<dynamic> Function(http.Response) callback,
  ) async {
    await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Basic ${_authService.authToken}',
      },
    ).then(callback);
  }

  Future<void> post(
    String endpoint,
    Object? body, {
    FutureOr<dynamic> Function(http.Response)? callback,
  }) async {
    await http
        .post(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Basic ${_authService.authToken}',
          },
          body: body,
        )
        .then(
          (value) => callback?.call(value),
        );
  }

  static Future<List<T>> getJsonList<T>(String endpoint, String token) async {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Basic $token',
      },
    );

    List<dynamic> list = json.decode(response.body);

    return list.cast();
  }
}
