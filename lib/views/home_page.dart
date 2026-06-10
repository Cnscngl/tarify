import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../viewmodels/recipe_vm.dart';
import 'add_recipe_page.dart';
import 'recipe_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: const Color(0xFFF29B7E)),
            const SizedBox(width: 8),
          ],
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

  Widget _buildRecentViewedSection(
      BuildContext context,
      List<Recipe> recentRecipes,
      ) {
    if (recentRecipes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Son Görüntülenenler',
          icon: Icons.history,
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: recentRecipes.length,
            itemBuilder: (context, index) {
              final recipe = recentRecipes[index];

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(recipe: recipe),
                    ),
                  );
                  if (context.mounted) {
                    await context.read<RecipeViewModel>().loadRecipes();
                  }
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        recipe.imagePath != null && recipe.imagePath!.isNotEmpty
                            ? Image.file(
                          File(recipe.imagePath!),
                          width: 58,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 58,
                          color: const Color(0xFFFFF1E8),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Color(0xFFF29B7E),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              recipe.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF4A3B34),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, RecipeViewModel vm) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF2DFD1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10D29A7B),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: vm.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Tarif, kategori veya zorluk ara...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFF29B7E)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFEEDCCD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFEEDCCD)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: vm.selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              filled: true,
              fillColor: Colors.white,
            ),
            items: vm.categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                vm.setSelectedCategory(value);
              }
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: vm.selectedDifficulty,
            initialValue: vm.selectedDifficulty,
            decoration: const InputDecoration(
              labelText: 'Zorluk Seviyesi',
              filled: true,
              fillColor: Colors.white,
            ),
            items: vm.difficulties.map((difficulty) {
              return DropdownMenuItem<String>(
                value: difficulty,
                child: Text(difficulty),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                vm.setSelectedDifficulty(value);
              }
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: vm.toggleOnlyFavorites,
                  icon: Icon(
                    vm.showOnlyFavorites
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: vm.showOnlyFavorites
                        ? const Color(0xFFD87979)
                        : const Color(0xFF75665D),
                  ),
                  label: const Text('Favoriler'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: vm.clearFilters,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Temizle'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, RecipeViewModel vm, Recipe recipe) {
    final difficultyColor = _difficultyColor(recipe.difficulty);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailPage(recipe: recipe),
            ),
          );
          await vm.loadRecipes();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              recipe.imagePath != null && recipe.imagePath!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(recipe.imagePath!),
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF2DFD1),
                  ),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 34,
                  color: Color(0xFFF29B7E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3B34),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.category,
                        style: const TextStyle(
                          color: Color(0xFF75665D),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: difficultyColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: difficultyColor.withOpacity(0.18),
                              ),
                            ),
                            child: Text(
                              recipe.difficulty,
                              style: TextStyle(
                                color: difficultyColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF3E3D3),
                              ),
                            ),
                            child: Text(
                              '${recipe.servings} kişilik',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF5B4B44),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  recipe.isFavorite == 1
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: recipe.isFavorite == 1
                      ? const Color(0xFFD87979)
                      : const Color(0xFF9A9088),
                ),
                onPressed: () => vm.toggleFavorite(recipe),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarify'),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(context, vm),
          ),
          SliverToBoxAdapter(
            child: _buildRecentViewedSection(context, vm.recentViewedRecipes),
          ),
          SliverToBoxAdapter(
            child: _buildSectionTitle(
              'Tarifler',
              icon: Icons.menu_book_rounded,
            ),
          ),
          if (vm.recipes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF2DFD1),
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          size: 42,
                          color: Color(0xFFF29B7E),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Gösterilecek tarif bulunamadı.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A3B34),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Filtreleri temizleyebilir veya yeni tarif ekleyebilirsin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF75665D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final recipe = vm.recipes[index];
                  return _buildRecipeCard(context, vm, recipe);
                },
                childCount: vm.recipes.length,
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecipePage()),
          );
          await vm.loadRecipes();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tarif Ekle'),
      ),
    );
  }
}