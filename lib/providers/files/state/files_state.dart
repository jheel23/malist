import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:malist/data/models/files/user_file.dart';

part 'files_state.freezed.dart';

@freezed
abstract class FilesState with _$FilesState {
  const factory FilesState.initial() = _Initial;
  const factory FilesState.loading() = _Loading;
  const factory FilesState.loaded({required List<UserFile> files}) = _Loaded;
  const factory FilesState.error({required String message}) = _Error;
}
