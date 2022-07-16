import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jserializer/jserializer.dart';

part 'generic_union.freezed.dart';

@JUnion()
@freezed
class GenericUnion<T> with _$GenericUnion<T> {
  const factory GenericUnion.first({
    @Default(32) int number,
    required T value,
  }) = GenericUnionFirst<T>;
  @JUnionValue(name: 'the_second')
  const factory GenericUnion.second({
    @Default('Hello') String greeting,
  }) = GenericUnionSecond<T>;
  const factory GenericUnion.third({
    @Default(true) bool flag,
  }) = GenericUnionThird<T>;
}
