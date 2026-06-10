import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../viewmodels/recipe_vm.dart';
import 'add_recipe_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final FlutterTts _flutterTts = FlutterTts();
  late final TextEditingController _servingsController;

  double _speechRate = 0.4;
  bool _isSpeaking = false;
  bool _isPaused = false;

  List<String> _stepList = [];
  int _currentStepIndex = 0;
  int _selectedServings = 1;
  List<bool> _checkedIngredients = [];

  @override
  void initState() {
    super.initState();
    _selectedServings = widget.recipe.servings;
    _servingsController = TextEditingController(
      text: _selectedServings.toString(),
    );
    _stepList = _parseSteps(widget.recipe.steps);
    _checkedIngredients = List.generate(
      _ingredientLines().length,
          (_) => false,
    );

    Future.microtask(() {
      if (widget.recipe.id != null) {
        context.read<RecipeViewModel>().markRecipeAsViewed(widget.recipe.id!);
      }
    });

    _initTts();
  }

  List<String> _parseSteps(String rawSteps) {
    return rawSteps
        .split('\n')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  String? _extractStepDuration(String step) {
    final match = RegExp(r'^\[(.+?)\]\s*').firstMatch(step.trim());
    return match?.group(1)?.trim();
  }

  String _extractStepContent(String step) {
    final trimmed = step.trim();
    final match = RegExp(r'^\[(.+?)\]\s*(.*)$').firstMatch(trimmed);

    if (match != null) {
      final content = match.group(2)?.trim() ?? '';
      return content.isEmpty ? trimmed : content;
    }

    return trimmed;
  }

  String _buildSpeechTextForStep(int index) {
    final rawStep = _stepList[index];
    final duration = _extractStepDuration(rawStep);
    final content = _extractStepContent(rawStep);

    if (duration != null && duration.isNotEmpty) {
      return 'Adım ${index + 1}. Süre: $duration. $content';
    }

    return 'Adım ${index + 1}. $content';
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Kolay':
        return const Color(0xFF7DAA72);
      case 'Orta':
        return const Color(0xFFE1A85B);
      case 'Zor':
        return const Color(0xFFD87979);
      default:
        return const Color(0xFF9A9088);
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('tr-TR');
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = true;
        _isPaused = false;
      });
    });

    _flutterTts.setCompletionHandler(() async {
      if (!mounted) return;
      if (_isPaused) return;

      if (_currentStepIndex < _stepList.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
        await _speakCurrentStep();
      } else {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
        });
      }
    });

    _flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((message) {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        _isPaused = false;
      });
    });
  }

  Future<void> _speakCurrentStep() async {
    if (_stepList.isEmpty) return;

    final text = _buildSpeechTextForStep(_currentStepIndex);

    await _flutterTts.stop();
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.speak(text);
  }

  Future<void> _startReading() async {
    if (_stepList.isEmpty) return;

    setState(() {
      _currentStepIndex = 0;
      _isPaused = false;
    });

    await _speakCurrentStep();
  }

  Future<void> _startReadingFromStep(int index) async {
    if (_stepList.isEmpty) return;
    if (index < 0 || index >= _stepList.length) return;

    setState(() {
      _currentStepIndex = index;
      _isPaused = false;
    });

    await _speakCurrentStep();
  }

  Future<void> _pauseReading() async {
    await _flutterTts.stop();
    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
      _isPaused = true;
    });
  }

  Future<void> _resumeReading() async {
    if (_stepList.isEmpty) return;

    setState(() {
      _isPaused = false;
    });

    await _speakCurrentStep();
  }

  Future<void> _stopReading() async {
    await _flutterTts.stop();
    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
      _isPaused = false;
      _currentStepIndex = 0;
    });
  }

  Future<void> _goToNextStep() async {
    if (_stepList.isEmpty) return;
    if (_currentStepIndex >= _stepList.length - 1) return;

    setState(() {
      _currentStepIndex++;
      _isPaused = false;
    });

    await _speakCurrentStep();
  }

  Future<void> _goToPreviousStep() async {
    if (_stepList.isEmpty) return;
    if (_currentStepIndex <= 0) return;

    setState(() {
      _currentStepIndex--;
      _isPaused = false;
    });

    await _speakCurrentStep();
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tarifi sil'),
          content: const Text(
            'Bu tarifi silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await context.read<RecipeViewModel>().deleteRecipe(widget.recipe.id!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _syncServingsController() {
    if (_servingsController.text != _selectedServings.toString()) {
      _servingsController.text = _selectedServings.toString();
      _servingsController.selection = TextSelection.fromPosition(
        TextPosition(offset: _servingsController.text.length),
      );
    }
  }

  void _updateServingsFromInput(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null && parsed > 0) {
      setState(() {
        _selectedServings = parsed;
      });
    }
  }

  void _validateServingsInput() {
    final parsed = int.tryParse(_servingsController.text.trim());

    if (parsed == null || parsed <= 0) {
      _syncServingsController();
      return;
    }

    if (parsed != _selectedServings) {
      setState(() {
        _selectedServings = parsed;
      });
    }

    _syncServingsController();
  }

  String _speedLabel() {
    if (_speechRate <= 0.25) return 'Çok yavaş';
    if (_speechRate <= 0.45) return 'Yavaş';
    if (_speechRate <= 0.7) return 'Normal';
    if (_speechRate <= 0.9) return 'Hızlı';
    return 'Çok hızlı';
  }

  double _roundSmart(double value) {
    return (value * 100).round() / 100;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return _roundSmart(value).toString();
  }

  bool _isIngredientHeader(String line) {
    return line.trim().endsWith(':');
  }

  bool _startsWithNumber(String line) {
    return RegExp(r'^(\d+([.,]\d+)?)\s+').hasMatch(line.trim());
  }

  bool _isCheckableIngredient(String line) {
    return !_isIngredientHeader(line);
  }

  String _scaleIngredientLine(String line) {
    final ratio = _selectedServings / widget.recipe.servings;
    final trimmed = line.trim();

    if (trimmed.isEmpty) return trimmed;
    if (_isIngredientHeader(trimmed)) return trimmed;
    if (!_startsWithNumber(trimmed)) return trimmed;

    final regex = RegExp(r'^(\d+([.,]\d+)?)\s+(.*)$');
    final match = regex.firstMatch(trimmed);

    if (match == null) {
      return trimmed;
    }

    final originalNumberText = match.group(1)!;
    final restOfLine = match.group(3)!;

    final originalNumber =
    double.tryParse(originalNumberText.replaceAll(',', '.'));

    if (originalNumber == null) {
      return trimmed;
    }

    final newValue = originalNumber * ratio;
    return '${_formatNumber(newValue)} $restOfLine';
  }

  List<String> _ingredientLines() {
    return widget.recipe.ingredients
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  void _ensureIngredientChecksLength() {
    final linesLength = _ingredientLines().length;

    if (_checkedIngredients.length != linesLength) {
      _checkedIngredients = List.generate(linesLength, (_) => false);
    }
  }

  int _countCheckableIngredients() {
    final lines = _ingredientLines();
    return lines.where(_isCheckableIngredient).length;
  }

  int _countCompletedIngredients() {
    final lines = _ingredientLines();
    int completed = 0;

    for (int i = 0; i < lines.length; i++) {
      if (_isCheckableIngredient(lines[i]) && _checkedIngredients[i]) {
        completed++;
      }
    }

    return completed;
  }

  double _ingredientProgress() {
    final total = _countCheckableIngredients();
    if (total == 0) return 0;
    return _countCompletedIngredients() / total;
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFE4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF2DFD1)),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFF29B7E)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3B34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? textColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFFFF1E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor ?? const Color(0xFFF2DFD1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor ?? const Color(0xFF75665D)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: textColor ?? const Color(0xFF5B4B44),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(title, icon),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTextSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return _buildSectionCard(
      title: title,
      icon: icon,
      child: Text(
        content.isEmpty ? '-' : content,
        style: const TextStyle(
          fontSize: 14.5,
          height: 1.45,
          color: Color(0xFF5B4B44),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.recipe.imagePath == null || widget.recipe.imagePath!.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Container(
          height: 220,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF1E8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.restaurant_menu,
                size: 42,
                color: Color(0xFFF29B7E),
              ),
              SizedBox(height: 10),
              Text('Bu tarif için görsel eklenmemiş'),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Image.file(
        File(widget.recipe.imagePath!),
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRecipeSummaryCard() {
    final recipe = widget.recipe;
    final totalMinutes = recipe.prepMinutes + recipe.cookMinutes;
    final difficultyColor = _difficultyColor(recipe.difficulty);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Color(0xFF4A3B34),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.category_outlined,
                  label: recipe.category,
                ),
                _buildInfoChip(
                  icon: Icons.signal_cellular_alt,
                  label: recipe.difficulty,
                  textColor: difficultyColor,
                  backgroundColor: difficultyColor.withOpacity(0.14),
                  borderColor: difficultyColor.withOpacity(0.18),
                ),
                _buildInfoChip(
                  icon: Icons.schedule_outlined,
                  label: 'Toplam $totalMinutes dk',
                ),
                _buildInfoChip(
                  icon: Icons.people_alt_outlined,
                  label: '${recipe.servings} kişilik',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF2E3D6)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.timer_outlined,
                  label: 'Hazırlık ${recipe.prepMinutes} dk',
                ),
                _buildInfoChip(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Pişirme ${recipe.cookMinutes} dk',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTtsCard() {
    return _buildSectionCard(
      title: 'Sesli Okuma',
      icon: Icons.record_voice_over_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: (!_isSpeaking && !_isPaused) ? _startReading : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Başlat'),
              ),
              ElevatedButton.icon(
                onPressed: _isSpeaking ? _pauseReading : null,
                icon: const Icon(Icons.pause),
                label: const Text('Duraklat'),
              ),
              ElevatedButton.icon(
                onPressed: _isPaused ? _resumeReading : null,
                icon: const Icon(Icons.play_circle),
                label: const Text('Devam Et'),
              ),
              OutlinedButton.icon(
                onPressed: (_isSpeaking || _isPaused) ? _stopReading : null,
                icon: const Icon(Icons.stop),
                label: const Text('Durdur'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _goToPreviousStep,
                icon: const Icon(Icons.skip_previous),
                label: const Text('Önceki Adım'),
              ),
              OutlinedButton.icon(
                onPressed: _goToNextStep,
                icon: const Icon(Icons.skip_next),
                label: const Text('Sonraki Adım'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Okuma Hızı',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A3B34),
            ),
          ),
          Text(
            '${_speedLabel()} (${_speechRate.toStringAsFixed(2)})',
            style: const TextStyle(
              color: Color(0xFF75665D),
            ),
          ),
          Slider(
            value: _speechRate,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: _speechRate.toStringAsFixed(2),
            activeColor: const Color(0xFFF29B7E),
            onChanged: (value) async {
              setState(() {
                _speechRate = value;
              });

              await _flutterTts.setSpeechRate(_speechRate);

              if (_isSpeaking) {
                await _speakCurrentStep();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepTrackerCard() {
    if (_stepList.isEmpty) {
      return _buildSectionCard(
        title: 'Aktif Adım',
        icon: Icons.playlist_play_rounded,
        child: const Text('Adım bilgisi bulunamadı.'),
      );
    }

    final currentRawStep = _stepList[_currentStepIndex];
    final currentDuration = _extractStepDuration(currentRawStep);
    final currentContent = _extractStepContent(currentRawStep);

    return _buildSectionCard(
      title: 'Aktif Adım',
      icon: Icons.playlist_play_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adım ${_currentStepIndex + 1} / ${_stepList.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A3B34),
            ),
          ),
          if (currentDuration != null && currentDuration.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoChip(
              icon: Icons.schedule,
              label: currentDuration,
              textColor: const Color(0xFF6C8CBF),
              backgroundColor: const Color(0xFFEAF2FF),
              borderColor: const Color(0xFFD5E5FF),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF2DFD1)),
            ),
            child: Text(
              currentContent,
              style: const TextStyle(
                fontSize: 15,
                height: 1.35,
                color: Color(0xFF5B4B44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingsCard() {
    _syncServingsController();

    return _buildSectionCard(
      title: 'Porsiyon Ayarı',
      icon: Icons.people_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orijinal Porsiyon: ${widget.recipe.servings} kişilik',
            style: const TextStyle(color: Color(0xFF75665D)),
          ),
          const SizedBox(height: 4),
          Text(
            'Güncel Porsiyon: $_selectedServings kişilik',
            style: const TextStyle(
              color: Color(0xFF4A3B34),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton(
                onPressed: _selectedServings > 1
                    ? () {
                  setState(() {
                    _selectedServings--;
                  });
                  _syncServingsController();
                }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _servingsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    hintText: 'Kişi',
                  ),
                  onChanged: _updateServingsFromInput,
                  onEditingComplete: () {
                    _validateServingsInput();
                    FocusScope.of(context).unfocus();
                  },
                  onSubmitted: (_) => _validateServingsInput(),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedServings++;
                  });
                  _syncServingsController();
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScaledIngredientsCard() {
    final lines = _ingredientLines();
    _ensureIngredientChecksLength();

    final completed = _countCompletedIngredients();
    final total = _countCheckableIngredients();
    final progress = _ingredientProgress();

    return _buildSectionCard(
      title: 'Malzemeler',
      icon: Icons.shopping_basket_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hazırlanan Malzeme: $completed / $total',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A3B34),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: const Color(0xFFF4E7DB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF29B7E)),
          ),
          const SizedBox(height: 14),
          if (lines.isEmpty)
            const Text('-')
          else
            ...List.generate(lines.length, (index) {
              final line = lines[index];
              final isHeader = _isIngredientHeader(line);
              final displayLine = _scaleIngredientLine(line);

              if (isHeader) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF2DFD1)),
                  ),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF4A3B34),
                    ),
                  ),
                );
              }

              return CheckboxListTile(
                value: _checkedIngredients[index],
                activeColor: const Color(0xFFF29B7E),
                onChanged: (value) {
                  setState(() {
                    _checkedIngredients[index] = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  displayLine,
                  style: TextStyle(
                    decoration: _checkedIngredients[index]
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: _checkedIngredients[index]
                        ? const Color(0xFF9A9088)
                        : const Color(0xFF5B4B44),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAllStepsCard() {
    if (_stepList.isEmpty) {
      return _buildSimpleTextSection(
        title: 'Yapılış Adımları',
        icon: Icons.format_list_numbered_rounded,
        content: widget.recipe.steps,
      );
    }

    return _buildSectionCard(
      title: 'Yapılış Adımları',
      icon: Icons.format_list_numbered_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İstediğin adıma dokunarak o adımdan sesli okumayı başlatabilirsin.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF75665D),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_stepList.length, (index) {
            final isActive = index == _currentStepIndex;
            final rawStep = _stepList[index];
            final duration = _extractStepDuration(rawStep);
            final content = _extractStepContent(rawStep);

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await _startReadingFromStep(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFFF1E8)
                      : const Color(0xFFFFFDFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFF2C9AE)
                        : const Color(0xFFF2E3D6),
                    width: isActive ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isActive
                          ? const Color(0xFFF29B7E)
                          : const Color(0xFFFFEFE4),
                      foregroundColor: isActive
                          ? Colors.white
                          : const Color(0xFF75665D),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (duration != null && duration.isNotEmpty) ...[
                            _buildInfoChip(
                              icon: Icons.schedule,
                              label: duration,
                              textColor: const Color(0xFF6C8CBF),
                              backgroundColor: const Color(0xFFEAF2FF),
                              borderColor: const Color(0xFFD5E5FF),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            content,
                            style: TextStyle(
                              height: 1.4,
                              color: const Color(0xFF5B4B44),
                              fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.volume_up_outlined,
                      size: 18,
                      color: isActive
                          ? const Color(0xFFF29B7E)
                          : const Color(0xFF9A9088),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddRecipePage(recipe: recipe),
                ),
              );

              if (result == true && context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              await context.read<RecipeViewModel>().toggleFavorite(recipe);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            icon: Icon(
              recipe.isFavorite == 1 ? Icons.favorite : Icons.favorite_border,
              color: recipe.isFavorite == 1
                  ? const Color(0xFFD87979)
                  : null,
            ),
          ),
          IconButton(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImage(),
          _buildRecipeSummaryCard(),
          _buildTtsCard(),
          _buildStepTrackerCard(),
          _buildServingsCard(),
          _buildScaledIngredientsCard(),
          _buildAllStepsCard(),
          _buildSimpleTextSection(
            title: 'Püf Noktaları',
            icon: Icons.lightbulb_outline,
            content: recipe.tips,
          ),
          _buildSimpleTextSection(
            title: 'Kişisel Notlar',
            icon: Icons.sticky_note_2_outlined,
            content: recipe.notes,
          ),
        ],
      ),
    );
  }
}