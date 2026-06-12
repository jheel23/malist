// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserFile {

 String get id; String get title; String get originalFileName; String get filePath; String get fileExtension; String get mimeType; int get fileSize; DateTime get createdAt; FileSource get source; bool get isFavorite; String get checksum;
/// Create a copy of UserFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFileCopyWith<UserFile> get copyWith => _$UserFileCopyWithImpl<UserFile>(this as UserFile, _$identity);

  /// Serializes this UserFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFile&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalFileName, originalFileName) || other.originalFileName == originalFileName)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileExtension, fileExtension) || other.fileExtension == fileExtension)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.source, source) || other.source == source)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.checksum, checksum) || other.checksum == checksum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,originalFileName,filePath,fileExtension,mimeType,fileSize,createdAt,source,isFavorite,checksum);

@override
String toString() {
  return 'UserFile(id: $id, title: $title, originalFileName: $originalFileName, filePath: $filePath, fileExtension: $fileExtension, mimeType: $mimeType, fileSize: $fileSize, createdAt: $createdAt, source: $source, isFavorite: $isFavorite, checksum: $checksum)';
}


}

/// @nodoc
abstract mixin class $UserFileCopyWith<$Res>  {
  factory $UserFileCopyWith(UserFile value, $Res Function(UserFile) _then) = _$UserFileCopyWithImpl;
@useResult
$Res call({
 String id, String title, String originalFileName, String filePath, String fileExtension, String mimeType, int fileSize, DateTime createdAt, FileSource source, bool isFavorite, String checksum
});




}
/// @nodoc
class _$UserFileCopyWithImpl<$Res>
    implements $UserFileCopyWith<$Res> {
  _$UserFileCopyWithImpl(this._self, this._then);

  final UserFile _self;
  final $Res Function(UserFile) _then;

/// Create a copy of UserFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? originalFileName = null,Object? filePath = null,Object? fileExtension = null,Object? mimeType = null,Object? fileSize = null,Object? createdAt = null,Object? source = null,Object? isFavorite = null,Object? checksum = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalFileName: null == originalFileName ? _self.originalFileName : originalFileName // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileExtension: null == fileExtension ? _self.fileExtension : fileExtension // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FileSource,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,checksum: null == checksum ? _self.checksum : checksum // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFile].
extension UserFilePatterns on UserFile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFile value)  $default,){
final _that = this;
switch (_that) {
case _UserFile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFile value)?  $default,){
final _that = this;
switch (_that) {
case _UserFile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String originalFileName,  String filePath,  String fileExtension,  String mimeType,  int fileSize,  DateTime createdAt,  FileSource source,  bool isFavorite,  String checksum)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFile() when $default != null:
return $default(_that.id,_that.title,_that.originalFileName,_that.filePath,_that.fileExtension,_that.mimeType,_that.fileSize,_that.createdAt,_that.source,_that.isFavorite,_that.checksum);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String originalFileName,  String filePath,  String fileExtension,  String mimeType,  int fileSize,  DateTime createdAt,  FileSource source,  bool isFavorite,  String checksum)  $default,) {final _that = this;
switch (_that) {
case _UserFile():
return $default(_that.id,_that.title,_that.originalFileName,_that.filePath,_that.fileExtension,_that.mimeType,_that.fileSize,_that.createdAt,_that.source,_that.isFavorite,_that.checksum);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String originalFileName,  String filePath,  String fileExtension,  String mimeType,  int fileSize,  DateTime createdAt,  FileSource source,  bool isFavorite,  String checksum)?  $default,) {final _that = this;
switch (_that) {
case _UserFile() when $default != null:
return $default(_that.id,_that.title,_that.originalFileName,_that.filePath,_that.fileExtension,_that.mimeType,_that.fileSize,_that.createdAt,_that.source,_that.isFavorite,_that.checksum);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserFile implements UserFile {
   _UserFile({required this.id, required this.title, required this.originalFileName, required this.filePath, required this.fileExtension, required this.mimeType, required this.fileSize, required this.createdAt, required this.source, this.isFavorite = false, this.checksum = ''});
  factory _UserFile.fromJson(Map<String, dynamic> json) => _$UserFileFromJson(json);

@override final  String id;
@override final  String title;
@override final  String originalFileName;
@override final  String filePath;
@override final  String fileExtension;
@override final  String mimeType;
@override final  int fileSize;
@override final  DateTime createdAt;
@override final  FileSource source;
@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  String checksum;

/// Create a copy of UserFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFileCopyWith<_UserFile> get copyWith => __$UserFileCopyWithImpl<_UserFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFile&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalFileName, originalFileName) || other.originalFileName == originalFileName)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileExtension, fileExtension) || other.fileExtension == fileExtension)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.source, source) || other.source == source)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.checksum, checksum) || other.checksum == checksum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,originalFileName,filePath,fileExtension,mimeType,fileSize,createdAt,source,isFavorite,checksum);

@override
String toString() {
  return 'UserFile(id: $id, title: $title, originalFileName: $originalFileName, filePath: $filePath, fileExtension: $fileExtension, mimeType: $mimeType, fileSize: $fileSize, createdAt: $createdAt, source: $source, isFavorite: $isFavorite, checksum: $checksum)';
}


}

/// @nodoc
abstract mixin class _$UserFileCopyWith<$Res> implements $UserFileCopyWith<$Res> {
  factory _$UserFileCopyWith(_UserFile value, $Res Function(_UserFile) _then) = __$UserFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String originalFileName, String filePath, String fileExtension, String mimeType, int fileSize, DateTime createdAt, FileSource source, bool isFavorite, String checksum
});




}
/// @nodoc
class __$UserFileCopyWithImpl<$Res>
    implements _$UserFileCopyWith<$Res> {
  __$UserFileCopyWithImpl(this._self, this._then);

  final _UserFile _self;
  final $Res Function(_UserFile) _then;

/// Create a copy of UserFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? originalFileName = null,Object? filePath = null,Object? fileExtension = null,Object? mimeType = null,Object? fileSize = null,Object? createdAt = null,Object? source = null,Object? isFavorite = null,Object? checksum = null,}) {
  return _then(_UserFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalFileName: null == originalFileName ? _self.originalFileName : originalFileName // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileExtension: null == fileExtension ? _self.fileExtension : fileExtension // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FileSource,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,checksum: null == checksum ? _self.checksum : checksum // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
