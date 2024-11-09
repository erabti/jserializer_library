import 'dart:collection';

import 'type_info.dart';
import 'type_plus.dart';
import 'type_switcher.dart';
import 'types_registry.dart';
import 'unresolved_type.dart';
import 'utils.dart';

class TypeMatch {
  final List<Function> bases;
  final List<TypeMatch> args;
  final bool isNullable;
  final TypeRegistry typeRegistry;

  TypeMatch.fromInfo(this.typeRegistry, TypeInfo info)
      : bases = typeRegistry.getFactoriesByName(info.type),
        args = info.args.map((i) => TypeMatch.fromInfo(typeRegistry, i)).toList(),
        isNullable = info.isNullable;

  Iterable<ResolvedType> resolve() sync* {
    for (var o in args.map((m) => m.resolve()).power()) {
      for (var b in bases) {
        yield ResolvedType(typeRegistry, b, o.toList(), isNullable: isNullable);
      }
    }
  }
}

class ResolvedType {
  final Type base;
  final Function factory;
  final List<ResolvedType> args;
  final bool isNullable;

  static final Map<Type, ResolvedType> _resolvedTypes = HashMap();

  late final Function _resolvedFactory;
  late final Type _reverseType;

  final TypeRegistry typeRegistry;

  static dynamic _type<T>(dynamic Function<T>() f) => f<T>();

  ResolvedType(this.typeRegistry, this.factory, this.args, {this.isNullable = false}) : base = factory(typeOf) {
    try {
      _resolvedFactory = TypeSwitcher.apply(factory, [<T>() => isNullable ? _type<T?> : _type<T>], args);
    } on TypeError catch (_) {
      _resolvedFactory = UnresolvedType.factory(1);
    } on ArgumentError catch (_) {
      _resolvedFactory = UnresolvedType.factory(1);
    }
    _reverseType = _resolvedFactory(typeOf);
    if (_reverseType != UnresolvedType) {
      _resolvedTypes[_reverseType] = this;
    }
  }

  factory ResolvedType.unresolved(TypeRegistry typeRegistry, TypeInfo info) {
    return ResolvedType(
      typeRegistry,
      UnresolvedType.factory(info.args.length),
      info.args.map((i) => ResolvedType.unresolved(typeRegistry, i)).toList(),
    );
  }

  R provideTo<R>(R Function<U>() fn) {
    return _resolvedFactory(fn);
  }

  Type get reversed => _reverseType;

  List<Type> get argsAsTypes => args.map((p) => p.reversed).toList();

  String get id {
    var nullSuffix = isNullable ? '?' : '';
    if (args.isNotEmpty) {
      return '${base.resolveWith(typeRegistry).baseId}<${args.map((r) => r.id).join(',')}>$nullSuffix';
    } else {
      return '$baseId$nullSuffix';
    }
  }

  String get baseId {
    return typeRegistry.idOf(base) ?? '';
  }

  late ResolvedType nonNull = !isNullable ? this : ResolvedType(typeRegistry, factory, args);

  static ResolvedType from<T>(TypeRegistry typeRegistry, [Type? t]) {
    var type = t ?? T;

    if (_resolvedTypes[type] != null) {
      return _resolvedTypes[type]!;
    }

    var info = TypeInfo.fromType(type);
    var match = TypeMatch.fromInfo(typeRegistry, info);

    var resolved = match.resolve().where((o) => o.reversed == type).firstOrNull;
    return resolved ?? ResolvedType.unresolved(typeRegistry, info);
  }

  @override
  String toString() => 'ResolvedType{base: $base, args: $args}';

  bool implements(Type t) {
    if (t == dynamic) return true;
    if (t == base) return true;

    var superFn = typeRegistry.getSuperFactories(baseId);

    for (var fn in superFn) {
      var st = TypeSwitcher.apply(fn, [typeOf], args) as Type;

      if (st == t || st.resolveWith(typeRegistry).implements(t)) {
        return true;
      }
    }
    return false;
  }
}
