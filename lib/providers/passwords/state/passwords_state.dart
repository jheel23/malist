import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:malist/data/models/password/password_model.dart';

part 'passwords_state.freezed.dart';

@freezed
abstract class PasswordsState with _$PasswordsState {
  const factory PasswordsState.initial() = _Initial;
  const factory PasswordsState.loading() = _Loading;
  const factory PasswordsState.loaded({
    required List<PasswordModel> passwords,
  }) = _Loaded;
  const factory PasswordsState.error({required String message}) = _Error;
}
