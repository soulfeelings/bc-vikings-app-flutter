import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class TrainingProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<TrainingSession> _sessions = [];
  Map<String, List<Attendance>> _attendanceBySession = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<TrainingSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadTrainingSessions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sessions = await _supabaseService.getTrainingSessions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTrainingSession(TrainingSession session) async {
    try {
      final newSession = await _supabaseService.createTrainingSession(session);
      _sessions.insert(0, newSession);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTrainingSession(String id) async {
    try {
      await _supabaseService.deleteTrainingSession(id);
      _sessions.removeWhere((s) => s.id == id);
      _attendanceBySession.remove(id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Attendance>> loadAttendanceForSession(String sessionId) async {
    try {
      final attendance = await _supabaseService.getAttendanceBySession(sessionId);
      _attendanceBySession[sessionId] = attendance;
      notifyListeners();
      return attendance;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  List<Attendance> getAttendanceForSession(String sessionId) {
    return _attendanceBySession[sessionId] ?? [];
  }

  Future<bool> markAttendance(Attendance attendance) async {
    try {
      final updatedAttendance = await _supabaseService.markAttendance(attendance);
      
      // Update local cache
      final sessionAttendance = _attendanceBySession[attendance.sessionId] ?? [];
      final existingIndex = sessionAttendance.indexWhere(
        (a) => a.playerId == attendance.playerId,
      );
      
      if (existingIndex != -1) {
        sessionAttendance[existingIndex] = updatedAttendance;
      } else {
        sessionAttendance.add(updatedAttendance);
      }
      
      _attendanceBySession[attendance.sessionId] = sessionAttendance;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Attendance>> getPlayerAttendance(String playerId) async {
    try {
      return await _supabaseService.getAttendanceByPlayer(playerId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }
}