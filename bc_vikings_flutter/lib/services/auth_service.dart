import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import 'supabase_service.dart';

enum UserRole { player, coach }

class AuthUser {
  final UserRole role;
  final Player? player;

  AuthUser({required this.role, this.player});

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'player': player?.toJson(),
    };
  }

  static AuthUser fromJson(Map<String, dynamic> json) {
    return AuthUser(
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      player: json['player'] != null ? Player.fromJson(json['player']) : null,
    );
  }
}

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();

  static const String _sessionKey = 'bc_vikings_session';
  
  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;
  bool get isCoach => _currentUser?.role == UserRole.coach;
  bool get isPlayer => _currentUser?.role == UserRole.player;

  Future<void> initialize() async {
    await _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson != null) {
        final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
        _currentUser = AuthUser.fromJson(sessionData);
      }
    } catch (e) {
      // Если не удалось загрузить сессию, очищаем сохраненные данные
      await clearSession();
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString(_sessionKey, jsonEncode(_currentUser!.toJson()));
      } else {
        await prefs.remove(_sessionKey);
      }
    } catch (e) {
      // Handle save error
    }
  }

  Future<AuthUser?> loginAsCoach(String password) async {
    if (password != AppConstants.coachPassword) {
      throw Exception(AppStrings.invalidCredentials);
    }

    _currentUser = AuthUser(role: UserRole.coach);
    await _saveSession();
    return _currentUser;
  }

  Future<AuthUser?> loginAsPlayer(String login, String password) async {
    try {
      final player = await SupabaseService.instance.getPlayerByLogin(login);
      
      if (player == null) {
        throw Exception(AppStrings.invalidCredentials);
      }

      // В реальном проекте здесь должна быть проверка хешированного пароля
      if (player.password != password) {
        throw Exception(AppStrings.invalidCredentials);
      }

      _currentUser = AuthUser(role: UserRole.player, player: player);
      await _saveSession();
      return _currentUser;
    } catch (e) {
      throw Exception('${AppStrings.error}: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _saveSession();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
  }


}