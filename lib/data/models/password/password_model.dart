import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_model.freezed.dart';
part 'password_model.g.dart';

@freezed
abstract class PasswordModel with _$PasswordModel {
  factory PasswordModel({
    required String id,
    required String username,
    required String category,
    required String password,
    required DateTime dateTime,
  }) = _PasswordModel;

  factory PasswordModel.fromJson(Map<String, dynamic> json) =>
      _$PasswordModelFromJson(json);
}
