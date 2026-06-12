import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_state.freezed.dart';

@freezed
abstract class BackupState with _$BackupState {
  const factory BackupState.initial() = _Initial;
  const factory BackupState.loading({
    @Default('') String message,
    @Default(0) int current,
    @Default(0) int total,
  }) = _Loading;
  const factory BackupState.validated({required Map<String, dynamic> summary}) =
      _Validated;
  const factory BackupState.success({required String message}) = _Success;
  const factory BackupState.error({required String message}) = _Error;
}
