import 'num_to_bool.dart';
import 'number.dart';
import 'string.dart';

export 'num_to_bool.dart';
export 'number.dart';
export 'string.dart';

abstract class JAdapters {
  const factory JAdapters.num({num? fallback, bool handleBool}) = JNumAdapter;

  const factory JAdapters.numNullable({num? fallback, bool handleBool}) =
      JNumNullableAdapter;

  const factory JAdapters.int({int? fallback, bool handleBool}) = JIntAdapter;

  const factory JAdapters.intNullable({int? fallback, bool handleBool}) =
      JIntNullableAdapter;

  const factory JAdapters.double({double? fallback, bool handleBool}) =
      JDoubleAdapter;

  const factory JAdapters.doubleNullable({double? fallback, bool handleBool}) =
      JDoubleNullableAdapter;

  const factory JAdapters.string() = JStringAdapter;

  const factory JAdapters.stringNullable() = JStringNullableAdapter;

  const factory JAdapters.numToBool({bool? fallback}) = JNumToBoolAdapter;

  const factory JAdapters.numToBoolNullable({bool? fallback}) =
      JNumToBoolNullableAdapter;
}
