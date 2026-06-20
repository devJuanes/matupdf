import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/matudb/matudb_client.dart';
import '../../../../core/matudb/matudb_result.dart';

class AuthController extends ChangeNotifier {
  AuthController({MatuDbClient? client}) : _client = client ?? MatuDbClient();

  static const _sessionKey = 'matudb_session';
  static const _guestKey = 'matupdf_guest_id';

  final MatuDbClient _client;

  MatuDbSession? _session;
  bool _isLoading = false;
  String? _errorMessage;
  String? _guestId;

  MatuDbSession? get session => _session;
  MatuDbUser? get user => _session?.user;
  bool get isAuthenticated =>
      _session != null && _session!.accessToken.isNotEmpty;

  bool get isSessionExpired => _session?.isExpired ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get guestId => _guestId;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _guestId = prefs.getString(_guestKey);
    if (_guestId == null || _guestId!.isEmpty) {
      _guestId = const Uuid().v4();
      await prefs.setString(_guestKey, _guestId!);
    }

    final raw = prefs.getString(_sessionKey);
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final loaded = MatuDbSession.fromJson(json);
        if (loaded.accessToken.isNotEmpty) {
          _session = loaded;
          _client.setAccessToken(loaded.accessToken);
        }
      } catch (_) {
        await prefs.remove(_sessionKey);
      }
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    _setLoading(true);
    final result = await _client.signUp(
      email: email,
      password: password,
      name: name,
    );
    return _handleAuthResult(result);
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    final result = await _client.signIn(email: email, password: password);
    return _handleAuthResult(result);
  }

  Future<bool> _handleAuthResult(MatuDbResult<MatuDbSession> result) async {
    if (!result.isSuccess || result.data == null) {
      _errorMessage = result.error ?? 'No se pudo completar la operación';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _session = result.data;
    _client.setAccessToken(_session!.accessToken);
    _errorMessage = null;
    _isLoading = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(_session!.toJson()));
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _session = null;
    _client.setAccessToken(null);
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }
}
