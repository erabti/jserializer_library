import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jserializer/jserializer.dart';

part 'union2.freezed.dart';

@JUnion(typeKey: 'type')
@freezed
class Union2 with _$Union2 {
  const factory Union2.first({
    @Default(32) int number,
    required int number2,
    String? something,
  }) = Union2First;
  @JUnionValue(name: 'the_second')
  const factory Union2.second({
    @Default('Hello') String greeting,
  }) = Union2Second;
  const factory Union2.third({
    @Default(true) bool flag,
  }) = Union2Third;
}
