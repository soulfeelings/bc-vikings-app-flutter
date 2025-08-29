import 'package:equatable/equatable.dart';

class TrainingSession extends Equatable {
  final String id;
  final DateTime date;
  final String title;
  final DateTime createdAt;

  const TrainingSession({
    required this.id,
    required this.date,
    required this.title,
    required this.createdAt,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? 'Тренировка',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Date only
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TrainingSession copyWith({
    String? id,
    DateTime? date,
    String? title,
    DateTime? createdAt,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, date, title, createdAt];
}