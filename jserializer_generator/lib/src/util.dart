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

List<CustomAdapterConfig> getParamAdapters({
  required InterfaceElement parentClass,
  required TypeChecker typeChecker,
  required ParameterElement element,
  required TypeResolver typeResolver,
  required String parentAdapterClassName,
}) {
  return element.metadata
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
      final superType = clazz.supertype;
      final superName = superType?.element.displayName;

      InterfaceType? mixedWith(String name) => clazz.mixins
          .firstWhereOrNull((element) => element.element.displayName == name);

      InterfaceType? implementedWith(String name) => clazz.interfaces
          .firstWhereOrNull((element) => element.element.displayName == name);

      InterfaceType? extendsWith(String name) =>
          (superName == name ? superType : null) ??
          mixedWith(name) ??
          implementedWith(name);

      final customerAdapterType = extendsWith(parentAdapterClassName);

      final resolvedAdapter = typeResolver.resolveType(customerAdapterType!);
      final adapterModelGenericType = resolvedAdapter.typeArguments.first;
      final paramType = typeResolver.resolveType(element.type);

      if (adapterModelGenericType.isNullable &&
          !adapterResolvedType.isNullable &&
          element.isRequired) {
        throw Exception(
          'JSerializationGenerationError '
          '[${parentClass.name}.${element.name}]:\n'
          'The adapter [$adapterResolvedType] used is nullable while '
          'the parameter is a non nullable required type of '
          '[$paramType].',
        );
      }

      if (adapterModelGenericType.identity != paramType.identity) {
        throw Exception(
          'JSerializationGenerationError '
          '[${parentClass.name}.${element.name}]:\n'
          'The adapter [$adapterResolvedType] used takes the type '
          '[$adapterModelGenericType] but the parameter takes the type '
          '[$paramType]',
        );
      }

      return CustomAdapterConfig(
        reader: e,
        revivable: e.revive(),
        type: adapterResolvedType,
        jsonType: resolvedAdapter.typeArguments[0],
        modelType: adapterModelGenericType,
      );
    },
  ).toList();
}
