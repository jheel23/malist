import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_file.freezed.dart';
part 'user_file.g.dart';

enum FileSource { camera, device }

enum FileCategory {
  all,
  images,
  documents,
  spreadsheets,
  presentations,
  pdfs,
  videos,
  audio,
  archives,
  other;

  String get label => switch (this) {
    FileCategory.all => 'All',
    FileCategory.images => 'Images',
    FileCategory.documents => 'Documents',
    FileCategory.spreadsheets => 'Spreadsheets',
    FileCategory.presentations => 'Presentations',
    FileCategory.pdfs => 'PDFs',
    FileCategory.videos => 'Videos',
    FileCategory.audio => 'Audio',
    FileCategory.archives => 'Archives',
    FileCategory.other => 'Other',
  };

  static FileCategory fromExtension(String ext) {
    final e = ext.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(e)) {
      return FileCategory.images;
    }
    if (['doc', 'docx', 'txt', 'rtf'].contains(e)) {
      return FileCategory.documents;
    }
    if (['xls', 'xlsx', 'csv'].contains(e)) {
      return FileCategory.spreadsheets;
    }
    if (['ppt', 'pptx'].contains(e)) return FileCategory.presentations;
    if (e == 'pdf') return FileCategory.pdfs;
    if (['mp4', 'mov', 'avi', 'mkv'].contains(e)) return FileCategory.videos;
    if (['mp3', 'wav', 'aac', 'm4a'].contains(e)) return FileCategory.audio;
    if (['zip', 'rar', '7z'].contains(e)) return FileCategory.archives;
    return FileCategory.other;
  }
}

@freezed
abstract class UserFile with _$UserFile {
  factory UserFile({
    required String id,
    required String title,
    required String originalFileName,
    required String filePath,
    required String fileExtension,
    required String mimeType,
    required int fileSize,
    required DateTime createdAt,
    required FileSource source,
    @Default(false) bool isFavorite,
  }) = _UserFile;

  factory UserFile.fromJson(Map<String, dynamic> json) =>
      _$UserFileFromJson(json);
}
