import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:malist/data/repository/core_service_repo.dart';
import 'package:malist/providers/core/state/core_service_state.dart';
import 'package:malist/service_locator.dart';

class CoreServiceNotifier extends Notifier<CoreServiceState> {
  final CoreServiceRepo repo;

  CoreServiceNotifier({required this.repo});

  @override
  CoreServiceState build() {
    return CoreServiceState.initial();
  }

  Future<void> nukeData() async {
    state = CoreServiceState.loading();
    final result = await repo.nukeData();
    result.fold(
      (failure) {
        state = CoreServiceState.error(message: failure.message);
      },
      (unit) {
        state = CoreServiceState.loaded(result: true);
      },
    );
  }
}

final coreServiceProvider =
    NotifierProvider<CoreServiceNotifier, CoreServiceState>(() {
      return sl<CoreServiceNotifier>();
    });
