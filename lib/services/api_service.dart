import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> _getJwt() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      final cognitoSession = session as CognitoAuthSession;
      return cognitoSession.userPoolTokensResult.value.idToken.raw;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _headers(String? jwt) => {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };

  Uri _uri(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  Future<Map<String, dynamic>> get(String path) async {
    final jwt = await _getJwt();
    final res = await http.get(_uri(path), headers: _headers(jwt));
    return _handle(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final jwt = await _getJwt();
    final res = await http.post(
      _uri(path),
      headers: _headers(jwt),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final jwt = await _getJwt();
    final res = await http.put(
      _uri(path),
      headers: _headers(jwt),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<List<dynamic>> getList(String path) async {
    final jwt = await _getJwt();
    final res = await http.get(_uri(path), headers: _headers(jwt));
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postMultipart(
    String path,
    List<http.MultipartFile> files, {
    Map<String, String>? fields,
  }) async {
    final jwt = await _getJwt();
    final request = http.MultipartRequest('POST', _uri(path));
    if (jwt != null) request.headers['Authorization'] = 'Bearer $jwt';
    if (fields != null) request.fields.addAll(fields);
    request.files.addAll(files);
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  Future<List<dynamic>> postMultipartList(
    String path,
    List<http.MultipartFile> files, {
    Map<String, String>? fields,
  }) async {
    final jwt = await _getJwt();
    final request = http.MultipartRequest('POST', _uri(path));
    if (jwt != null) request.headers['Authorization'] = 'Bearer $jwt';
    if (fields != null) request.fields.addAll(fields);
    request.files.addAll(files);
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Map<String, dynamic> _handle(http.Response res) {
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}
