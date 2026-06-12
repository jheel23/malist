import 'dart:io';

abstract class BackupStorageService {
  Future<File> saveBackup(File zipFile);
  Future<File?> retrieveBackup();
  Future<List<File>> listBackups();
  Future<void> deleteBackup(File backup);
}

class BackupStorageServiceImpl implements BackupStorageService {
  final Directory backupDir;
  BackupStorageServiceImpl({required this.backupDir});

  @override
  Future<File> saveBackup(File zipFile) async {
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final destPath = '${backupDir.path}/${zipFile.uri.pathSegments.last}';
    return zipFile.copy(destPath);
  }

  @override
  Future<File?> retrieveBackup() async {
    final backups = await listBackups();
    if (backups.isEmpty) return null;
    backups.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );
    return backups.first;
  }

  @override
  Future<List<File>> listBackups() async {
    if (!await backupDir.exists()) return [];
    return backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
  }

  @override
  Future<void> deleteBackup(File backup) async {
    if (await backup.exists()) {
      await backup.delete();
    }
  }

  Future<void> enforceRetentionPolicy({int maxBackups = 2}) async {
    final backups = await listBackups();
    if (backups.length > maxBackups) {
      for (var i = maxBackups; i < backups.length; i++) {
        await deleteBackup(backups[i]);
      }
    }
  }
}
