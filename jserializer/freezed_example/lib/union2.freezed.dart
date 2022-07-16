// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'union2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Union2 {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number, int number2, String? something) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number, int number2, String? something)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number, int number2, String? something)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Union2First value) first,
    required TResult Function(Union2Second value) second,
    required TResult Function(Union2Third value) third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Union2First value)? first,
    TResult Function(Union2Second value)? second,
    TResult Function(Union2Third value)? third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Union2First value)? first,
    TResult Function(Union2Second value)? second,
    TResult Function(Union2Third value)? third,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $Union2CopyWith<$Res> {
  factory $Union2CopyWith(Union2 value, $Res Function(Union2) then) =
      _$Union2CopyWithImpl<$Res>;
}

/// @nodoc
class _$Union2CopyWithImpl<$Res> implements $Union2CopyWith<$Res> {
  _$Union2CopyWithImpl(this._value, this._then);

  final Union2 _value;
  // ignore: unused_field
  final $Res Function(Union2) _then;
}

/// @nodoc
abstract class _$$Union2FirstCopyWith<$Res> {
  factory _$$Union2FirstCopyWith(
          _$Union2First value, $Res Function(_$Union2First) then) =
      __$$Union2FirstCopyWithImpl<$Res>;
  $Res call({int number, int number2, String? something});
}

/// @nodoc
class __$$Union2FirstCopyWithImpl<$Res> extends _$Union2CopyWithImpl<$Res>
    implements _$$Union2FirstCopyWith<$Res> {
  __$$Union2FirstCopyWithImpl(
      _$Union2First _value, $Res Function(_$Union2First) _then)
      : super(_value, (v) => _then(v as _$Union2First));

  @override
  _$Union2First get _value => super._value as _$Union2First;

  @override
  $Res call({
    Object? number = freezed,
    Object? number2 = freezed,
    Object? something = freezed,
  }) {
    return _then(_$Union2First(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      number2: number2 == freezed
          ? _value.number2
          : number2 // ignore: cast_nullable_to_non_nullable
              as int,
      something: something == freezed
          ? _value.something
          : something // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$Union2First implements Union2First {
  const _$Union2First(
      {this.number = 32, required this.number2, this.something});

  @override
  @JsonKey()
  final int number;
  @override
  final int number2;
  @override
  final String? something;

  @override
  String toString() {
    return 'Union2.first(number: $number, number2: $number2, something: $something)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Union2First &&
            const DeepCollectionEquality().equals(other.number, number) &&
            const DeepCollectionEquality().equals(other.number2, number2) &&
            const DeepCollectionEquality().equals(other.something, something));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(number),
      const DeepCollectionEquality().hash(number2),
      const DeepCollectionEquality().hash(something));

  @JsonKey(ignore: true)
  @override
  _$$Union2FirstCopyWith<_$Union2First> get copyWith =>
      __$$Union2FirstCopyWithImpl<_$Union2First>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number, int number2, String? something) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return first(number, number2, something);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number, int number2, String? something)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return first?.call(number, number2, something);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number, int number2, String? something)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
    required TResult orElse(),
  }) {
    if (first != null) {
      return first(number, number2, something);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Union2First value) first,
    required TResult Function(Union2Second value) second,
    required TResult Function(Union2Third value) third,
  }) {
    return first(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Union2First value)? first,
    TResult Function(Union2Second value)? second,
    TResult Function(Union2Third value)? third,
  }) {
    return first?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Union2First value)? first,
    TResult Function(Union2Second value)? second,
    TResult Function(Union2Third value)? third,
    required TResult orElse(),
  }) {
    if (first != null) {
      return first(this);
    }
    return orElse();
  }
}

abstract class Union2First implements Union2 {
  const factory Union2First(
      {final int number,
      required final int number2,
      final String? something}) = _$Union2First;

