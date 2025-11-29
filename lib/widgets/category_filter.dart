import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

/// Widget de filtrage par catégorie
class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Bouton "Toutes"
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Toutes'),
                  selected: provider.selectedCategory == null,
                  onSelected: (_) => provider.setSelectedCategory(null),
                  avatar: provider.selectedCategory == null
                      ? const Icon(Icons.check, size: 18)
                      : null,
                ),
              ),

              // Catégories
              ...provider.categories.map((category) {
                final isSelected = provider.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => provider.setSelectedCategory(
                      isSelected ? null : category,
                    ),
                    avatar: isSelected
                        ? const Icon(Icons.check, size: 18)
                        : Icon(Icons.folder, size: 18, color: Theme.of(context).colorScheme.primary),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
