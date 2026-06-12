import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:malist/core/local/secure_storage_service.dart';
import 'package:malist/data/repository/core_service_repo.dart';
import 'package:malist/data/repository/files_repo.dart';
import 'package:malist/data/repository/notes_repo.dart';
import 'package:malist/data/repository/passwords_repo.dart';
import 'package:malist/data/repository/todo_repo.dart';
import 'package:malist/data/source/backup_storage_provider.dart';
import 'package:malist/data/source/core_service.dart';
import 'package:malist/data/source/database_service.dart';
import 'package:malist/providers/backup/backup_provider.dart';
import 'package:malist/providers/core/core_service_provider.dart';
import 'package:malist/providers/files/files_provider.dart';
import 'package:malist/providers/notes/notes_provider.dart';
import 'package:malist/providers/passwords/passwords_provider.dart';
import 'package:malist/providers/todo/todo_provider.dart';

import 'core/constants/api_endpoints.dart';
import 'core/network/dio_client.dart';
import 'package:path_provider/path_provider.dart';

part 'service_locator.main.dart';
