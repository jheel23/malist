// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PasswordModel {

 String get id; String get username; String get category; String get password; DateTime get dateTime;
/// Create a copy of PasswordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordModelCopyWith<PasswordModel> get copyWith => _$PasswordModelCopyWithImpl<PasswordModel>(this as PasswordModel, _$identity);

  /// Serializes this PasswordModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.category, category) || other.category == category)&&(identical(other.password, password) || other.password == password)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,category,password,dateTime);

@override
String toString() {
  return 'PasswordModel(id: $id, username: $username, category: $category, password: $password, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class $PasswordModelCopyWith<$Res>  {
  factory $PasswordModelCopyWith(PasswordModel value, $Res Function(PasswordModel) _then) = _$PasswordModelCopyWithImpl;
@useResult
$Res call({
 String id, String username, String category, String password, DateTime dateTime
});




}
/// @nodoc
class _$PasswordModelCopyWithImpl<$Res>
    implements $PasswordModelCopyWith<$Res> {
  _$PasswordModelCopyWithImpl(this._self, this._then);

  final PasswordModel _self;
  final $Res Function(PasswordModel) _then;

/// Create a copy of PasswordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? category = null,Object? password = null,Object? dateTime = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordModel].
extension PasswordModelPatterns on PasswordModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordModel value)  $default,){
final _that = this;
switch (_that) {
case _PasswordModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordModel value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String category,  String password,  DateTime dateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordModel() when $default != null:
return $default(_that.id,_that.username,_that.category,_that.password,_that.dateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String category,  String password,  DateTime dateTime)  $default,) {final _that = this;
switch (_that) {
case _PasswordModel():
return $default(_that.id,_that.username,_that.category,_that.password,_that.dateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String category,  String password,  DateTime dateTime)?  $default,) {final _that = this;
switch (_that) {
case _PasswordModel() when $default != null:
return $default(_that.id,_that.username,_that.category,_that.password,_that.dateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordModel implements PasswordModel {
   _PasswordModel({required this.id, required this.username, required this.category, required this.password, required this.dateTime});
  factory _PasswordModel.fromJson(Map<String, dynamic> json) => _$PasswordModelFromJson(json);

@override final  String id;
@override final  String username;
@override final  String category;
@override final  String password;
@override final  DateTime dateTime;

/// Create a copy of PasswordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordModelCopyWith<_PasswordModel> get copyWith => __$PasswordModelCopyWithImpl<_PasswordModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.category, category) || other.category == category)&&(identical(other.password, password) || other.password == password)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,category,password,dateTime);

@override
String toString() {
  return 'PasswordModel(id: $id, username: $username, category: $category, password: $password, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class _$PasswordModelCopyWith<$Res> implements $PasswordModelCopyWith<$Res> {
  factory _$PasswordModelCopyWith(_PasswordModel value, $Res Function(_PasswordModel) _then) = __$PasswordModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String category, String password, DateTime dateTime
});




}
/// @nodoc
class __$PasswordModelCopyWithImpl<$Res>
    implements _$PasswordModelCopyWith<$Res> {
  __$PasswordModelCopyWithImpl(this._self, this._then);

  final _PasswordModel _self;
  final $Res Function(_PasswordModel) _then;

/// Create a copy of PasswordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? category = null,Object? password = null,Object? dateTime = null,}) {
  return _then(_PasswordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
