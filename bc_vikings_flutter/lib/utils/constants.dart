import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> positions = [
    'Point Guard',
    'Shooting Guard', 
    'Small Forward',
    'Power Forward',
    'Center',
  ];

  static const Map<int, String> levelNames = {
    1: 'Новичок',
    2: 'Любитель', 
    3: 'Игрок',
    4: 'Звезда',
    5: 'Легенда',
  };

  static const Map<int, Color> levelColors = {
    1: Colors.grey,
    2: Colors.blue,
    3: Colors.purple,
    4: Colors.orange,
    5: Colors.amber,
  };

  static const String coachPassword = 'vikings2024';
  
  static const int defaultPointsPerTraining = 10;
  
  // Level thresholds
  static const Map<int, int> levelThresholds = {
    1: 0,
    2: 50,
    3: 150,
    4: 300,
    5: 500,
  };

  static int calculateLevel(int totalPoints) {
    if (totalPoints >= levelThresholds[5]!) return 5;
    if (totalPoints >= levelThresholds[4]!) return 4;
    if (totalPoints >= levelThresholds[3]!) return 3;
    if (totalPoints >= levelThresholds[2]!) return 2;
    return 1;
  }
}

class AppStrings {
  static const String appTitle = 'BC Vikings';
  static const String playerMode = 'Режим игрока';
  static const String coachMode = 'Режим тренера';
  static const String login = 'Войти';
  static const String logout = 'Выход';
  static const String loading = 'Загрузка...';
  static const String error = 'Ошибка';
  static const String success = 'Успешно';
  static const String cancel = 'Отмена';
  static const String save = 'Сохранить';
  static const String delete = 'Удалить';
  static const String edit = 'Редактировать';
  static const String add = 'Добавить';
  
  // Player specific
  static const String playerLogin = 'Логин игрока';
  static const String playerPassword = 'Пароль игрока';
  static const String playerStats = 'Статистика игрока';
  static const String totalPoints = 'Всего очков';
  static const String level = 'Уровень';
  static const String attendance = 'Посещения';
  
  // Coach specific
  static const String coachPassword = 'Пароль тренера';
  static const String dashboard = 'Панель управления';
  static const String players = 'Игроки';
  static const String trainingSessions = 'Тренировки';
  static const String addPlayer = 'Добавить игрока';
  static const String addTraining = 'Добавить тренировку';
  static const String markAttendance = 'Отметить посещаемость';
  
  // Form fields
  static const String name = 'Имя';
  static const String age = 'Возраст';
  static const String position = 'Позиция';
  static const String password = 'Пароль';
  static const String title = 'Название';
  static const String date = 'Дата';
  
  // Validation messages
  static const String fieldRequired = 'Это поле обязательно';
  static const String invalidCredentials = 'Неверные учетные данные';
  static const String loginExists = 'Логин уже существует';
}