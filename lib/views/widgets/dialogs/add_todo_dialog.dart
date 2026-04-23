import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:malist/data/models/todo/todo_model.dart';
import 'package:malist/providers/todo/todo_provider.dart';

class AddTodoDialog extends ConsumerStatefulWidget {
  const AddTodoDialog({super.key});

  @override
  ConsumerState<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newTodo = ToDoModel(
        id: "",
        description: _descController.text.trim(),
        dateTime: DateTime.now(),
        status: false,
      );
      ref.read(todoProvider.notifier).addTodo(newTodo);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NEW TASK",
                style: theme.textTheme.headlineSmall!.copyWith(
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "What do you need to do?",
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Description is required"
                    : null,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text("CANCEL", style: TextStyle(letterSpacing: 1)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    child: Text("ADD", style: TextStyle(letterSpacing: 1)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
