import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:malist/data/models/todo/todo_model.dart';
import 'package:malist/data/repository/todo_repo.dart';
import 'package:malist/providers/todo/state/todo_state.dart';
import 'package:malist/service_locator.dart';

class TodoNotifier extends Notifier<TodoState> {
  final TodoRepo repository;

  TodoNotifier({required this.repository});

  @override
  TodoState build() {
    Future.microtask(() => getTodos());
    return const TodoState.initial();
  }

  Future<void> getTodos() async {
    state = const TodoState.loading();

    final result = await repository.getTodos();
    state = result.fold(
      (failure) => TodoState.error(message: failure.message),
      (todos) => TodoState.loaded(todos: todos),
    );
  }

  Future<void> addTodo(ToDoModel todo) async {
    state = const TodoState.loading();
    final result = await repository.addTodo(todo: todo);

    result.fold(
      (failure) => state = TodoState.error(message: failure.message),
      (_) => getTodos(),
    );
  }

  Future<void> updateTodo(ToDoModel todo) async {
    state = const TodoState.loading();
    final result = await repository.updateTodo(todo: todo);

    result.fold(
      (failure) => state = TodoState.error(message: failure.message),
      (_) => getTodos(),
    );
  }

  Future<void> deleteTodo(String id) async {
    state = const TodoState.loading();
    final result = await repository.deleteTodo(id: id);

    result.fold(
      (failure) => state = TodoState.error(message: failure.message),
      (_) => getTodos(),
    );
  }
}

final todoProvider = NotifierProvider<TodoNotifier, TodoState>(
  () => sl<TodoNotifier>(),
);
