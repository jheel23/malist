import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:malist/providers/todo/state/todo_state.dart';
import 'package:malist/providers/todo/todo_provider.dart';
import 'package:malist/views/widgets/dialogs/add_todo_dialog.dart';
import 'package:malist/views/widgets/no_data_widget.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoProvider.notifier).getTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoState = ref.watch(todoProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "Add Todo",
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (context, anim1, anim2) => const AddTodoDialog(),
            transitionBuilder: (context, anim1, anim2, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * anim1.value),
                child: FadeTransition(
                  opacity: anim1,
                  child: child,
                ),
              );
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        child: const Icon(Iconsax.add, size: 35),
      ),
      body: todoState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (todos) {
          final completedTodos = todos
              .where((t) => t.status == true || t.status == null)
              .toList();
          final notCompletedTodos = todos
              .where((t) => t.status == false)
              .toList();
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                expandedHeight: 100,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Row(
                      crossAxisAlignment: .center,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .start,
                          children: [
                            Text('To-Do', style: theme.textTheme.displayMedium),
                            Text(
                              ' ${todos.length} TASKS',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  background: Container(color: theme.colorScheme.surface),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 40)),
              // No Data Widget
              if (todos.isEmpty)
                SliverToBoxAdapter(
                  child: NoDataWidget(message: "No tasks found!"),
                )
              else
                SliverList.builder(
                  itemCount: notCompletedTodos.length,
                  itemBuilder: (context, index) {
                    final todo = notCompletedTodos[index];
                    return ListTile(
                      leading: GestureDetector(
                        onLongPress: () async {
                          if (todo.status == null) {
                            final updatedTodo = todo.copyWith(status: false);
                            await ref
                                .read(todoProvider.notifier)
                                .updateTodo(updatedTodo);
                          }
                        },
                        child: Checkbox.adaptive(
                          value: todo.status,
                          onChanged: (value) async {
                            switch (todo.status) {
                              case true:
                                final updatedTodo = todo.copyWith(status: null);
                                await ref
                                    .read(todoProvider.notifier)
                                    .updateTodo(updatedTodo);

                                break;
                              case false:
                                final updatedTodo = todo.copyWith(status: true);
                                await ref
                                    .read(todoProvider.notifier)
                                    .updateTodo(updatedTodo);
                                break;
                              case null:
                                await ref
                                    .read(todoProvider.notifier)
                                    .deleteTodo(todo.id);
                                break;
                            }
                          },
                          tristate: true,
                        ),
                      ),
                      title: Text(
                        todo.description,
                        style: theme.textTheme.titleMedium,
                      ),
                    );
                  },
                ),
              if (completedTodos.isNotEmpty) _buildCompletedHeader(),
              SliverList.builder(
                itemCount: completedTodos.length,
                itemBuilder: (context, index) {
                  final todo = completedTodos[index];
                  return ListTile(
                    leading: GestureDetector(
                      onLongPress: () async {
                        if (todo.status == null) {
                          final updatedTodo = todo.copyWith(status: false);
                          await ref
                              .read(todoProvider.notifier)
                              .updateTodo(updatedTodo);
                        }
                      },
                      child: Checkbox.adaptive(
                        value: todo.status,
                        onChanged: (value) async {
                          switch (todo.status) {
                            case true:
                              final updatedTodo = todo.copyWith(status: null);
                              await ref
                                  .read(todoProvider.notifier)
                                  .updateTodo(updatedTodo);

                              break;
                            case false:
                              final updatedTodo = todo.copyWith(status: true);
                              await ref
                                  .read(todoProvider.notifier)
                                  .updateTodo(updatedTodo);
                              break;
                            case null:
                              await ref
                                  .read(todoProvider.notifier)
                                  .deleteTodo(todo.id);
                              break;
                          }
                        },
                        tristate: true,
                      ),
                    ),
                    title: Text(
                      todo.description,
                      style: theme.textTheme.titleMedium!.copyWith(
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.grey,
                        decorationThickness: 2,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
        error: (message) => Center(child: Text('Error: $message')),
      ),
    );
  }

  SliverToBoxAdapter _buildCompletedHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
        child: Text(
          'COMPLETED',
          style: TextStyle(
            color: Colors.grey.shade700,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
