import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:malist/data/models/password/password_model.dart';
import 'package:malist/providers/passwords/passwords_provider.dart';

class AddPasswordDialog extends ConsumerStatefulWidget {
  const AddPasswordDialog({super.key});

  @override
  ConsumerState<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends ConsumerState<AddPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _categoryController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newPassword = PasswordModel(
        id: "", // ID handled by tostore
        username: _usernameController.text.trim(),
        category: _categoryController.text.trim(),
        password: _passwordController.text.trim(),
        dateTime: DateTime.now(),
      );
      ref.read(passwordsNotifierProvider.notifier).addPassword(newPassword);
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
                "NEW PASSWORD",
                style: theme.textTheme.headlineSmall!.copyWith(
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username / Email",
                  hintText: "Enter username",
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Username is required"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: "Category / Site",
                  hintText: "e.g., Google, Bank, Social",
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Category is required"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Password is required"
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
