import 'package:type_plus/src/type_info.dart';

import 'resolved_type.dart';
import 'type_switcher.dart';
import 'types_registry.dart';

extension TypePlus on Type {
  TypeInfo get info => TypeInfo.fromType(this);

  ResolvedType resolveWith(TypeRegistry typeRegistry) => ResolvedType.from(typeRegistry, this);
}

/// A TypeProvider is used to handle types without needing to manually add their factory functions.
abstract class TypeProvider {
  /// Get a type factory from a type id
  Function? getFactoryById(String id);

  /// Get a list of type factories from a type name
  List<Function> getFactoriesByName(String name);

  /// Get the id of a type
  String? idOf(Type type);
}

/// Extension to call any function with generic type arguments.
extension FunctionPlus on Function {
  dynamic callWith({
    required TypeRegistry typeRegistry,
    List<dynamic>? parameters,
    List<Type>? typeArguments,
  }) {
    return TypeSwitcher.apply(
      this,
      parameters ?? [],
      typeArguments?.map((t) => ResolvedType.from(typeRegistry, t)).toList() ?? [],
    );
  }
}
