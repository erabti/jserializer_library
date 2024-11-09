import 'package:jserializer/jserializer.dart';
import 'package:type_plus/type_plus.dart';

abstract class GenericSerializer<Model, Json> extends Serializer<Model, Json> {
  const GenericSerializer({super.jSerializer});

  M fromJson<M extends Model?>(Json json) {
    final result = decoder.callWith(
      typeRegistry: jSerializer.typeRegistry,
      parameters: [json],
      typeArguments: M.resolveWith(jSerializer.typeRegistry).argsAsTypes,
    );

    try {
      return result as M;
    } catch (error) {
      throw LocationAwareJSerializerException(
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
