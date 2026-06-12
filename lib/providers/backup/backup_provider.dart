import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:malist/core/constants/storage_keys.dart';
import 'package:malist/core/local/secure_storage_service.dart';
import 'package:malist/data/repository/core_service_repo.dart';
import 'package:malist/data/source/backup_storage_provider.dart';
import 'package:malist/providers/backup/state/backup_state.dart';
import 'package:malist/service_locator.dart';

class BackupNotifier extends Notifier<BackupState> {
  final CoreServiceRepo repo;
  final SecureStorageService storage;
  final LocalBackupStorageProvider backupStorage;

  BackupNotifier({
    required this.repo,
    required this.storage,
    required this.backupStorage,
  });

  @override
  BackupState build() => const BackupState.initial();

  Future<void> exportBackup(String password) async {
    state = const BackupState.loading(message: 'Preparing backup...');
    final result = await repo.exportData(
      password,
      onProgress: (current, total) {
        state = BackupState.loading(
          message: 'Backing up $current / $total items',
          current: current,
          total: total,
        );
      },
    );
    result.fold(
      (failure) => state = BackupState.error(message: failure.message),
      (path) async {
        final file = File(path);
        final size = await file.length();
        await storage.setString(
          StorageKeys.lastBackupTimestamp,
          DateTime.now().toIso8601String(),
        );
        await storage.setString(StorageKeys.lastBackupSize, size.toString());
        state = BackupState.success(message: 'Backup saved successfully');
        ref.invalidate(backupInfoProvider);
      },
    );
  }

  Future<void> validateBackup(String zipPath, String password) async {
    state = const BackupState.loading(message: 'Validating backup...');
    final result = await repo.validateBackup(zipPath, password);
    result.fold(
      (failure) => state = BackupState.error(message: failure.message),
      (summary) => state = BackupState.validated(summary: summary),
    );
  }

  Future<void> importBackup(String zipPath, String password) async {
    state = const BackupState.loading(message: 'Restoring data...');
    final result = await repo.importData(
      zipPath,
      password,
      onProgress: (current, total) {
        state = BackupState.loading(
          message: 'Restoring $current / $total items',
          current: current,
          total: total,
        );
      },
    );
    result.fold(
      (failure) => state = BackupState.error(message: failure.message),
      (_) async {
        await storage.setString(
          StorageKeys.lastBackupTimestamp,
          DateTime.now().toIso8601String(),
        );
        state = const BackupState.success(
          message: 'Restore completed successfully',
        );
        ref.invalidate(backupInfoProvider);
      },
    );
  }

  Future<String?> getLastBackupTimestamp() async {
    return storage.getString(StorageKeys.lastBackupTimestamp);
  }

  Future<String?> getLastBackupSize() async {
    return storage.getString(StorageKeys.lastBackupSize);
  }

  Future<String> getBackupFrequency() async {
    return await storage.getString(StorageKeys.backupFrequency) ?? 'never';
  }

  Future<void> setBackupFrequency(String frequency) async {
    await storage.setString(StorageKeys.backupFrequency, frequency);
    ref.invalidate(backupInfoProvider);
  }

  Future<String?> getBackupPassword() async {
    return storage.getString(StorageKeys.backupPassword);
  }

  Future<void> setBackupPassword(String password) async {
    await storage.setString(StorageKeys.backupPassword, password);
    ref.invalidate(backupInfoProvider);
  }

  Future<List<File>> getBackupHistory() async {
    return backupStorage.listBackups();
  }

  Future<void> checkAndRunScheduledBackup() async {
    final password = await getBackupPassword();
    if (password == null || password.isEmpty) return;

    final frequency = await getBackupFrequency();
    if (frequency == 'never') return;

    final lastTimestamp = await getLastBackupTimestamp();
    if (lastTimestamp == null) {
      await exportBackup(password);
      return;
    }

    final lastBackup = DateTime.tryParse(lastTimestamp);
    if (lastBackup == null) {
      await exportBackup(password);
      return;
    }

    final now = DateTime.now();
    final diff = now.difference(lastBackup);
    final shouldBackup = switch (frequency) {
      'daily' => diff.inDays >= 1,
      'weekly' => diff.inDays >= 7,
      'monthly' => diff.inDays >= 30,
      _ => false,
    };

    if (shouldBackup) {
      await exportBackup(password);
    }
  }

  void reset() {
    state = const BackupState.initial();
  }
}

class BackupInfo {
  final String frequency;
  final String? lastBackupTimestamp;
  final bool hasPassword;
  BackupInfo({
    required this.frequency,
    this.lastBackupTimestamp,
    required this.hasPassword,
  });
}

final backupNotifierProvider = NotifierProvider<BackupNotifier, BackupState>(
  () => sl<BackupNotifier>(),
);

final backupInfoProvider = FutureProvider<BackupInfo>((ref) async {
  final notifier = ref.read(backupNotifierProvider.notifier);
  final freq = await notifier.getBackupFrequency();
  final timestamp = await notifier.getLastBackupTimestamp();
  final password = await notifier.getBackupPassword();
  return BackupInfo(
    frequency: freq,
    lastBackupTimestamp: timestamp,
    hasPassword: password != null && password.isNotEmpty,
  );
});
