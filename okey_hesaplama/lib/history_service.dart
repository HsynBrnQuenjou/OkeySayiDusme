
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'core.dart';

class HistoryService {
  static const String _key = 'game_history';

  // Geçmişi Getir
  Future<List<GameRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => GameRecord.fromJson(e)).toList();
  }

  // Oyun Kaydet
  Future<void> saveGame(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<GameRecord> currentHistory = await getHistory();
    
    // En başa ekle (En yeni en üstte)
    currentHistory.insert(0, record);

    String jsonString = jsonEncode(currentHistory.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  // Geçmişi Temizle
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Listeyi komple kaydet (Silme işleminden sonra vb.)
  Future<void> saveHistoryList(List<GameRecord> history) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
