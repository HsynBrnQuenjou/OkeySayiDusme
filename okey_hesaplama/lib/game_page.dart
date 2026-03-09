import 'package:flutter/material.dart';
import 'core.dart';
import 'history_service.dart';
import 'setup_page.dart';

class GamePage extends StatefulWidget {
  final List<Player> players;
  final int indicatorDrop;
  final int normalDrop;
  final int okeyDrop;

  const GamePage({
    super.key,
    required this.players,
    required this.indicatorDrop,
    required this.normalDrop,
    required this.okeyDrop,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // İstatistikler
  int _roundCount = 1;
  int _indicatorCount = 0;
  int _normalCount = 0;

  int _okeyCount = 0;
  final List<GameLog> _logs = [];

  // Puan hesaplama
  void _calculateScore(int winnerIndex, bool isOkey) {
    int penalty = isOkey ? widget.okeyDrop : widget.normalDrop;
    setState(() {
      _logs.add(GameLog(
        round: _roundCount,
        message: "${widget.players[winnerIndex].name} ${isOkey ? 'okey/çift' : 'normal'} bitirdi"
      ));
      _roundCount++; // Yeni tura geç
      if (isOkey) {
        _okeyCount++;
      } else {
        _normalCount++;
      }

      for (int i = 0; i < widget.players.length; i++) {
        if (i != winnerIndex) {
          widget.players[i].score -= penalty;
          widget.players[i].lastChange = -penalty; // "Son: -2" gösterimi için
        } else {
          widget.players[i].lastChange = 0;
        }
      }
    });
    Navigator.pop(context);
    _checkGameOver();
  }

  // Gösterge (Ceza düşer ama tur bitmez)
  void _applyIndicator(int index) {
    setState(() {
      _logs.add(GameLog(
        round: _roundCount,
        message: "${widget.players[index].name} gösterge attı"
      ));
      _indicatorCount++;
      // Diğer oyunculardan puan düş
      for (int i = 0; i < widget.players.length; i++) {
        if (i != index) {
          widget.players[i].score -= widget.indicatorDrop;
          widget.players[i].lastChange = -widget.indicatorDrop;
        } else {
          widget.players[i].lastChange = 0;
        }
      }
    });
    Navigator.pop(context);
    _checkGameOver();
  }

  void _checkGameOver() {
    if (widget.players.any((p) => p.score <= 0)) {
      // En yüksek puanlı oyuncuyu bul (Kazanan)
      Player winner = widget.players.reduce((curr, next) => curr.score > next.score ? curr : next);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy Icon / Header
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.emoji_events, size: 64, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Titles
                const Text("OYUN BİTTİ", 
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2)
                ),
                const SizedBox(height: 8),
                const Text("Kazanan belli oldu!", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                
                const SizedBox(height: 32),

                // Winner Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    winner.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 32),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Kaydet
                      GameRecord record = GameRecord(
                        date: DateTime.now(), 
                        winnerName: winner.name, 
                        players: widget.players,
                        logs: _logs,
                      );
                      await HistoryService().saveGame(record);

                      Navigator.pop(ctx);
                      Navigator.pop(context); // Setup'a dön
                      Navigator.pop(context); // History'ye dön (Setup da pop edilmeli mi? Setup -> Game. Game bitince Setup'a dönüyor. History -> Setup -> Game.)
                      // Akış: History -> (push) Setup -> (push) Game.
                      // Game bitti -> Pop (Game) -> Pop (Setup) -> History (reload)
                      // Ancak şu an GamePage'deki flow 'Navigator.pop(context)' Setup'a dönüyor.
                      // Setup'tan da çıkmak gerek.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("YENİ OYUN BAŞLAT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // --- MODAL BOTTOM SHEET (HTML Tasarımı) ---
  void _showWinModal(int index) {
    Player p = widget.players[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tutamaç
              Container(width: 48, height: 6, decoration: BoxDecoration(color: AppColors.borderDark, borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 24),

              // Profil Resmi ve Başlık
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.borderDark,
                  child: Text(p.name[0], style: const TextStyle(fontSize: 24, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text("İşlem Seçin", style: TextStyle(color: AppColors.textSecondary)),

              const SizedBox(height: 24),

              // Buton: Gösterge (Tur Bitmez)
              _buildModalButton(
                title: "Gösterge",
                badge: "-${widget.indicatorDrop} Puan",
                icon: Icons.bolt,
                bgColor: Colors.orange.shade800,
                textColor: Colors.white,
                iconBg: Colors.white24,
                badgeBg: Colors.black26,
                onTap: () => _applyIndicator(index),
              ),

              const SizedBox(height: 12),

              // Buton: Normal Bitti
              _buildModalButton(
                title: "Normal Bitti",
                badge: "-${widget.normalDrop} Puan",
                icon: Icons.check_circle,
                bgColor: AppColors.primary,
                textColor: AppColors.backgroundDark,
                iconBg: Colors.black12,
                badgeBg: Colors.black26,
                onTap: () => _calculateScore(index, false),
              ),

              const SizedBox(height: 12),

              // Buton: Okey/Çift Bitti
              _buildModalButton(
                title: "Okey / Çift Bitti",
                badge: "-${widget.okeyDrop} Puan",
                icon: Icons.star,
                bgColor: AppColors.backgroundDark,
                textColor: Colors.white,
                iconBg: AppColors.primary.withOpacity(0.1),
                badgeBg: Colors.white10,
                borderColor: AppColors.borderDark,
                iconColor: AppColors.primary,
                onTap: () => _calculateScore(index, true),
              ),

              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İptal", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalButton({
    required String title, required String badge, required IconData icon,
    required Color bgColor, required Color textColor, required Color iconBg,
    required Color badgeBg, required VoidCallback onTap,
    Color? borderColor, Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor ?? textColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
              child: Text(badge, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lideri bul
    int maxScore = widget.players.map((e) => e.score).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Skor Tablosu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white10),
            child: IconButton(
              icon: const Icon(Icons.settings, color: AppColors.textSecondary),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Oyun devam ederken ayarlar değiştirilemez."))
              ),// Ayarlara git (Pop yapma)
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),

      // --- BODY ---
      body: Column(
        children: [
          // Info Bar (Tur ve İstatistikler)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withOpacity(0.5),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem("TUR", "$_roundCount", Icons.refresh),
                _buildStatItem("GÖS", "$_indicatorCount", Icons.bolt),
                _buildStatItem("NORMAL", "$_normalCount", Icons.check_circle_outline),
                _buildStatItem("OKEY", "$_okeyCount", Icons.star_outline),
              ],
            ),
          ),

          // Oyuncu Listesi
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.players.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                Player p = widget.players[index];
                int leaderIndex = widget.players.indexWhere((p) => p.score == maxScore);
                bool isLeader = index == leaderIndex;

                return GestureDetector(
                  onTap: () => _showWinModal(index),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: isLeader
                              ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 2)
                              : Border.all(color: Colors.white10),
                          boxShadow: isLeader
                              ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10)]
                              : [],
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.backgroundDark,
                                  child: Text(p.name[0], style: const TextStyle(color: AppColors.textSecondary)),
                                ),
                                const Positioned(
                                  bottom: 0, right: 0,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppColors.primary,
                                    child: Icon(Icons.edit, size: 12, color: AppColors.backgroundDark),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(width: 16),
                            // İsim ve Son Durum
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: TextStyle(color: isLeader ? AppColors.primary : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(
                                      "Son: ${p.lastChange > 0 ? '+' : ''}${p.lastChange}",
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)
                                  ),
                                ],
                              ),
                            ),
                            // Puan
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${p.score}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: isLeader ? AppColors.primary : Colors.white70)),
                                const Text("PUAN", style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2)),
                          ],
                        ),
                      ),
                      // Lider Rozeti (HTML'deki gibi sağ üstte değil sol üstte ya da isim yanında olabilir ama HTML sağ üst vermiş)
                      if (isLeader)
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.leaderboard, size: 14, color: AppColors.backgroundDark),
                                SizedBox(width: 4),
                                Text("Lider", style: TextStyle(color: AppColors.backgroundDark, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          "$label: ",
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}