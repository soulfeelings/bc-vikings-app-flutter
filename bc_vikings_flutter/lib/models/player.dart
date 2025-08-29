import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final int? age;
  final String? position;
  final String login;
  final String? password;
  final int totalPoints;
  final int attendanceCount;
  final int level;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Player({
    required this.id,
    required this.name,
    this.age,
    this.position,
    required this.login,
    this.password,
    required this.totalPoints,
    required this.attendanceCount,
    required this.level,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int?,
      position: json['position'] as String?,
      login: json['login'] as String,
      password: json['password'] as String?,
      totalPoints: json['total_points'] as int? ?? 0,
      attendanceCount: json['attendance_count'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'position': position,
      'login': login,
      'password': password,
      'total_points': totalPoints,
      'attendance_count': attendanceCount,
      'level': level,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Player copyWith({
    String? id,
    String? name,
    int? age,
    String? position,
    String? login,
    String? password,
    int? totalPoints,
    int? attendanceCount,
    int? level,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      position: position ?? this.position,
      login: login ?? this.login,
      password: password ?? this.password,
      totalPoints: totalPoints ?? this.totalPoints,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      level: level ?? this.level,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        position,
        login,
        password,
        totalPoints,
        attendanceCount,
        level,
        avatarUrl,
        createdAt,
        updatedAt,
      ];
}