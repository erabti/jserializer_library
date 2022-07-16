import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jserializer/jserializer.dart';

part 'union.freezed.dart';

@JUnion(
  typeKey: 'type',
  fallbackName: 'the_second',
)
@freezed
class Union with _$Union {
  const factory Union.first({
    @Default(32) int number,
  }) = UnionFirst;
  @JUnionValue(name: 'the_second')
  const factory Union.second({
    @Default('Hello') String greeting,
  }) = UnionSecond;
  const factory Union.third({
    @Default(true) bool flag,
  }) = UnionThird;
}



