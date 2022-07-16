// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'generic_union.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GenericUnion<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number, T value) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number, T value)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number, T value)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GenericUnionFirst<T> value) first,
    required TResult Function(GenericUnionSecond<T> value) second,
    required TResult Function(GenericUnionThird<T> value) third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GenericUnionFirst<T> value)? first,
    TResult Function(GenericUnionSecond<T> value)? second,
    TResult Function(GenericUnionThird<T> value)? third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GenericUnionFirst<T> value)? first,
    TResult Function(GenericUnionSecond<T> value)? second,
    TResult Function(GenericUnionThird<T> value)? third,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenericUnionCopyWith<T, $Res> {
  factory $GenericUnionCopyWith(
          GenericUnion<T> value, $Res Function(GenericUnion<T>) then) =
      _$GenericUnionCopyWithImpl<T, $Res>;
}

/// @nodoc
class _$GenericUnionCopyWithImpl<T, $Res>
    implements $GenericUnionCopyWith<T, $Res> {
  _$GenericUnionCopyWithImpl(this._value, this._then);

  final GenericUnion<T> _value;
  // ignore: unused_field
  final $Res Function(GenericUnion<T>) _then;
}

/// @nodoc
abstract class _$$GenericUnionFirstCopyWith<T, $Res> {
  factory _$$GenericUnionFirstCopyWith(_$GenericUnionFirst<T> value,
          $Res Function(_$GenericUnionFirst<T>) then) =
      __$$GenericUnionFirstCopyWithImpl<T, $Res>;
  $Res call({int number, T value});
}

/// @nodoc
class __$$GenericUnionFirstCopyWithImpl<T, $Res>
    extends _$GenericUnionCopyWithImpl<T, $Res>
    implements _$$GenericUnionFirstCopyWith<T, $Res> {
  __$$GenericUnionFirstCopyWithImpl(_$GenericUnionFirst<T> _value,
      $Res Function(_$GenericUnionFirst<T>) _then)
      : super(_value, (v) => _then(v as _$GenericUnionFirst<T>));

  @override
  _$GenericUnionFirst<T> get _value => super._value as _$GenericUnionFirst<T>;

  @override
  $Res call({
    Object? number = freezed,
    Object? value = freezed,
  }) {
    return _then(_$GenericUnionFirst<T>(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      value: value == freezed
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$GenericUnionFirst<T> implements GenericUnionFirst<T> {
  const _$GenericUnionFirst({this.number = 32, required this.value});

  @override
  @JsonKey()
  final int number;
  @override
  final T value;

  @override
  String toString() {
    return 'GenericUnion<$T>.first(number: $number, value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenericUnionFirst<T> &&
            const DeepCollectionEquality().equals(other.number, number) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(number),
      const DeepCollectionEquality().hash(value));

  @JsonKey(ignore: true)
  @override
  _$$GenericUnionFirstCopyWith<T, _$GenericUnionFirst<T>> get copyWith =>
      __$$GenericUnionFirstCopyWithImpl<T, _$GenericUnionFirst<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number, T value) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return first(number, value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number, T value)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return first?.call(number, value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number, T value)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
    required TResult orElse(),
  }) {
    if (first != null) {
      return first(number, value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GenericUnionFirst<T> value) first,
    required TResult Function(GenericUnionSecond<T> value) second,
    required TResult Function(GenericUnionThird<T> value) third,
  }) {
    return first(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GenericUnionFirst<T> value)? first,
    TResult Function(GenericUnionSecond<T> value)? second,
    TResult Function(GenericUnionThird<T> value)? third,
  }) {
    return first?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GenericUnionFirst<T> value)? first,
    TResult Function(GenericUnionSecond<T> value)? second,
    TResult Function(GenericUnionThird<T> value)? third,
    required TResult orElse(),
  }) {
    if (first != null) {
      return first(this);
    }
    return orElse();
  }
}

abstract class GenericUnionFirst<T> implements GenericUnion<T> {
  const factory GenericUnionFirst({final int number, required final T value}) =
      _$GenericUnionFirst<T>;

