import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' show TypeReference;
import 'package:collection/collection.dart';

void main() {}

class ResolvedType {
  final String? import;
  final String name;
  final bool isNullable;
  final List<ResolvedType> typeArguments;
  final DartType dartType;

  String get fullName => dartType
      .getDisplayString(withNullability: false)
      .replaceAll(RegExp(r'[\s>]'), '')
      .replaceAll(RegExp(r'[,<]'), '_');

  String get fullNameAsSerializer => '_${fullName}Serializer';

  bool get isMap {
    return dartType.isDartCoreMap;
  }

  bool get isJson =>
      isMap &&
      typeArguments[0].dartType.isDartCoreString &&
      typeArguments[1].dartType is DynamicType;

  bool get isListOrMap {
    return isList || isMap;
  }

  bool get isList {
    return dartType.isDartCoreList;
  }

  List<ResolvedType> _getDistinctTypesWithDisplayNameOf(
    List<ResolvedType> types,
  ) {
    final typeNames = <String>{};
    final typeNamesDistinct = <ResolvedType>[];

    for (final f in types) {
      if (typeNames.add(
        f.dartType.getDisplayString(withNullability: false),
      )) typeNamesDistinct.add(f);
    }

    return typeNamesDistinct;
  }

  List<ResolvedType> distinctFlatTypes({
    bool Function(ResolvedType type) skip = _flatTypesSkip,
  }) =>
      _getDistinctTypesWithDisplayNameOf(flatTypes().toSet().toList());

  static bool _flatTypesSkip(ResolvedType type) => false;

  List<ResolvedType> flatTypes({
    bool Function(ResolvedType type) skip = _flatTypesSkip,
  }) {
    List<ResolvedType> _flatTypes(ResolvedType type) {
      final result = <ResolvedType>[if (!skip(type)) type];

      for (final t in type.typeArguments) {
        if (skip(t)) continue;
        if (t.typeArguments.isEmpty) result.add(t);
        final inners = _flatTypes(t);
        result.addAll(inners);
      }

      return result;
    }

    return _flatTypes(this);
  }

  bool isPrimitiveOrListOrMap({
    bool Function(ResolvedType type) skip = _flatTypesSkip,
  }) =>
      flatTypes(skip: skip).every(
        (e) => e.isList || e.isMap || e.isPrimitive,
      );

  ResolvedType? get listTypeArgument => !isList ? null : typeArguments.first;

  bool get isPrimitiveList {
    return isList &&
        typeArguments.every(
          (t) => _isPrimitive(t.dartType),
        );
  }

  bool get isPrimitiveNestedMapOrList {
    return (isMap || isList) &&
        typeArguments.every(
          (t) => _isPrimitive(t.dartType) || t.isPrimitiveNestedMapOrList,
        );
  }

  bool get isPrimitiveNestedList {
    return isList &&
        typeArguments.every(
          (t) => _isPrimitive(t.dartType) || t.isPrimitiveNestedList,
        );
  }

  bool _isPrimitive(DartType t) {
    return t is DynamicType ||
        t.isDartCoreBool ||
        t.isDartCoreString ||
        t.isDartCoreDouble ||
        t.isDartCoreNum ||
        t.isDartCoreInt;
  }

  bool get isPrimitive => _isPrimitive(dartType);

  ResolvedType({
    required this.name,
    this.import,
    this.typeArguments = const [],
    this.isNullable = false,
    required this.dartType,
  });

  bool _hasGenericNameOf(DartType t) {
    return typeArguments.firstWhereOrNull(
          (element) {
            return element.dartType.getDisplayString(withNullability: false) ==
                t.getDisplayString(withNullability: false);
          },
        ) !=
        null;
  }

  bool hasDeepGenericOf(DartType dartType) => _hasDeepGenericOf(dartType, this);

  bool _hasDeepGenericOf(DartType type, ResolvedType t) {
    if (t.typeArguments.isEmpty) return false;
    final has = t._hasGenericNameOf(type);

    if (has) return true;
    return t.typeArguments
        .map((e) => _hasDeepGenericOf(type, e))
        .reduce((value, element) => value || element);
  }

  String get identity => "$import#$name";

  TypeReference get referAsNullable => TypeReference(
        (b) => b
          ..symbol = dartType.getDisplayString(withNullability: true)
          ..url = import
          ..isNullable = isNullable
          ..types.addAll(typeArguments.map((e) => e.refer)),
      );

  TypeReference get refer => TypeReference((b) => b
    ..symbol = name
    ..url = import
    ..isNullable = isNullable
    ..types.addAll(typeArguments.map((e) => e.refer)));

  TypeReference get baseRefer => TypeReference(
        (b) => b
          ..symbol = name
          ..url = import
          ..isNullable = isNullable,
      );
  @override
  String toString() {
    if (typeArguments.isEmpty) return name;
    return '$name<${typeArguments.join(',')}>';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedType &&
          runtimeType == other.runtimeType &&
          identity == other.identity;

  @override
  int get hashCode => import.hashCode ^ name.hashCode;

  ResolvedType copyWith({
    String? import,
    String? name,
    List<ResolvedType>? typeArguments,
    bool? isNullable,
    DartType? dartType,
  }) {
    return ResolvedType(
      dartType: dartType ?? this.dartType,
      import: import ?? this.import,
      name: name ?? this.name,
      isNullable: isNullable ?? this.isNullable,
      typeArguments: typeArguments ?? this.typeArguments,
    );
  }
}
