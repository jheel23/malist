import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:malist/data/models/files/user_file.dart';
import 'package:malist/data/repository/files_repo.dart';
import 'package:malist/providers/files/state/files_state.dart';
import 'package:malist/service_locator.dart';

class FilesNotifier extends Notifier<FilesState> {
  FilesNotifier({required this.repository});

  final FilesRepo repository;

  @override
  FilesState build() {
    Future.microtask(() => getFiles());
    return const FilesState.initial();
  }

  Future<void> getFiles() async {
    state = const FilesState.loading();
    final result = await repository.getFiles();
    state = result.fold(
      (failure) => FilesState.error(message: failure.message),
      (files) => FilesState.loaded(files: files),
    );
  }

  Future<void> addFile(UserFile file) async {
    state = const FilesState.loading();
    final result = await repository.addFile(file: file);
    result.fold(
      (failure) => state = FilesState.error(message: failure.message),
      (_) => getFiles(),
    );
  }

  Future<void> updateFile(UserFile file) async {
    state = const FilesState.loading();
    final result = await repository.updateFile(file: file);
    result.fold(
      (failure) => state = FilesState.error(message: failure.message),
      (_) => getFiles(),
    );
  }

  Future<void> deleteFile(String id, String filePath) async {
    state = const FilesState.loading();
    final result = await repository.deleteFile(id: id, filePath: filePath);
    result.fold(
      (failure) => state = FilesState.error(message: failure.message),
      (_) => getFiles(),
    );
  }

  Future<void> toggleFavorite(UserFile file) async {
    final updated = file.copyWith(isFavorite: !file.isFavorite);
    final result = await repository.updateFile(file: updated);
    result.fold(
      (failure) => state = FilesState.error(message: failure.message),
      (_) => getFiles(),
    );
  }

  Future<void> renameFile(UserFile file, String newTitle) async {
    final updated = file.copyWith(title: newTitle);
    final result = await repository.updateFile(file: updated);
    result.fold(
      (failure) => state = FilesState.error(message: failure.message),
      (_) => getFiles(),
    );
  }
}

final filesNotifierProvider = NotifierProvider<FilesNotifier, FilesState>(
  () => sl<FilesNotifier>(),
);
