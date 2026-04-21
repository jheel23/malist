// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ToDoModel {

 String get id; String get description; DateTime get dateTime; bool? get status;
/// Create a copy of ToDoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToDoModelCopyWith<ToDoModel> get copyWith => _$ToDoModelCopyWithImpl<ToDoModel>(this as ToDoModel, _$identity);

  /// Serializes this ToDoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToDoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,dateTime,status);

@override
String toString() {
  return 'ToDoModel(id: $id, description: $description, dateTime: $dateTime, status: $status)';
}


}

/// @nodoc
abstract mixin class $ToDoModelCopyWith<$Res>  {
  factory $ToDoModelCopyWith(ToDoModel value, $Res Function(ToDoModel) _then) = _$ToDoModelCopyWithImpl;
@useResult
$Res call({
 String id, String description, DateTime dateTime, bool? status
});




}
/// @nodoc
class _$ToDoModelCopyWithImpl<$Res>
    implements $ToDoModelCopyWith<$Res> {
  _$ToDoModelCopyWithImpl(this._self, this._then);

  final ToDoModel _self;
  final $Res Function(ToDoModel) _then;

/// Create a copy of ToDoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? dateTime = null,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ToDoModel].
extension ToDoModelPatterns on ToDoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToDoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToDoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToDoModel value)  $default,){
final _that = this;
switch (_that) {
case _ToDoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToDoModel value)?  $default,){
final _that = this;
switch (_that) {
case _ToDoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  DateTime dateTime,  bool? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToDoModel() when $default != null:
return $default(_that.id,_that.description,_that.dateTime,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  DateTime dateTime,  bool? status)  $default,) {final _that = this;
switch (_that) {
case _ToDoModel():
return $default(_that.id,_that.description,_that.dateTime,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  DateTime dateTime,  bool? status)?  $default,) {final _that = this;
switch (_that) {
case _ToDoModel() when $default != null:
return $default(_that.id,_that.description,_that.dateTime,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ToDoModel implements ToDoModel {
   _ToDoModel({required this.id, required this.description, required this.dateTime, this.status});
  factory _ToDoModel.fromJson(Map<String, dynamic> json) => _$ToDoModelFromJson(json);

@override final  String id;
@override final  String description;
@override final  DateTime dateTime;
@override final  bool? status;

/// Create a copy of ToDoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToDoModelCopyWith<_ToDoModel> get copyWith => __$ToDoModelCopyWithImpl<_ToDoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToDoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToDoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,dateTime,status);

@override
String toString() {
  return 'ToDoModel(id: $id, description: $description, dateTime: $dateTime, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ToDoModelCopyWith<$Res> implements $ToDoModelCopyWith<$Res> {
  factory _$ToDoModelCopyWith(_ToDoModel value, $Res Function(_ToDoModel) _then) = __$ToDoModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, DateTime dateTime, bool? status
});




}
/// @nodoc
class __$ToDoModelCopyWithImpl<$Res>
    implements _$ToDoModelCopyWith<$Res> {
  __$ToDoModelCopyWithImpl(this._self, this._then);

  final _ToDoModel _self;
  final $Res Function(_ToDoModel) _then;

/// Create a copy of ToDoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? dateTime = null,Object? status = freezed,}) {
  return _then(_ToDoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
