import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final String id;
  final String playerId;
  final String sessionId;
  final bool attended;
  final int pointsEarned;
  final DateTime createdAt;

  const Attendance({
    required this.id,
    required this.playerId,
    required this.sessionId,
    required this.attended,
    required this.pointsEarned,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      sessionId: json['session_id'] as String,
      attended: json['attended'] as bool? ?? true,
      pointsEarned: json['points_earned'] as int? ?? 10,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'session_id': sessionId,
      'attended': attended,
      'points_earned': pointsEarned,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Attendance copyWith({
    String? id,
    String? playerId,
    String? sessionId,
    bool? attended,
    int? pointsEarned,
    DateTime? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      sessionId: sessionId ?? this.sessionId,
      attended: attended ?? this.attended,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        playerId,
        sessionId,
        attended,
        pointsEarned,
        createdAt,
      ];
}