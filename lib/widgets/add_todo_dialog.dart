import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

/// Dialogue pour ajouter une nouvelle tâche
class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre du dialogue
                Text(
                  'Nouvelle tâche',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Champ titre
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    hintText: 'Ex: Acheter du lait',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Champ description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Détails supplémentaires...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Sélecteur de priorité
                DropdownButtonFormField<Priority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priorité',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: Priority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: _getPriorityColor(priority),
                          ),
                          const SizedBox(width: 8),
                          Text(priority.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Champ catégorie avec suggestions
                Consumer<TodoProvider>(
                  builder: (context, provider, child) {
                    return Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return provider.categories;
                        }
                        return provider.categories.where((category) {
                          return category
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        _categoryController.text = selection;
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _categoryController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
                            hintText: 'Ex: Travail, Personnel...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.folder),
                          ),
                          textCapitalization: TextCapitalization.words,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Sélecteur de date
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date d\'échéance',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Aucune date'
                              : _formatDate(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null
                                ? Colors.grey
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() => _selectedDate = null);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _saveTodo,
                      icon: const Icon(Icons.check),
                      label: const Text('Créer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final todo = Todo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        priority: _selectedPriority,
        category: _categoryController.text.trim().isNotEmpty
            ? _categoryController.text.trim()
            : null,
        dueDate: _selectedDate,
      );

      context.read<TodoProvider>().addTodo(todo);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche créée avec succès'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
