import 'package:flutter/material.dart';
import 'core.dart';
import 'game_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  // Değerler
  int _startScore = 20;
  int _indicatorDrop = 1;
  int _normalDrop = 2;
  int _okeyDrop = 4;

  // İsim Controllerları
  final List<TextEditingController> _nameControllers = [
    TextEditingController(text: "Oyuncu 1"),
    TextEditingController(text: "Oyuncu 2"),
    TextEditingController(text: "Oyuncu 3"),
    TextEditingController(text: "Oyuncu 4"),
  ];
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var node in _focusNodes) node.dispose();
    for (var controller in _nameControllers) controller.dispose();
    super.dispose();
  }

  void _startGame() {
    List<Player> players = _nameControllers.map((ctrl) {
      return Player(
        name: ctrl.text.isEmpty ? "Oyuncu" : ctrl.text,
        score: _startScore,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          players: players,
          indicatorDrop: _indicatorDrop,
          normalDrop: _normalDrop,
          okeyDrop: _okeyDrop,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        title: const Text("Oyun Ayarları", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // Çıkış işlevi
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startScore = 20;
                _indicatorDrop = 1;
                _normalDrop = 2;
                _okeyDrop = 4;
              });
            },
            child: const Text("Sıfırla", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderDark, height: 1),
        ),
      ),

      // --- BODY ---
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100), // Buton için boşluk
        children: [
          // Başlık: Puanlama Kuralları
          _buildSectionHeader(Icons.casino, "Puanlama Kuralları", "Oyunun başlangıç ve bitiş puanlarını belirleyin."),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Başlangıç Puanı Kartı
                _buildCounterCardFull("Başlangıç Puanı", _startScore, (val) => setState(() => _startScore = val)),
                const SizedBox(height: 16),
                // Yan Yana Düşme Miktarları
                Row(
                  children: [
                    Expanded(child: _buildCounterCardSmall("Gösterge", _indicatorDrop, (val) => setState(() => _indicatorDrop = val))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCounterCardSmall("Normal Bitiş", _normalDrop, (val) => setState(() => _normalDrop = val))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCounterCardSmall("Okey / Çift", _okeyDrop, (val) => setState(() => _okeyDrop = val))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Başlık: Oyuncular
          _buildSectionHeader(Icons.groups, "Oyuncular", null),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(4, (index) => _buildPlayerInput(index)),
            ),
          ),
        ],
      ),

      // --- BOTTOM BUTTON ---
      bottomSheet: Container(
        color: AppColors.backgroundDark,
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDark,
            fixedSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 10,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Oyunu Başlat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.play_arrow)
            ],
          ),
        ),
      ),
    );
  }

  // Yardımcı Widget: Section Başlığı
  Widget _buildSectionHeader(IconData icon, String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ]
        ],
      ),
    );
  }

  // Yardımcı Widget: Tam Genişlik Sayaç (Başlangıç Puanı)
  Widget _buildCounterCardFull(String title, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text("Varsayılan: 20", style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          StepperInput(value: value, onChanged: onChanged, height: 56),
        ],
      ),
    );
  }

  // Yardımcı Widget: Yarım Genişlik Sayaç
  Widget _buildCounterCardSmall(String title, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          StepperInput(value: value, onChanged: onChanged, height: 48),
        ],
      ),
    );
  }



  // Yardımcı Widget: Oyuncu Input
  Widget _buildPlayerInput(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: const Icon(Icons.person, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _nameControllers[index],
                  focusNode: _focusNodes[index],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: "İsim Giriniz",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => _focusNodes[index].requestFocus(),
              child: const Icon(Icons.edit, color: AppColors.primary, size: 20),
            ),
          )
        ],
      ),
    );
  }
}

class StepperInput extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double height;

  const StepperInput({
    super.key,
    required this.value,
    required this.onChanged,
    required this.height,
  });

  @override
  State<StepperInput> createState() => _StepperInputState();
}

class _StepperInputState extends State<StepperInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(StepperInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (_controller.text != widget.value.toString()) {
        _controller.text = widget.value.toString();
        // Keep cursor at end if focused? Or just update.
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepperBtn(Icons.remove, () {
            if (widget.value > 1) widget.onChanged(widget.value - 1);
          }),
          Expanded(
            child: Center(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (val) {
                  int? newValue = int.tryParse(val);
                  if (newValue != null) {
                    widget.onChanged(newValue);
                  }
                },
              ),
            ),
          ),
          _stepperBtn(Icons.add, () => widget.onChanged(widget.value + 1)),
        ],
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}