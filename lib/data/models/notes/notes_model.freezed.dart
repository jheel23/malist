// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notes_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotesModel {

 String get id; String get title; String get description; DateTime get dateTime;
/// Create a copy of NotesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotesModelCopyWith<NotesModel> get copyWith => _$NotesModelCopyWithImpl<NotesModel>(this as NotesModel, _$identity);

  /// Serializes this NotesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotesModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,dateTime);

@override
String toString() {
  return 'NotesModel(id: $id, title: $title, description: $description, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class $NotesModelCopyWith<$Res>  {
  factory $NotesModelCopyWith(NotesModel value, $Res Function(NotesModel) _then) = _$NotesModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, DateTime dateTime
});




}
/// @nodoc
class _$NotesModelCopyWithImpl<$Res>
    implements $NotesModelCopyWith<$Res> {
  _$NotesModelCopyWithImpl(this._self, this._then);

  final NotesModel _self;
  final $Res Function(NotesModel) _then;

/// Create a copy of NotesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? dateTime = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotesModel].
extension NotesModelPatterns on NotesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotesModel value)  $default,){
final _that = this;
switch (_that) {
case _NotesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotesModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  DateTime dateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotesModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.dateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  DateTime dateTime)  $default,) {final _that = this;
switch (_that) {
case _NotesModel():
return $default(_that.id,_that.title,_that.description,_that.dateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  DateTime dateTime)?  $default,) {final _that = this;
switch (_that) {
case _NotesModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.dateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotesModel implements NotesModel {
   _NotesModel({required this.id, required this.title, required this.description, required this.dateTime});
  factory _NotesModel.fromJson(Map<String, dynamic> json) => _$NotesModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  DateTime dateTime;

/// Create a copy of NotesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotesModelCopyWith<_NotesModel> get copyWith => __$NotesModelCopyWithImpl<_NotesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotesModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotesModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,dateTime);

@override
String toString() {
  return 'NotesModel(id: $id, title: $title, description: $description, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class _$NotesModelCopyWith<$Res> implements $NotesModelCopyWith<$Res> {
  factory _$NotesModelCopyWith(_NotesModel value, $Res Function(_NotesModel) _then) = __$NotesModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, DateTime dateTime
});




}
/// @nodoc
class __$NotesModelCopyWithImpl<$Res>
    implements _$NotesModelCopyWith<$Res> {
  __$NotesModelCopyWithImpl(this._self, this._then);

  final _NotesModel _self;
  final $Res Function(_NotesModel) _then;

/// Create a copy of NotesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? dateTime = null,}) {
  return _then(_NotesModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
