import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class PlayersProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<Player> _players = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadPlayers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _players = await _supabaseService.getPlayers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPlayer(Player player) async {
    try {
      final newPlayer = await _supabaseService.createPlayer(player);
      _players.add(newPlayer);
      _players.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlayer(Player player) async {
    try {
      final updatedPlayer = await _supabaseService.updatePlayer(player);
      final index = _players.indexWhere((p) => p.id == player.id);
      if (index != -1) {
        _players[index] = updatedPlayer;
        _players.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlayer(String id) async {
    try {
      await _supabaseService.deletePlayer(id);
      _players.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Player? getPlayerById(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Player?> refreshPlayer(String id) async {
    try {
      final player = await _supabaseService.getPlayerById(id);
      if (player != null) {
        final index = _players.indexWhere((p) => p.id == id);
        if (index != -1) {
          _players[index] = player;
          _players.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
          notifyListeners();
        }
        return player;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return null;
  }
}