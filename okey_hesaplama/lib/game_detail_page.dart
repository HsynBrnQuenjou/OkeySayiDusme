
import 'package:flutter/material.dart';
import 'core.dart';

class GameDetailPage extends StatelessWidget {
  final GameRecord record;

  const GameDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    // Group logs by round
    Map<int, List<GameLog>> groupedLogs = {};
    for (var log in record.logs) {
      if (!groupedLogs.containsKey(log.round)) {
        groupedLogs[log.round] = [];
      }
      groupedLogs[log.round]!.add(log);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text("Oyun Detayı (${record.date.day}/${record.date.month})", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Winner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text("KAZANAN", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(record.winnerName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Scoreboard (Final)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Oyun Sonucu", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: record.players.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      Text("${p.score} Puan", style: TextStyle(color: p.name == record.winnerName ? AppColors.primary : Colors.white70, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 24),
            if (record.logs.isNotEmpty) ...[
               const Align(
                alignment: Alignment.centerLeft,
                child: Text("Olay Günlüğü", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              // Logs List
              ...groupedLogs.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${entry.key}. El", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white12, height: 16),
                      ...entry.value.map((log) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(log.message, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )),
                    ],
                  ),
                );
              }),
            ]
          ],
        ),
      ),
    );
  }
}
