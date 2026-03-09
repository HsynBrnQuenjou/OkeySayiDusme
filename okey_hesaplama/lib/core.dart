import 'package:flutter/material.dart';

class AppColors {
  // HTML'deki Tailwind konfigürasyonundan alınan renkler:
  static const Color primary = Color(0xFF11D452); // "primary": "#11d452"
  static const Color primaryHover = Color(0xFF0EB545);
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color backgroundDark = Color(0xFF102216); // "background-dark": "#102216"
  static const Color surfaceDark = Color(0xFF1C2E21); // "surface-dark": "#1c2e21"
  static const Color borderDark = Color(0xFF2D4233);
  static const Color textSecondary = Color(0xFF9DB9A6);
  static const Color textWhite = Colors.white;
}

class Player {
  String name;
  int score;
  int lastChange; // "Son: -20" gösterimi için

  Player({
    required this.name,
    required this.score,
    this.lastChange = 0
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      score: json['score'],
    );
  }
}

class GameLog {
  final int round;
  final String message;

  GameLog({required this.round, required this.message});

  Map<String, dynamic> toJson() => {'round': round, 'message': message};

  factory GameLog.fromJson(Map<String, dynamic> json) {
    return GameLog(
      round: json['round'],
      message: json['message'],
    );
  }
}

class GameRecord {
  final DateTime date;
  final String winnerName;
  final List<Player> players;
  final List<GameLog> logs;

  GameRecord({
    required this.date,
    required this.winnerName,
    required this.players,
    required this.logs,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'winnerName': winnerName,
    'players': players.map((p) => p.toJson()).toList(),
    'logs': logs.map((l) => l.toJson()).toList(),
  };

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      date: DateTime.parse(json['date']),
      winnerName: json['winnerName'],
      players: (json['players'] as List).map((i) => Player.fromJson(i)).toList(),
      logs: json['logs'] != null 
        ? (json['logs'] as List).map((i) => GameLog.fromJson(i)).toList()
        : [],
    );
  }
}