import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

/// Service de gestion de la base de données Isar
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;

  /// Initialise la base de données
  Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TodoSchema],
      directory: dir.path,
    );
  }

  /// Récupère l'instance Isar
  Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  /// Crée une nouvelle tâche
  Future<int> createTodo(Todo todo) async {
    return await isar.writeTxn(() async {
      return await isar.todos.put(todo);
    });
  }

  /// Récupère toutes les tâches
  Future<List<Todo>> getAllTodos() async {
    return await isar.todos.where().findAll();
  }

  /// Récupère une tâche par son ID
  Future<Todo?> getTodoById(int id) async {
    return await isar.todos.get(id);
  }

  /// Met à jour une tâche
  Future<void> updateTodo(Todo todo) async {
    await isar.writeTxn(() async {
      await isar.todos.put(todo);
    });
  }

  /// Supprime une tâche
  Future<bool> deleteTodo(int id) async {
    return await isar.writeTxn(() async {
      return await isar.todos.delete(id);
    });
  }

  /// Récupère les tâches par statut
  Future<List<Todo>> getTodosByStatus(bool isCompleted) async {
    return await isar.todos
        .filter()
        .isCompletedEqualTo(isCompleted)
        .findAll();
  }

  /// Récupère les tâches par catégorie
  Future<List<Todo>> getTodosByCategory(String category) async {
    return await isar.todos
        .filter()
        .categoryEqualTo(category)
        .findAll();
  }

  /// Récupère toutes les catégories uniques
  Future<List<String>> getAllCategories() async {
    final todos = await getAllTodos();
    final categories = todos
        .where((todo) => todo.category != null && todo.category!.isNotEmpty)
        .map((todo) => todo.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  /// Stream de toutes les tâches (pour updates en temps réel)
  Stream<List<Todo>> watchAllTodos() {
    return isar.todos.where().watch(fireImmediately: true);
  }

  /// Stream des tâches par statut
  Stream<List<Todo>> watchTodosByStatus(bool isCompleted) {
    return isar.todos
        .filter()
        .isCompletedEqualTo(isCompleted)
        .watch(fireImmediately: true);
  }

  /// Marque une tâche comme complétée/non-complétée
  Future<void> toggleTodoStatus(int id) async {
    final todo = await getTodoById(id);
    if (todo != null) {
      todo.isCompleted = !todo.isCompleted;
      todo.completedAt = todo.isCompleted ? DateTime.now() : null;
      await updateTodo(todo);
    }
  }

  /// Supprime toutes les tâches complétées
  Future<int> deleteCompletedTodos() async {
    return await isar.writeTxn(() async {
      return await isar.todos
          .filter()
          .isCompletedEqualTo(true)
          .deleteAll();
    });
  }

  /// Récupère les statistiques
  Future<Map<String, int>> getStats() async {
    final todos = await getAllTodos();
    final completed = todos.where((t) => t.isCompleted).length;
    final pending = todos.length - completed;
    final urgent = todos.where((t) => t.priority == Priority.urgent && !t.isCompleted).length;

    return {
      'total': todos.length,
      'completed': completed,
      'pending': pending,
      'urgent': urgent,
    };
  }
}
