import 'package:flutter/material.dart';
import 'core.dart';
import 'history_service.dart';
import 'setup_page.dart';
import 'game_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  List<GameRecord> _history = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<GameRecord> _selectedRecords = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    List<GameRecord> records = await _historyService.getHistory();
    if (!mounted) return; // DÜZELTME: async sonrası mounted kontrolü
    setState(() {
      _history = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: _isSelectionMode
            ? Text("${_selectedRecords.length} Seçildi",
            style: const TextStyle(fontWeight: FontWeight.bold))
            : const Text("Oyun Geçmişi",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark,
        centerTitle: true,
        leading: _isSelectionMode
            ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              _isSelectionMode = false;
              _selectedRecords.clear();
            }))
            : null,
        actions: _isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              setState(() {
                if (_selectedRecords.length == _history.length) {
                  _selectedRecords.clear();
                } else {
                  _selectedRecords.addAll(_history);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              setState(() {
                _history.removeWhere(
                        (r) => _selectedRecords.contains(r));
                _isSelectionMode = false;
                _selectedRecords.clear();
              });
              await _historyService.saveHistoryList(_history);
            },
          )
        ]
            : [
          if (_history.isNotEmpty)
            IconButton(
                onPressed: () =>
                    setState(() => _isSelectionMode = true),
                icon: const Icon(Icons.checklist))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history,
                size: 64,
                color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text("Henüz oyun yok.",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5))),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final record = _history[index];
          final isSelected = _selectedRecords.contains(record);

          return GestureDetector(
            onTap: () {
              if (_isSelectionMode) {
                setState(() {
                  if (isSelected) {
                    _selectedRecords.remove(record);
                    if (_selectedRecords.isEmpty) {
                      _isSelectionMode = false;
                    }
                  } else {
                    _selectedRecords.add(record);
                  }
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GameDetailPage(record: record)),
                );
              }
            },
            onLongPress: () {
              setState(() {
                _isSelectionMode = true;
                _selectedRecords.add(record);
              });
            },
            child: Card(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? const BorderSide(
                    color: AppColors.primary, width: 2)
                    : BorderSide.none,
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${record.date.day}/${record.date.month}/${record.date.year}",
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withOpacity(0.2),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Kazanan: ${record.winnerName}",
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          const Divider(
                              color: Colors.white12, height: 24),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: record.players
                                .map((p) => Text(
                              "${p.name}: ${p.score}",
                              style: const TextStyle(
                                  color: Colors.white70),
                            ))
                                .toList(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SetupPage()),
          );
          _loadHistory(); // Dönüşte yenile
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.backgroundDark),
        label: const Text("YENİ OYUN",
            style: TextStyle(
                color: AppColors.backgroundDark,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}