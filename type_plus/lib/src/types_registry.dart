import 'dart:async';

import 'resolved_type.dart';
import 'type_info.dart';
import 'type_plus.dart';
import 'unresolved_type.dart';
import 'utils.dart';

Function ff<T>() => (dynamic Function<X>() f) => f<T>();

MapEntry<String, Iterable<Function>?> fd(String id, [Iterable<Function>? st]) => MapEntry(id, st);
final ffObj = ff<Object>();

final _sdkTypes = <(Function, String, Iterable<Function>?)>{
  ((dynamic Function<X>() f) => f<dynamic>(), 'dynamic', null),
  ((dynamic Function<X>() f) => f<void>(), 'void', null),
  ((dynamic Function<X>() f) => f<Null>(), 'Null', null),
  ((dynamic Function<X>() f) => f<Object>(), 'Object', null),
  ((dynamic Function<X>() f) => f<bool>(), 'bool', {ffObj}),
  (<T>(dynamic Function<X>() f) => f<Comparable<T>>(), 'Comparable', {ffObj}),
  ((dynamic Function<X>() f) => f<num>(), 'num', {ff<Comparable<num>>()}),
  ((dynamic Function<X>() f) => f<int>(), 'int', {ff<num>()}),
  ((dynamic Function<X>() f) => f<double>(), 'double', {ff<num>()}),
  ((dynamic Function<X>() f) => f<Pattern>(), 'Pattern', {ffObj}),
  ((dynamic Function<X>() f) => f<String>(), 'String', {ff<Comparable<String>>(), ff<Pattern>()}),
  (<T>(dynamic Function<X>() f) => f<Iterable<T>>(), 'Iterable', {ffObj}),
  (<T>(dynamic Function<X>() f) => f<List<T>>(), 'List', {<T>(dynamic Function<X>() f) => f<Iterable<T>>()}),
  (<T>(dynamic Function<X>() f) => f<Set<T>>(), 'Set', {<T>(dynamic Function<X>() f) => f<Iterable<T>>()}),
  (<K, V>(dynamic Function<X>() f) => f<Map<K, V>>(), 'Map', {ffObj}),
  ((dynamic Function<X>() f) => f<DateTime>(), 'DateTime', {ff<Comparable<DateTime>>()}),
  ((dynamic Function<X>() f) => f<Type>(), 'Type', {ffObj}),
  ((dynamic Function<X>() f) => f<Runes>(), 'Runes', {ff<Iterable<int>>()}),
  ((dynamic Function<X>() f) => f<Symbol>(), 'Symbol', {ffObj}),
  (<T>(dynamic Function<X>() f) => f<Future<T>>(), 'Future', {ffObj}),
  (<T>(dynamic Function<X>() f) => f<Stream<T>>(), 'Stream', {ffObj}),
};

class TypeRegistry {
  Map<Type, String> _typeToId = {};
  Map<String, Set<String>> _nameToId = {};
  Map<String, Function> _idToFactory = {};
  Map<String, Set<Function>> _idToSuperFactory = {};

  final Set<TypeProvider> typeProviders = {};

  static TypeRegistry? _instance;

  static TypeRegistry newInstance({
    TypeRegistry? parent,
  }) {
    final instance = TypeRegistry._();

    if (parent == null) {
      for (var (fn, id, sup) in _sdkTypes) {
        instance.add(fn, id: id, superTypes: sup);
      }
    } else {
      instance._typeToId = Map.of(parent._typeToId);
      instance._nameToId = Map.of(parent._nameToId);
      instance._idToFactory = Map.of(parent._idToFactory);
      instance._idToSuperFactory = Map.of(parent._idToSuperFactory);

      instance.typeProviders.addAll(parent.typeProviders);
    }

    return instance;
  }

  static TypeRegistry get instance {
    if (_instance == null) {
      _instance = TypeRegistry._();
      for (var (fn, id, sup) in _sdkTypes) {
        _instance!.add(fn, id: id, superTypes: sup);
      }
    }
    return _instance!;
  }

  TypeRegistry._();

  void add(Function factory, {String? id, Iterable<Function>? superTypes}) {
    Type type = factory(typeOf);

    if (id != null) {
      if (_idToFactory.containsKey(id)) {
        Type existingType = _idToFactory[id]!(typeOf);
        if (existingType != type) {
          throw UnsupportedError('Types must have a unique id. You tried to add type $type with id "$id", '
              'but this was already used for type $existingType.');
        }
      }
    }

    var typeId = id ?? _typeToId[type];

    if (typeId == null) {
      typeId = '${type.hashCode}';
      while (_idToFactory.containsKey(typeId)) {
        typeId = '${typeId}_';
      }
    }

    _idToFactory[typeId!] = factory;
    (_nameToId[type.info.type] ??= {}).add(typeId);
    _typeToId[type] = typeId;
    _idToSuperFactory[typeId] = superTypes?.toSet() ?? {ffObj};

    final resolvedType = type.resolveWith(this);

    if (resolvedType.base == UnresolvedType) {
      throw ArgumentError('Failed to add type $type. This may happen when you did register '
          'a used bound on a type parameter. Register all needed bounds before this type.');
    }
  }

  List<Function> getFactoriesByName(String name) {
    return (_nameToId[name] ?? {})
        .map((h) => _idToFactory[h]!)
        .followedBy(typeProviders.expand((p) => p.getFactoriesByName(name)))
        .toList();
  }

  void register(TypeProvider provider) {
    typeProviders.add(provider);
  }

  String? idOf(Type type) {
    return _typeToId[type] ?? typeProviders.fold(null, (id, p) => id ?? p.idOf(type));
  }

  Type fromId(String id) {
    var info = TypeInfo.fromString(id);

    ResolvedType resolve(TypeInfo info) {
      var factory = _idToFactory[info.type] ?? typeProviders.fold(null, (f, p) => f ?? p.getFactoryById(info.type));
      return factory != null
          ? ResolvedType(this, factory, info.args.map(resolve).toList(), isNullable: info.isNullable)
          : ResolvedType.unresolved(this, info);
    }

    return resolve(info).reversed;
  }

  Set<Function> getSuperFactories(String id) {
    return _idToSuperFactory[id] ?? {};
  }
}
