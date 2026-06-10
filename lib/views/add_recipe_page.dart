import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../viewmodels/recipe_vm.dart';

class AddRecipePage extends StatefulWidget {
  final Recipe? recipe;

  const AddRecipePage({
    super.key,
    this.recipe,
  });

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _prepMinutesController = TextEditingController();
  final _cookMinutesController = TextEditingController();
  final _servingsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _tipsController = TextEditingController();
  final _notesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  String _selectedDifficulty = 'Kolay';

  bool get _isEditMode => widget.recipe != null;

  final List<String> _difficultyOptions = const [
    'Kolay',
    'Orta',
    'Zor',
  ];

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      final recipe = widget.recipe!;
      _titleController.text = recipe.title == 'İsimsiz Tarif' ? '' : recipe.title;
      _categoryController.text = recipe.category;
      _prepMinutesController.text =
      recipe.prepMinutes == 0 ? '' : recipe.prepMinutes.toString();
      _cookMinutesController.text =
      recipe.cookMinutes == 0 ? '' : recipe.cookMinutes.toString();
      _servingsController.text =
      recipe.servings == 0 ? '' : recipe.servings.toString();
      _ingredientsController.text = recipe.ingredients;
      _stepsController.text = recipe.steps;
      _tipsController.text = recipe.tips;
      _notesController.text = recipe.notes;
      _selectedImagePath = recipe.imagePath;
      _selectedDifficulty = recipe.difficulty;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _prepMinutesController.dispose();
    _cookMinutesController.dispose();
    _servingsController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _tipsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final recipe = widget.recipe;

    if (recipe == null) {
      return _titleController.text.trim().isNotEmpty ||
          _categoryController.text.trim().isNotEmpty ||
          _prepMinutesController.text.trim().isNotEmpty ||
          _cookMinutesController.text.trim().isNotEmpty ||
          _servingsController.text.trim().isNotEmpty ||
          _ingredientsController.text.trim().isNotEmpty ||
          _stepsController.text.trim().isNotEmpty ||
          _tipsController.text.trim().isNotEmpty ||
          _notesController.text.trim().isNotEmpty ||
          _selectedImagePath != null ||
          _selectedDifficulty != 'Kolay';
    }

