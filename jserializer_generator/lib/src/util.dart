import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:jserializer_generator/src/generator.dart';
import 'package:jserializer_generator/src/type_resolver.dart';
import 'package:source_gen/source_gen.dart';

extension DartTypeJSerializerX on DartType {
  String getDisplayStringWithoutNullability() {
    final displayString = getDisplayString(withNullability: true);

    return displayString.replaceAll('?', '');
  }
}

extension InterfaceElementX on InterfaceElement {
  PropertyAccessorElement? safeLookupGetter({
    required String name,
    required LibraryElement library,
  }) {
    return lookUpGetter(name, library);
  }

  String getDisplayStringWithoutNullability() {
    final displayString = getDisplayString(withNullability: true);

    return displayString.replaceAll('?', '');
  }
}

InterfaceType? getMatchingSuperType({
  required InterfaceElement element,
  required String superTypeName,
}) {
  final superTypes = element.allSupertypes;

  for (final superType in superTypes) {
    if (superType.element.displayName == superTypeName) {
      return superType;
    }
  }

  return null;
}

List<CustomAdapterConfig> getParamAdapters({
  required InterfaceElement parentClass,
  required TypeChecker typeChecker,
  required ParameterElement param,
  required TypeResolver typeResolver,
  required String parentAdapterClassName,
}) {
  return param.metadata
      .map((element) => element.computeConstantValue())
      .where(
        (element) =>
            element?.type?.element != null &&
            typeChecker.isAssignableFrom(element!.type!.element!),
      )
      .whereType<DartObject>()
      .map((e) => ConstantReader(e))
      .where((e) => !e.revive().isPrivate)
      .map(
    (e) {
      final adapterResolvedType = typeResolver.resolveType(e.objectValue.type!);
      final clazz = e.objectValue.type!.element! as InterfaceElement;
      final customerAdapterType = getMatchingSuperType(
        element: clazz,
        superTypeName: parentAdapterClassName,
      );

      if (customerAdapterType == null) {
        throw Exception(
          'JSerializationGenerationError '
          '[${parentClass.name}.${param.name}]:\n'
          'The adapter [$adapterResolvedType] used does not extend '
          '[$parentAdapterClassName].',
        );
      }

      final resolvedAdapter = typeResolver.resolveType(customerAdapterType);
      final adapterModelGenericType = resolvedAdapter.typeArguments.first;
      final paramType = typeResolver.resolveType(param.type);

      if (adapterModelGenericType.isNullable &&
          !adapterResolvedType.isNullable &&
          param.isRequired) {
        throw Exception(
          'JSerializationGenerationError '
          '[${parentClass.name}.${param.name}]:\n'
          'The adapter [$adapterResolvedType] used is nullable while '
          'the parameter is a non nullable required type of '
          '[$paramType].',
        );
      }

      if (adapterModelGenericType.identity != paramType.identity) {
        throw Exception(
          'JSerializationGenerationError '
          '[${parentClass.name}.${param.name}]:\n'
          'The adapter [$adapterResolvedType] used takes the type '
          '[$adapterModelGenericType] but the parameter takes the type '
          '[$paramType]',
        );
      }

      return CustomAdapterConfig(
        param: param,
        reader: e,
        revivable: e.revive(),
        type: adapterResolvedType,
        jsonType: resolvedAdapter.typeArguments[0],
        modelType: adapterModelGenericType,
      );
    },
  ).toList();
}
