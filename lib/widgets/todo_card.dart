import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'edit_todo_dialog.dart';

/// Widget de carte pour afficher une tâche
class TodoCard extends StatelessWidget {
  final Todo todo;

  const TodoCard({
    required this.todo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: todo.isCompleted ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getPriorityColor(todo.priority).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showEditDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => _toggleStatus(context),
                shape: const CircleBorder(),
              ),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.isCompleted
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    // Description
                    if (todo.description != null &&
                        todo.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Tags et infos
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // Priorité
                        _buildChip(
                          context,
                          todo.priority.label,
                          _getPriorityColor(todo.priority),
                          Icons.flag,
                        ),

                        // Catégorie
                        if (todo.category != null &&
                            todo.category!.isNotEmpty)
                          _buildChip(
                            context,
                            todo.category!,
                            Theme.of(context).colorScheme.secondary,
                            Icons.folder,
                          ),

                        // Date d'échéance
                        if (todo.dueDate != null)
                          _buildChip(
                            context,
                            _formatDate(todo.dueDate!),
                            _isOverdue(todo.dueDate!)
                                ? Colors.red
                                : Theme.of(context).colorScheme.tertiary,
                            Icons.calendar_today,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bouton supprimer
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: () => _deleteTodo(context),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.deepOrange;
      case Priority.urgent:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return "Aujourd'hui";
    } else if (dateToCheck == today.add(const Duration(days: 1))) {
      return 'Demain';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else {
      return DateFormat('dd MMM', 'fr_FR').format(date);
    }
  }

  bool _isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    return dateToCheck.isBefore(today) && !todo.isCompleted;
  }

  void _toggleStatus(BuildContext context) {
    context.read<TodoProvider>().toggleTodoStatus(todo.id);
  }

  void _deleteTodo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TodoProvider>().deleteTodo(todo.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditTodoDialog(todo: todo),
    );
  }
}
