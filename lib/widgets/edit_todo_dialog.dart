import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

/// Dialogue pour éditer une tâche existante
class EditTodoDialog extends StatefulWidget {
  final Todo todo;

  const EditTodoDialog({
    required this.todo,
    super.key,
  });

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  late Priority _selectedPriority;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController =
        TextEditingController(text: widget.todo.description ?? '');
    _categoryController =
        TextEditingController(text: widget.todo.category ?? '');
    _selectedPriority = widget.todo.priority;
    _selectedDate = widget.todo.dueDate;
  }

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
                Text(
                  'Modifier la tâche',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

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

                Consumer<TodoProvider>(
                  builder: (context, provider, child) {
                    return Autocomplete<String>(
                      initialValue: TextEditingValue(
                        text: widget.todo.category ?? '',
                      ),
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
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        _categoryController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _updateTodo,
                      icon: const Icon(Icons.check),
                      label: const Text('Enregistrer'),
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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
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

  void _updateTodo() {
    if (_formKey.currentState!.validate()) {
      widget.todo.title = _titleController.text.trim();
      widget.todo.description = _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null;
      widget.todo.priority = _selectedPriority;
      widget.todo.category = _categoryController.text.trim().isNotEmpty
          ? _categoryController.text.trim()
          : null;
      widget.todo.dueDate = _selectedDate;

      context.read<TodoProvider>().updateTodo(widget.todo);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche mise à jour'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
