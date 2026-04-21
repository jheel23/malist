import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:malist/data/models/password/password_model.dart';
import 'package:malist/providers/passwords/state/passwords_state.dart';
import 'package:malist/data/repository/passwords_repo.dart';
import 'package:malist/service_locator.dart';

class PasswordsNotifier extends Notifier<PasswordsState> {
  PasswordsNotifier({required this.repository});

  final PasswordsRepo repository;

  @override
  PasswordsState build() {
    Future.microtask(() => getPasswords());
    return const PasswordsState.initial();
  }

  Future<void> getPasswords() async {
    state = const PasswordsState.loading();

    final result = await repository.getPasswords();

    state = result.fold(
      (failure) => PasswordsState.error(message: failure.message),
      (passwords) => PasswordsState.loaded(passwords: passwords),
    );
  }

  Future<void> addPassword(PasswordModel password) async {
    state = const PasswordsState.loading();
    final result = await repository.addPassword(password: password);

    result.fold(
      (failure) => state = PasswordsState.error(message: failure.message),
      (_) => getPasswords(),
    );
  }

  Future<void> updatePassword(PasswordModel password) async {
    state = const PasswordsState.loading();
    final result = await repository.updatePassword(password: password);

    result.fold(
      (failure) => state = PasswordsState.error(message: failure.message),
      (_) => getPasswords(),
    );
  }

  Future<void> deletePassword(String id) async {
    state = const PasswordsState.loading();
    final result = await repository.deletePassword(id: id);

    result.fold(
      (failure) => state = PasswordsState.error(message: failure.message),
      (_) => getPasswords(),
    );
  }
}

final passwordsNotifierProvider =
    NotifierProvider<PasswordsNotifier, PasswordsState>(
      () => sl<PasswordsNotifier>(),
    );
