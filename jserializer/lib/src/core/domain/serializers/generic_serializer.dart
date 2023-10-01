import 'package:jserializer/jserializer.dart';
import 'package:type_plus/type_plus.dart';

abstract class GenericSerializer<Model, Json> extends Serializer<Model, Json> {
  const GenericSerializer({super.jSerializer});

  M fromJson<M extends Model?>(Json json) {
    final result = decoder.callWith(
      parameters: [json],
      typeArguments: M.args,
    );

    try {
      return result as M;
    } catch (error) {
      throw LocationAwareJSerializerError(
        location: 'GenericSerializer: $this',
        error: error,
      );
    }
  }
}

abstract class GenericModelSerializer<Model>
    extends GenericSerializer<Model, Map> {
  const GenericModelSerializer({super.jSerializer});
}
