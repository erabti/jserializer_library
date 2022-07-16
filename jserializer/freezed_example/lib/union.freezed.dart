// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'union.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Union {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UnionFirst value) first,
    required TResult Function(UnionSecond value) second,
    required TResult Function(UnionThird value) third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(UnionFirst value)? first,
    TResult Function(UnionSecond value)? second,
    TResult Function(UnionThird value)? third,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UnionFirst value)? first,
    TResult Function(UnionSecond value)? second,
    TResult Function(UnionThird value)? third,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnionCopyWith<$Res> {
  factory $UnionCopyWith(Union value, $Res Function(Union) then) =
      _$UnionCopyWithImpl<$Res>;
}

/// @nodoc
class _$UnionCopyWithImpl<$Res> implements $UnionCopyWith<$Res> {
  _$UnionCopyWithImpl(this._value, this._then);

  final Union _value;
  // ignore: unused_field
  final $Res Function(Union) _then;
}

/// @nodoc
abstract class _$$UnionFirstCopyWith<$Res> {
  factory _$$UnionFirstCopyWith(
          _$UnionFirst value, $Res Function(_$UnionFirst) then) =
      __$$UnionFirstCopyWithImpl<$Res>;
  $Res call({int number});
}

/// @nodoc
class __$$UnionFirstCopyWithImpl<$Res> extends _$UnionCopyWithImpl<$Res>
    implements _$$UnionFirstCopyWith<$Res> {
  __$$UnionFirstCopyWithImpl(
      _$UnionFirst _value, $Res Function(_$UnionFirst) _then)
      : super(_value, (v) => _then(v as _$UnionFirst));

  @override
  _$UnionFirst get _value => super._value as _$UnionFirst;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_$UnionFirst(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$UnionFirst implements UnionFirst {
  const _$UnionFirst({this.number = 32});

  @override
  @JsonKey()
  final int number;

  @override
  String toString() {
    return 'Union.first(number: $number)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnionFirst &&
            const DeepCollectionEquality().equals(other.number, number));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(number));

  @JsonKey(ignore: true)
  @override
  _$$UnionFirstCopyWith<_$UnionFirst> get copyWith =>
      __$$UnionFirstCopyWithImpl<_$UnionFirst>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return first(number);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return first?.call(number);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
    required TResult orElse(),
  }) {
    if (first != null) {
      return first(number);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UnionFirst value) first,
    required TResult Function(UnionSecond value) second,
    required TResult Function(UnionThird value) third,
  }) {
    return first(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(UnionFirst value)? first,
    TResult Function(UnionSecond value)? second,
    TResult Function(UnionThird value)? third,
  }) {
    return first?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UnionFirst value)? first,
    TResult Function(UnionSecond value)? second,
    TResult Function(UnionThird value)? third,
    required TResult orElse(),
  }) {
    if (first != null) {
      return first(this);
    }
    return orElse();
  }
}

abstract class UnionFirst implements Union {
  const factory UnionFirst({final int number}) = _$UnionFirst;

