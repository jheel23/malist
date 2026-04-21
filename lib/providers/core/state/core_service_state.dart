import 'package:freezed_annotation/freezed_annotation.dart';

part 'core_service_state.freezed.dart';

@freezed
abstract class CoreServiceState with _$CoreServiceState {
  const factory CoreServiceState.initial() = _Initial;
  const factory CoreServiceState.loading() = _Loading;
  const factory CoreServiceState.loaded({required bool result}) = _Loaded;
  const factory CoreServiceState.error({required String message}) = _Error;
}