  int get number;
  int get number2;
  String? get something;
  @JsonKey(ignore: true)
  _$$Union2FirstCopyWith<_$Union2First> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Union2SecondCopyWith<$Res> {
  factory _$$Union2SecondCopyWith(
          _$Union2Second value, $Res Function(_$Union2Second) then) =
      __$$Union2SecondCopyWithImpl<$Res>;
  $Res call({String greeting});
}

/// @nodoc
class __$$Union2SecondCopyWithImpl<$Res> extends _$Union2CopyWithImpl<$Res>
    implements _$$Union2SecondCopyWith<$Res> {
  __$$Union2SecondCopyWithImpl(
      _$Union2Second _value, $Res Function(_$Union2Second) _then)
      : super(_value, (v) => _then(v as _$Union2Second));

  @override
  _$Union2Second get _value => super._value as _$Union2Second;

  @override
  $Res call({
    Object? greeting = freezed,
  }) {
    return _then(_$Union2Second(
      greeting: greeting == freezed
          ? _value.greeting
          : greeting // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JUnionValue(name: 'the_second')
class _$Union2Second implements Union2Second {
  const _$Union2Second({this.greeting = 'Hello'});

  @override
  @JsonKey()
  final String greeting;

  @override
  String toString() {
    return 'Union2.second(greeting: $greeting)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Union2Second &&
            const DeepCollectionEquality().equals(other.greeting, greeting));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(greeting));

  @JsonKey(ignore: true)
  @override
  _$$Union2SecondCopyWith<_$Union2Second> get copyWith =>
      __$$Union2SecondCopyWithImpl<_$Union2Second>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number, int number2, String? something) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return second(greeting);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number, int number2, String? something)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return second?.call(greeting);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number, int number2, String? something)? first,
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
    required TResult Function(Union2First value) first,
    required TResult Function(Union2Second value) second,
    required TResult Function(Union2Third value) third,
  }) {
    return second(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Union2First value)? first,
    TResult Function(Union2Second value)? second,
    TResult Function(Union2Third value)? third,
  }) {
    return second?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Union2First value)? first,
    TResult Function(Union2Second value)? second,
    TResult Function(Union2Third value)? third,
    required TResult orElse(),
  }) {
    if (second != null) {
      return second(this);
    }
    return orElse();
  }
}

abstract class Union2Second implements Union2 {
  const factory Union2Second({final String greeting}) = _$Union2Second;

  String get greeting;
  @JsonKey(ignore: true)
  _$$Union2SecondCopyWith<_$Union2Second> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Union2ThirdCopyWith<$Res> {
  factory _$$Union2ThirdCopyWith(
          _$Union2Third value, $Res Function(_$Union2Third) then) =
      __$$Union2ThirdCopyWithImpl<$Res>;
  $Res call({bool flag});
}

/// @nodoc
class __$$Union2ThirdCopyWithImpl<$Res> extends _$Union2CopyWithImpl<$Res>
    implements _$$Union2ThirdCopyWith<$Res> {
  __$$Union2ThirdCopyWithImpl(
      _$Union2Third _value, $Res Function(_$Union2Third) _then)
      : super(_value, (v) => _then(v as _$Union2Third));

  @override
  _$Union2Third get _value => super._value as _$Union2Third;

  @override
  $Res call({
    Object? flag = freezed,
  }) {
    return _then(_$Union2Third(
      flag: flag == freezed
          ? _value.flag
          : flag // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$Union2Third implements Union2Third {
  const _$Union2Third({this.flag = true});

  @override
  @JsonKey()
  final bool flag;

  @override
  String toString() {
    return 'Union2.third(flag: $flag)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Union2Third &&
            const DeepCollectionEquality().equals(other.flag, flag));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(flag));

  @JsonKey(ignore: true)
  @override
  _$$Union2ThirdCopyWith<_$Union2Third> get copyWith =>
      __$$Union2ThirdCopyWithImpl<_$Union2Third>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number, int number2, String? something) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return third(flag);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number, int number2, String? something)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return third?.call(flag);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number, int number2, String? something)? first,
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
    required TResult Function(Union2First value) first,
    required TResult Function(Union2Second value) second,
    required TResult Function(Union2Third value) third,
  }) {
    return third(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Union2First value)? first,
    TResult Function(Union2Second value)? second,
    TResult Function(Union2Third value)? third,
  }) {
    return third?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Union2First value)? first,
    TResult Function(Union2Second value)? second,
    TResult Function(Union2Third value)? third,
    required TResult orElse(),
  }) {
    if (third != null) {
      return third(this);
    }
    return orElse();
  }
}

abstract class Union2Third implements Union2 {
  const factory Union2Third({final bool flag}) = _$Union2Third;

  bool get flag;
  @JsonKey(ignore: true)
  _$$Union2ThirdCopyWith<_$Union2Third> get copyWith =>
      throw _privateConstructorUsedError;
}