    return _titleController.text.trim() !=
        (recipe.title == 'İsimsiz Tarif' ? '' : recipe.title) ||
        _categoryController.text.trim() != recipe.category ||
        _prepMinutesController.text.trim() !=
            (recipe.prepMinutes == 0 ? '' : recipe.prepMinutes.toString()) ||
        _cookMinutesController.text.trim() !=
            (recipe.cookMinutes == 0 ? '' : recipe.cookMinutes.toString()) ||
        _servingsController.text.trim() !=
            (recipe.servings == 0 ? '' : recipe.servings.toString()) ||
        _ingredientsController.text.trim() != recipe.ingredients ||
        _stepsController.text.trim() != recipe.steps ||
        _tipsController.text.trim() != recipe.tips ||
        _notesController.text.trim() != recipe.notes ||
        _selectedImagePath != recipe.imagePath ||
        _selectedDifficulty != recipe.difficulty;
  }

  bool get _isCompletelyEmpty {
    return _titleController.text.trim().isEmpty &&
        _categoryController.text.trim().isEmpty &&
        _prepMinutesController.text.trim().isEmpty &&
        _cookMinutesController.text.trim().isEmpty &&
        _servingsController.text.trim().isEmpty &&
        _ingredientsController.text.trim().isEmpty &&
        _stepsController.text.trim().isEmpty &&
        _tipsController.text.trim().isEmpty &&
        _notesController.text.trim().isEmpty &&
        _selectedImagePath == null;
  }

  int _parseIntOrZero(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (_isCompletelyEmpty) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? 'İsimsiz Tarif'
        : _titleController.text.trim();

    final recipe = Recipe(
      id: widget.recipe?.id,
      title: title,
      category: _categoryController.text.trim(),
      difficulty: _selectedDifficulty,
      prepMinutes: _parseIntOrZero(_prepMinutesController.text),
      cookMinutes: _parseIntOrZero(_cookMinutesController.text),
      servings: _parseIntOrZero(_servingsController.text),
      ingredients: _ingredientsController.text.trim(),
      steps: _stepsController.text.trim(),
      tips: _tipsController.text.trim(),
      notes: _notesController.text.trim(),
      imagePath: _selectedImagePath,
      isFavorite: widget.recipe?.isFavorite ?? 0,
    );

    final vm = context.read<RecipeViewModel>();

    if (_isEditMode) {
      await vm.updateRecipe(recipe);
    } else {
      await vm.addRecipe(recipe);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<bool> _handleExit() async {
    if (!_hasChanges) return true;

    if (_isCompletelyEmpty) {
      return true;
    }

    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Değişiklikler kaydedilsin mi?'),
          content: const Text(
            'Sayfadan çıkmadan önce yaptığınız değişiklikleri kaydetmek ister misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'discard'),
              child: const Text('Kaydetmeden Çık'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'save'),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (choice == 'save') {
      await _saveRecipe();
      return false;
    }

    if (choice == 'discard') {
      return true;
    }

    return false;
  }

  Widget _buildSectionTitle(String title, IconData icon) {
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

  Widget _buildFormCard({
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
            _buildSectionTitle(title, icon),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedImagePath == null)
            Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFFFFF1E8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.image_outlined,
                    size: 44,
                    color: Color(0xFFF29B7E),
                  ),
                  SizedBox(height: 10),
                  Text('Henüz görsel seçilmedi'),
                ],
              ),
            )
          else
            Image.file(
              File(_selectedImagePath!),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(
                _isEditMode ? 'Görseli Değiştir' : 'Galeriden Görsel Seç',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedDifficulty,
        decoration: const InputDecoration(
          labelText: 'Zorluk Seviyesi',
        ),
        items: _difficultyOptions.map((difficulty) {
          return DropdownMenuItem<String>(
            value: difficulty,
            child: Text(difficulty),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedDifficulty = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditMode ? 'Tarifi Düzenle' : 'Yeni Tarif Oluştur',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Color(0xFF4A3B34),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'İstersen tüm alanları doldur, istersen sadece gerekli gördüklerini yaz. Tamamen boş çıkarsan tarif kaydedilmez.',
            style: TextStyle(
              color: Color(0xFF75665D),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _saveRecipe,
          icon: const Icon(Icons.save_outlined),
          label: Text(_isEditMode ? 'Güncelle' : 'Kaydet'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await _handleExit();
        if (shouldLeave && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Tarif Düzenle' : 'Tarif Ekle'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldLeave = await _handleExit();
              if (shouldLeave && mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderInfo(),
                _buildImagePreview(),
                _buildFormCard(
                  title: 'Temel Bilgiler',
                  icon: Icons.info_outline,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Tarif Adı',
                      ),
                      _buildTextField(
                        controller: _categoryController,
                        label: 'Kategori',
                      ),
                      _buildDifficultyField(),
                    ],
                  ),
                ),
                _buildFormCard(
                  title: 'Süre ve Porsiyon',
                  icon: Icons.schedule_outlined,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _prepMinutesController,
                        label: 'Hazırlık Süresi (dk)',
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        controller: _cookMinutesController,
                        label: 'Pişirme Süresi (dk)',
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        controller: _servingsController,
                        label: 'Porsiyon',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                _buildFormCard(
                  title: 'Malzemeler',
                  icon: Icons.shopping_basket_outlined,
                  child: _buildTextField(
                    controller: _ingredientsController,
                    label: 'Malzemeleri satır satır yaz',
                    maxLines: 7,
                  ),
                ),
                _buildFormCard(
                  title: 'Yapılış Adımları',
                  icon: Icons.format_list_numbered_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İstersen süre etiketi kullanabilirsin. Örnek: [10 dk] Soğanı kavur.',
                        style: TextStyle(
                          color: Color(0xFF75665D),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _stepsController,
                        label: 'Adımları satır satır yaz',
                        maxLines: 7,
                      ),
                    ],
                  ),
                ),
                _buildFormCard(
                  title: 'Ek Notlar',
                  icon: Icons.sticky_note_2_outlined,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _tipsController,
                        label: 'Püf Noktaları',
                        maxLines: 4,
                      ),
                      _buildTextField(
                        controller: _notesController,
                        label: 'Kişisel Notlar',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}