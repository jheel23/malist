import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/core/utils/encryption_helper.dart';
import 'package:malist/data/source/backup_storage_provider.dart';
import 'package:malist/data/source/database_service.dart';
import 'package:path_provider/path_provider.dart';

abstract class CoreServiceSource {
  Future<Either<Failure, Unit>> nukeData();
  Future<Either<Failure, String>> exportData(
    String password, {
    void Function(int current, int total)? onProgress,
  });
  Future<Either<Failure, Map<String, dynamic>>> validateBackup(
    String zipPath,
    String password,
  );
  Future<Either<Failure, Unit>> importData(
    String zipPath,
    String password, {
    void Function(int current, int total)? onProgress,
  });
}

class CoreServiceSourceImpl implements CoreServiceSource {
  final DatabaseService databaseService;
  final LocalBackupStorageProvider backupStorageProvider;

  CoreServiceSourceImpl({
    required this.databaseService,
    required this.backupStorageProvider,
  });

  static const int _backupVersion = 1;
  static const String _appVersion = '1.0.1';
  static const List<String> _tables = ['notes', 'todos', 'passwords', 'files'];

  @override
  Future<Either<Failure, Unit>> nukeData() async {
    try {
      await databaseService.deleteAll();
      final appDir = await getApplicationDocumentsDirectory();
      final filesDir = Directory('${appDir.path}/malist_files');
      if (await filesDir.exists()) {
        await filesDir.delete(recursive: true);
      }
      return const Right(unit);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportData(
    String password, {
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final filesDir = Directory('${appDir.path}/malist_files');

      final Map<String, List<Map<String, dynamic>>> dbData = {};
      int totalRecords = 0;
      for (final table in _tables) {
        final result = await databaseService.getAllRecords(table);
        result.fold((failure) => dbData[table] = [], (records) {
          dbData[table] = records;
          totalRecords += records.length;
        });
      }

      final physicalFiles = <File>[];
      if (await filesDir.exists()) {
        physicalFiles.addAll(filesDir.listSync().whereType<File>().toList());
      }
      final totalItems = totalRecords + physicalFiles.length;

      final dbJson = jsonEncode(dbData);
      final encryptedDb = EncryptionHelper.encrypt(dbJson, password);

      final manifest = {
        'backupVersion': _backupVersion,
        'appVersion': _appVersion,
        'createdAt': DateTime.now().toIso8601String(),
        'totalFiles': physicalFiles.length,
        'databaseRecords': totalRecords,
        'backupSize': 0,
      };
      final manifestJson = jsonEncode(manifest);
      final encryptedManifest = EncryptionHelper.encrypt(
        manifestJson,
        password,
      );

      final archive = Archive();

      archive.addFile(
        ArchiveFile(
          'backup_manifest.json',
          utf8.encode(encryptedManifest).length,
          utf8.encode(encryptedManifest),
        ),
      );

      archive.addFile(
        ArchiveFile(
          'database.json',
          utf8.encode(encryptedDb).length,
          utf8.encode(encryptedDb),
        ),
      );

      int progress = totalRecords;
      for (final file in physicalFiles) {
        final fileName = file.uri.pathSegments.last;
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile('files/$fileName', bytes.length, bytes));
        progress++;
        onProgress?.call(progress, totalItems);
      }

      final zipData = ZipEncoder().encode(archive);
      if (zipData.isEmpty) {
        return const Left(GeneralFailure('Failed to create ZIP archive'));
      }

      final now = DateTime.now();
      final zipName =
          'Malist_Backup_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}.zip';
      final tempDir = await getTemporaryDirectory();
      final tempZip = File('${tempDir.path}/$zipName');
      await tempZip.writeAsBytes(zipData);

      final savedFile = await backupStorageProvider.saveBackup(tempZip);
      await backupStorageProvider.enforceRetentionPolicy();
      await tempZip.delete();

      debugPrint('Backup saved: ${savedFile.path} (${zipData.length} bytes)');
      return Right(savedFile.path);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateBackup(
    String zipPath,
    String password,
  ) async {
    try {
      final zipFile = File(zipPath);
      if (!await zipFile.exists()) {
        return const Left(GeneralFailure('Backup file not found'));
      }

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final manifestFile = archive.findFile('backup_manifest.json');
      if (manifestFile == null) {
        return const Left(GeneralFailure('Invalid backup: missing manifest'));
      }

      final dbFile = archive.findFile('database.json');
      if (dbFile == null) {
        return const Left(GeneralFailure('Invalid backup: missing database'));
      }

      String manifestJson;
      String dbJson;
      try {
        final encryptedManifest = utf8.decode(manifestFile.content);
        manifestJson = EncryptionHelper.decrypt(encryptedManifest, password);
        final encryptedDb = utf8.decode(dbFile.content);
        dbJson = EncryptionHelper.decrypt(encryptedDb, password);
      } catch (_) {
        return const Left(
          GeneralFailure('Incorrect password or corrupted backup'),
        );
      }

      final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
      final backupVersion = manifest['backupVersion'] as int? ?? 0;
      if (backupVersion > _backupVersion) {
        return Left(
          GeneralFailure(
            'Backup version $backupVersion is not supported. Update the app.',
          ),
        );
      }

      final dbData = jsonDecode(dbJson) as Map<String, dynamic>;

      int newFiles = 0;
      int existingFiles = 0;
      final localFilesResult = await databaseService.getAllRecords('files');
      final localChecksums = <String>{};
      localFilesResult.fold((_) {}, (records) {
        for (final r in records) {
          final cs = r['checksum'] as String?;
          if (cs != null && cs.isNotEmpty) localChecksums.add(cs);
        }
      });

      final importedFiles = (dbData['files'] as List<dynamic>?) ?? [];
      for (final f in importedFiles) {
        final cs = (f as Map<String, dynamic>)['checksum'] as String? ?? '';
        if (cs.isNotEmpty && localChecksums.contains(cs)) {
          existingFiles++;
        } else {
          newFiles++;
        }
      }

      int newRecords = 0;
      for (final table in ['notes', 'todos', 'passwords']) {
        final records = (dbData[table] as List<dynamic>?) ?? [];
        newRecords += records.length;
      }

      final backupFiles = archive.files
          .where((f) => f.name.startsWith('files/') && !f.isFile == false)
          .length;

      return Right({
        'manifest': manifest,
        'newFiles': newFiles,
        'existingFiles': existingFiles,
        'newRecords': newRecords,
        'totalBackupFiles': backupFiles,
        'backupDate': manifest['createdAt'],
        'backupSize': bytes.length,
      });
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> importData(
    String zipPath,
    String password, {
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      final zipFile = File(zipPath);
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final manifestFile = archive.findFile('backup_manifest.json');
      final dbFile = archive.findFile('database.json');
      if (manifestFile == null || dbFile == null) {
        return const Left(GeneralFailure('Invalid backup structure'));
      }

      String dbJson;
      try {
        final encryptedDb = utf8.decode(dbFile.content);
        dbJson = EncryptionHelper.decrypt(encryptedDb, password);
      } catch (_) {
        return const Left(GeneralFailure('Incorrect password'));
      }

      final dbData = jsonDecode(dbJson) as Map<String, dynamic>;

      final localIdSets = <String, Set<String>>{};
      for (final table in _tables) {
        final result = await databaseService.getAllRecords(table);
        localIdSets[table] = {};
        result.fold((_) {}, (records) {
          for (final r in records) {
            localIdSets[table]!.add(r['id'].toString());
          }
        });
      }

      final localChecksums = <String, String>{};
      final localFilesResult = await databaseService.getAllRecords('files');
      localFilesResult.fold((_) {}, (records) {
        for (final r in records) {
          final cs = r['checksum'] as String? ?? '';
          if (cs.isNotEmpty) {
            localChecksums[cs] = r['filePath'] as String? ?? '';
          }
        }
      });

      final appDir = await getApplicationDocumentsDirectory();
      final filesDir = Directory('${appDir.path}/malist_files');
      if (!await filesDir.exists()) {
        await filesDir.create(recursive: true);
      }

      int totalItems = 0;
      for (final table in _tables) {
        totalItems += ((dbData[table] as List<dynamic>?) ?? []).length;
      }
      int progress = 0;

      for (final table in ['notes', 'todos', 'passwords']) {
        final records = (dbData[table] as List<dynamic>?) ?? [];
        for (final r in records) {
          final record = Map<String, dynamic>.from(r as Map);
          final originalId = record['id']?.toString() ?? '';
          if (localIdSets[table]!.contains(originalId)) {
            record.remove('id');
          }
          await databaseService.insertRecord(table, record);
          progress++;
          onProgress?.call(progress, totalItems);
        }
      }

      final fileRecords = (dbData['files'] as List<dynamic>?) ?? [];
      for (final r in fileRecords) {
        final record = Map<String, dynamic>.from(r as Map);
        final checksum = record['checksum'] as String? ?? '';

        if (checksum.isNotEmpty && localChecksums.containsKey(checksum)) {
          progress++;
          onProgress?.call(progress, totalItems);
          continue;
        }

        final originalFileName =
            record['originalFileName'] as String? ?? 'unknown';
        final archiveFileName = record['filePath'] as String? ?? '';
        final baseName = archiveFileName.split('/').last;

        ArchiveFile? archiveFile;
        for (final af in archive.files) {
          if (af.name == 'files/$baseName') {
            archiveFile = af;
            break;
          }
        }

        if (archiveFile == null) {
          for (final af in archive.files) {
            if (af.name.startsWith('files/') &&
                af.name.contains(originalFileName)) {
              archiveFile = af;
              break;
            }
          }
        }

        String newFilePath;
        if (archiveFile != null) {
          // final ext = originalFileName.contains('.')
          //     ? originalFileName.substring(originalFileName.lastIndexOf('.'))
          //     : '';
          newFilePath =
              '${filesDir.path}/${DateTime.now().millisecondsSinceEpoch}_$originalFileName';
          await File(newFilePath).writeAsBytes(archiveFile.content);

          if (checksum.isEmpty) {
            final fileChecksum = sha256.convert(archiveFile.content).toString();
            record['checksum'] = fileChecksum;
          }
        } else {
          progress++;
          onProgress?.call(progress, totalItems);
          continue;
        }

        record['filePath'] = newFilePath;
        final originalId = record['id']?.toString() ?? '';
        if (localIdSets['files']!.contains(originalId)) {
          record.remove('id');
        }
        if (record['createdAt'] is String) {
          record['createdAt'] = record['createdAt'];
        }
        if (record['source'] is String) {
          record['source'] = record['source'];
        }

        await databaseService.insertRecord('files', record);
        progress++;
        onProgress?.call(progress, totalItems);
      }

      return const Right(unit);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
