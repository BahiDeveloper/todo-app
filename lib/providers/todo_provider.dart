import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/database_service.dart';

/// Provider pour la gestion des tâches
class TodoProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Todo> _todos = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _selectedCategory;
  TodoFilter _currentFilter = TodoFilter.all;

  List<Todo> get todos => _getFilteredTodos();
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  TodoFilter get currentFilter => _currentFilter;

  /// Charge toutes les tâches
  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _dbService.getAllTodos();
      _todos.sort((a, b) {
        // Trier par: non-complétées d'abord, puis par priorité, puis par date
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (a.priority != b.priority) {
          return b.priority.value.compareTo(a.priority.value);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      await _loadCategories();
    } catch (e) {
      debugPrint('Erreur lors du chargement des tâches: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les catégories
  Future<void> _loadCategories() async {
    _categories = await _dbService.getAllCategories();
  }

  /// Ajoute une nouvelle tâche
  Future<void> addTodo(Todo todo) async {
    try {
      await _dbService.createTodo(todo);
      await loadTodos();
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la tâche: $e');
      rethrow;
    }
  }

  /// Met à jour une tâche
  Future<void> updateTodo(Todo todo) async {
    try {
      await _dbService.updateTodo(todo);
      await loadTodos();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la tâche: $e');
      rethrow;
    }
  }

  /// Supprime une tâche
  Future<void> deleteTodo(int id) async {
    try {
      await _dbService.deleteTodo(id);
      await loadTodos();
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la tâche: $e');
      rethrow;
    }
  }

  /// Toggle le statut d'une tâche
  Future<void> toggleTodoStatus(int id) async {
    try {
      await _dbService.toggleTodoStatus(id);
      await loadTodos();
    } catch (e) {
      debugPrint('Erreur lors du toggle de la tâche: $e');
      rethrow;
    }
  }

  /// Supprime toutes les tâches complétées
  Future<int> deleteCompletedTodos() async {
    try {
      final count = await _dbService.deleteCompletedTodos();
      await loadTodos();
      return count;
    } catch (e) {
      debugPrint('Erreur lors de la suppression des tâches complétées: $e');
      rethrow;
    }
  }

  /// Récupère les statistiques
  Future<Map<String, int>> getStats() async {
    return await _dbService.getStats();
  }

  /// Définit le filtre de catégorie
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Définit le filtre actuel
  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Récupère les tâches filtrées
  List<Todo> _getFilteredTodos() {
    List<Todo> filtered = _todos;

    // Filtre par catégorie
    if (_selectedCategory != null) {
      filtered = filtered
          .where((todo) => todo.category == _selectedCategory)
          .toList();
    }

    // Filtre par statut
    switch (_currentFilter) {
      case TodoFilter.active:
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilter.all:
        break;
    }

    return filtered;
  }

  /// Compte des tâches par filtre
  int get allCount => _todos.length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
}

enum TodoFilter {
  all,
  active,
  completed,
}

extension TodoFilterExtension on TodoFilter {
  String get label {
    switch (this) {
      case TodoFilter.all:
        return 'Toutes';
      case TodoFilter.active:
        return 'Actives';
      case TodoFilter.completed:
        return 'Complétées';
    }
  }
}
