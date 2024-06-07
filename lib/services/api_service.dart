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
    Map<String, String>? headers,
  }) async {
    final authHeader = {
      'Authorization': 'Basic ${_authService.authToken}',
    };

    if (headers != null) authHeader.addAll(headers);

    await http
        .post(
          Uri.parse(endpoint),
          body: body,
          headers: authHeader,
        )
        .then(
          (value) => callback?.call(value),
        );
  }

  Future<void> delete(
    String endpoint,
    FutureOr<dynamic> Function(http.Response)? callback,
  ) async {
    await http.delete(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Basic ${_authService.authToken}',
      },
    ).then(
      (value) => callback?.call(value),
    );
  }
}