  int get number;
  T get value;
  @JsonKey(ignore: true)
  _$$GenericUnionFirstCopyWith<T, _$GenericUnionFirst<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GenericUnionSecondCopyWith<T, $Res> {
  factory _$$GenericUnionSecondCopyWith(_$GenericUnionSecond<T> value,
          $Res Function(_$GenericUnionSecond<T>) then) =
      __$$GenericUnionSecondCopyWithImpl<T, $Res>;
  $Res call({String greeting});
}

/// @nodoc
class __$$GenericUnionSecondCopyWithImpl<T, $Res>
    extends _$GenericUnionCopyWithImpl<T, $Res>
    implements _$$GenericUnionSecondCopyWith<T, $Res> {
  __$$GenericUnionSecondCopyWithImpl(_$GenericUnionSecond<T> _value,
      $Res Function(_$GenericUnionSecond<T>) _then)
      : super(_value, (v) => _then(v as _$GenericUnionSecond<T>));

  @override
  _$GenericUnionSecond<T> get _value => super._value as _$GenericUnionSecond<T>;

  @override
  $Res call({
    Object? greeting = freezed,
  }) {
    return _then(_$GenericUnionSecond<T>(
      greeting: greeting == freezed
          ? _value.greeting
          : greeting // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JUnionValue(name: 'the_second')
class _$GenericUnionSecond<T> implements GenericUnionSecond<T> {
  const _$GenericUnionSecond({this.greeting = 'Hello'});

  @override
  @JsonKey()
  final String greeting;

  @override
  String toString() {
    return 'GenericUnion<$T>.second(greeting: $greeting)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenericUnionSecond<T> &&
            const DeepCollectionEquality().equals(other.greeting, greeting));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(greeting));

  @JsonKey(ignore: true)
  @override
  _$$GenericUnionSecondCopyWith<T, _$GenericUnionSecond<T>> get copyWith =>
      __$$GenericUnionSecondCopyWithImpl<T, _$GenericUnionSecond<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number, T value) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return second(greeting);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number, T value)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return second?.call(greeting);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number, T value)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
    required TResult orElse(),
  }) {
    if (second != null) {
      return second(greeting);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GenericUnionFirst<T> value) first,
    required TResult Function(GenericUnionSecond<T> value) second,
    required TResult Function(GenericUnionThird<T> value) third,
  }) {
    return second(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GenericUnionFirst<T> value)? first,
    TResult Function(GenericUnionSecond<T> value)? second,
    TResult Function(GenericUnionThird<T> value)? third,
  }) {
    return second?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GenericUnionFirst<T> value)? first,
    TResult Function(GenericUnionSecond<T> value)? second,
    TResult Function(GenericUnionThird<T> value)? third,
    required TResult orElse(),
  }) {
    if (second != null) {
      return second(this);
    }
    return orElse();
  }
}

abstract class GenericUnionSecond<T> implements GenericUnion<T> {
  const factory GenericUnionSecond({final String greeting}) =
      _$GenericUnionSecond<T>;

  String get greeting;
  @JsonKey(ignore: true)
  _$$GenericUnionSecondCopyWith<T, _$GenericUnionSecond<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GenericUnionThirdCopyWith<T, $Res> {
  factory _$$GenericUnionThirdCopyWith(_$GenericUnionThird<T> value,
          $Res Function(_$GenericUnionThird<T>) then) =
      __$$GenericUnionThirdCopyWithImpl<T, $Res>;
  $Res call({bool flag});
}

/// @nodoc
class __$$GenericUnionThirdCopyWithImpl<T, $Res>
    extends _$GenericUnionCopyWithImpl<T, $Res>
    implements _$$GenericUnionThirdCopyWith<T, $Res> {
  __$$GenericUnionThirdCopyWithImpl(_$GenericUnionThird<T> _value,
      $Res Function(_$GenericUnionThird<T>) _then)
      : super(_value, (v) => _then(v as _$GenericUnionThird<T>));

  @override
  _$GenericUnionThird<T> get _value => super._value as _$GenericUnionThird<T>;

  @override
  $Res call({
    Object? flag = freezed,
  }) {
    return _then(_$GenericUnionThird<T>(
      flag: flag == freezed
          ? _value.flag
          : flag // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$GenericUnionThird<T> implements GenericUnionThird<T> {
  const _$GenericUnionThird({this.flag = true});

  @override
  @JsonKey()
  final bool flag;

  @override
  String toString() {
    return 'GenericUnion<$T>.third(flag: $flag)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenericUnionThird<T> &&
            const DeepCollectionEquality().equals(other.flag, flag));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(flag));

  @JsonKey(ignore: true)
  @override
  _$$GenericUnionThirdCopyWith<T, _$GenericUnionThird<T>> get copyWith =>
      __$$GenericUnionThirdCopyWithImpl<T, _$GenericUnionThird<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number, T value) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return third(flag);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number, T value)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return third?.call(flag);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number, T value)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
    required TResult orElse(),
  }) {
    if (third != null) {
      return third(flag);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GenericUnionFirst<T> value) first,
    required TResult Function(GenericUnionSecond<T> value) second,
    required TResult Function(GenericUnionThird<T> value) third,
  }) {
    return third(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GenericUnionFirst<T> value)? first,
    TResult Function(GenericUnionSecond<T> value)? second,
    TResult Function(GenericUnionThird<T> value)? third,
  }) {
    return third?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GenericUnionFirst<T> value)? first,
    TResult Function(GenericUnionSecond<T> value)? second,
    TResult Function(GenericUnionThird<T> value)? third,
    required TResult orElse(),
  }) {
    if (third != null) {
      return third(this);
    }
    return orElse();
  }
}

abstract class GenericUnionThird<T> implements GenericUnion<T> {
  const factory GenericUnionThird({final bool flag}) = _$GenericUnionThird<T>;

  bool get flag;
  @JsonKey(ignore: true)
  _$$GenericUnionThirdCopyWith<T, _$GenericUnionThird<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
