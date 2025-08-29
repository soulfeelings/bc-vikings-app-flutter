import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late final SupabaseClient _client;

  static const String supabaseUrl = 'https://eptdatrchuegjvdedcpk.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwdGRhdHJjaHVlZ2p2ZGVkY3BrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5ODkxNDEsImV4cCI6MjA3MTU2NTE0MX0.liNfXuyxDoi3Qvym8K7MApDVIYvwAbWIUoF3okmMEIw';

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Players CRUD operations
  Future<List<Player>> getPlayers() async {
    try {
      final response = await _client
          .from('players')
          .select()
          .order('total_points', ascending: false);

      return (response as List).map((json) => Player.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch players: $e');
    }
  }

  Future<Player?> getPlayerById(String id) async {
    try {
      final response = await _client
          .from('players')
          .select()
          .eq('id', id)
          .single();

      return Player.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Player?> getPlayerByLogin(String login) async {
    try {
      final response = await _client
          .from('players')
          .select()
          .eq('login', login)
          .single();

      return Player.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Player> createPlayer(Player player) async {
    try {
      final response = await _client
          .from('players')
          .insert(player.toJson())
          .select()
          .single();

      return Player.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create player: $e');
    }
  }

  Future<Player> updatePlayer(Player player) async {
    try {
      final response = await _client
          .from('players')
          .update(player.toJson())
          .eq('id', player.id)
          .select()
          .single();

      return Player.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update player: $e');
    }
  }

  Future<void> deletePlayer(String id) async {
    try {
      await _client.from('players').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete player: $e');
    }
  }

  // Training Sessions CRUD operations
  Future<List<TrainingSession>> getTrainingSessions() async {
    try {
      final response = await _client
          .from('training_sessions')
          .select()
          .order('date', ascending: false);

      return (response as List).map((json) => TrainingSession.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch training sessions: $e');
    }
  }

  Future<TrainingSession> createTrainingSession(TrainingSession session) async {
    try {
      final response = await _client
          .from('training_sessions')
          .insert(session.toJson())
          .select()
          .single();

      return TrainingSession.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create training session: $e');
    }
  }

  Future<void> deleteTrainingSession(String id) async {
    try {
      await _client.from('training_sessions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete training session: $e');
    }
  }

  // Attendance CRUD operations
  Future<List<Attendance>> getAttendanceBySession(String sessionId) async {
    try {
      final response = await _client
          .from('attendance')
          .select()
          .eq('session_id', sessionId);

      return (response as List).map((json) => Attendance.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance: $e');
    }
  }

  Future<List<Attendance>> getAttendanceByPlayer(String playerId) async {
    try {
      final response = await _client
          .from('attendance')
          .select()
          .eq('player_id', playerId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Attendance.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch player attendance: $e');
    }
  }

  Future<Attendance> markAttendance(Attendance attendance) async {
    try {
      final response = await _client
          .from('attendance')
          .upsert(attendance.toJson())
          .select()
          .single();

      return Attendance.fromJson(response);
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  Future<void> deleteAttendance(String id) async {
    try {
      await _client.from('attendance').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete attendance: $e');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getTeamStats() async {
    try {
      // Get total players count
      final playersResponse = await _client
          .from('players')
          .select('id')
          .count();

      // Get total training sessions count
      final sessionsResponse = await _client
          .from('training_sessions')
          .select('id')
          .count();

      // Get average attendance
      final attendanceResponse = await _client
          .from('attendance')
          .select('attended')
          .eq('attended', true)
          .count();

      final totalAttendanceResponse = await _client
          .from('attendance')
          .select('id')
          .count();

      final avgAttendance = totalAttendanceResponse > 0 
          ? (attendanceResponse / totalAttendanceResponse * 100).round()
          : 0;

      return {
        'totalPlayers': playersResponse,
        'totalSessions': sessionsResponse,
        'averageAttendance': avgAttendance,
      };
    } catch (e) {
      throw Exception('Failed to fetch team stats: $e');
    }
  }
}