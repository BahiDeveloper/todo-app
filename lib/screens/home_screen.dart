import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/stats_card.dart';
import '../widgets/category_filter.dart';

/// Écran principal de l'application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les tâches au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Mes Tâches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'delete_completed') {
                final provider = context.read<TodoProvider>();
                final count = await provider.deleteCompletedTodos();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$count tâche(s) supprimée(s)'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_completed',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20),
                    SizedBox(width: 8),
                    Text('Supprimer les complétées'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Carte de statistiques
              const StatsCard(),

              // Filtres de catégorie
              const CategoryFilter(),

              // Filtres de statut
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      TodoFilter.all,
                      provider.allCount,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      TodoFilter.active,
                      provider.activeCount,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      TodoFilter.completed,
                      provider.completedCount,
                    ),
                  ],
                ),
              ),

              // Liste des tâches
              Expanded(
                child: provider.todos.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.todos.length,
                        itemBuilder: (context, index) {
                          final todo = provider.todos[index];
                          return TodoCard(
                            todo: todo,
                            key: ValueKey(todo.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tâche'),
        elevation: 4,
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, TodoFilter filter, int count) {
    final provider = context.watch<TodoProvider>();
    final isSelected = provider.currentFilter == filter;

    return Expanded(
      child: FilterChip(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(filter.label),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => provider.setFilter(filter),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune tâche',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour ajouter une tâche',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }
}