  int get number;
  @JsonKey(ignore: true)
  _$$UnionFirstCopyWith<_$UnionFirst> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnionSecondCopyWith<$Res> {
  factory _$$UnionSecondCopyWith(
          _$UnionSecond value, $Res Function(_$UnionSecond) then) =
      __$$UnionSecondCopyWithImpl<$Res>;
  $Res call({String greeting});
}

/// @nodoc
class __$$UnionSecondCopyWithImpl<$Res> extends _$UnionCopyWithImpl<$Res>
    implements _$$UnionSecondCopyWith<$Res> {
  __$$UnionSecondCopyWithImpl(
      _$UnionSecond _value, $Res Function(_$UnionSecond) _then)
      : super(_value, (v) => _then(v as _$UnionSecond));

  @override
  _$UnionSecond get _value => super._value as _$UnionSecond;

  @override
  $Res call({
    Object? greeting = freezed,
  }) {
    return _then(_$UnionSecond(
      greeting: greeting == freezed
          ? _value.greeting
          : greeting // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JUnionValue(name: 'the_second')
class _$UnionSecond implements UnionSecond {
  const _$UnionSecond({this.greeting = 'Hello'});

  @override
  @JsonKey()
  final String greeting;

  @override
  String toString() {
    return 'Union.second(greeting: $greeting)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnionSecond &&
            const DeepCollectionEquality().equals(other.greeting, greeting));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(greeting));

  @JsonKey(ignore: true)
  @override
  _$$UnionSecondCopyWith<_$UnionSecond> get copyWith =>
      __$$UnionSecondCopyWithImpl<_$UnionSecond>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return second(greeting);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return second?.call(greeting);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number)? first,
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
    required TResult Function(UnionFirst value) first,
    required TResult Function(UnionSecond value) second,
    required TResult Function(UnionThird value) third,
  }) {
    return second(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(UnionFirst value)? first,
    TResult Function(UnionSecond value)? second,
    TResult Function(UnionThird value)? third,
  }) {
    return second?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UnionFirst value)? first,
    TResult Function(UnionSecond value)? second,
    TResult Function(UnionThird value)? third,
    required TResult orElse(),
  }) {
    if (second != null) {
      return second(this);
    }
    return orElse();
  }
}

abstract class UnionSecond implements Union {
  const factory UnionSecond({final String greeting}) = _$UnionSecond;

  String get greeting;
  @JsonKey(ignore: true)
  _$$UnionSecondCopyWith<_$UnionSecond> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnionThirdCopyWith<$Res> {
  factory _$$UnionThirdCopyWith(
          _$UnionThird value, $Res Function(_$UnionThird) then) =
      __$$UnionThirdCopyWithImpl<$Res>;
  $Res call({bool flag});
}

/// @nodoc
class __$$UnionThirdCopyWithImpl<$Res> extends _$UnionCopyWithImpl<$Res>
    implements _$$UnionThirdCopyWith<$Res> {
  __$$UnionThirdCopyWithImpl(
      _$UnionThird _value, $Res Function(_$UnionThird) _then)
      : super(_value, (v) => _then(v as _$UnionThird));

  @override
  _$UnionThird get _value => super._value as _$UnionThird;

  @override
  $Res call({
    Object? flag = freezed,
  }) {
    return _then(_$UnionThird(
      flag: flag == freezed
          ? _value.flag
          : flag // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$UnionThird implements UnionThird {
  const _$UnionThird({this.flag = true});

  @override
  @JsonKey()
  final bool flag;

  @override
  String toString() {
    return 'Union.third(flag: $flag)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnionThird &&
            const DeepCollectionEquality().equals(other.flag, flag));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(flag));

  @JsonKey(ignore: true)
  @override
  _$$UnionThirdCopyWith<_$UnionThird> get copyWith =>
      __$$UnionThirdCopyWithImpl<_$UnionThird>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number) first,
    required TResult Function(String greeting) second,
    required TResult Function(bool flag) third,
  }) {
    return third(flag);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number)? first,
    TResult Function(String greeting)? second,
    TResult Function(bool flag)? third,
  }) {
    return third?.call(flag);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number)? first,
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
    required TResult Function(UnionFirst value) first,
    required TResult Function(UnionSecond value) second,
    required TResult Function(UnionThird value) third,
  }) {
    return third(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(UnionFirst value)? first,
    TResult Function(UnionSecond value)? second,
    TResult Function(UnionThird value)? third,
  }) {
    return third?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UnionFirst value)? first,
    TResult Function(UnionSecond value)? second,
    TResult Function(UnionThird value)? third,
    required TResult orElse(),
  }) {
    if (third != null) {
      return third(this);
    }
    return orElse();
  }
}

abstract class UnionThird implements Union {
  const factory UnionThird({final bool flag}) = _$UnionThird;

  bool get flag;
  @JsonKey(ignore: true)
  _$$UnionThirdCopyWith<_$UnionThird> get copyWith =>
      throw _privateConstructorUsedError;
}
