import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../models/sandbox_user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  SandboxUser? _user;
  String? _email;
  bool _isLoading = true;

  SandboxUser? get user => _user;
  String? get email => _email;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  final ApiService _api = ApiService();

  AuthProvider() {
    _checkCurrentSession();
  }

  Future<void> _checkCurrentSession() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final cognitoSession = session as CognitoAuthSession;
      final idToken = cognitoSession.userPoolTokensResult.value.idToken.raw;
      _email = _emailFromRawToken(idToken);

      final res = await _api.get('/v1/user');
      final rawCode = res['returnCode'];
      final returnCode = rawCode is int ? rawCode : int.parse(rawCode.toString());
      if (returnCode == 0 && res['user'] != null) {
        _user = SandboxUser.fromJson(res['user'] as Map<String, dynamic>);
      }
    } catch (_) {
      // session invalid or API error — stay unauthenticated
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LoginResult> login(String username, String password) async {
    try {
      SignInResult result;
      try {
        result = await Amplify.Auth.signIn(username: username, password: password);
      } on AuthException catch (e) {
        if (!e.message.contains('already')) rethrow;
        await Amplify.Auth.signOut();
        result = await Amplify.Auth.signIn(username: username, password: password);
      }
      if (!result.isSignedIn) throw Exception('追加の認証ステップが必要です');

      final session = await Amplify.Auth.fetchAuthSession();
      final cognitoSession = session as CognitoAuthSession;
      final idToken = cognitoSession.userPoolTokensResult.value.idToken.raw;
      _email = _emailFromRawToken(idToken);

      final emailB64 = base64.encode(utf8.encode(_email ?? ''));
      final res = await _api.post('/v1/auth/login', {'email': emailB64});
      final rawCode = res['returnCode'];
      final returnCode = rawCode is int ? rawCode : int.parse(rawCode.toString());

      if (returnCode == 0 && res['user'] != null) {
        _user = SandboxUser.fromJson(res['user'] as Map<String, dynamic>);
        notifyListeners();
        if (_user!.blocked) return LoginBlocked();
        if (!_user!.approved) return LoginPendingApproval();
        return LoginSuccess();
      }
      if (returnCode == 1) return LoginNewAccount();

      await Amplify.Auth.signOut();
      throw Exception(res['message'] as String? ?? 'ログインに失敗しました');
    } catch (_) {
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_user != null) {
      try {
        final userIdB64 = base64.encode(utf8.encode(_user!.userId));
        await _api.post('/v1/auth/logout-api', {'userId': userIdB64});
      } catch (_) {}
    }
    await Amplify.Auth.signOut();
    _user = null;
    _email = null;
    notifyListeners();
  }

  void updateUser(SandboxUser user) {
    _user = user;
    notifyListeners();
  }

  String? _emailFromRawToken(String rawToken) {
    try {
      final parts = rawToken.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);
      final decoded = utf8.decode(base64Url.decode(payload));
      final claims = jsonDecode(decoded) as Map<String, dynamic>;
      return claims['email'] as String?;
    } catch (_) {
      return null;
    }
  }
}
