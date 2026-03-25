import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart'
    show NullabilitySuffix;
import 'package:analyzer/dart/element/type.dart'
    show DartType, ParameterizedType;
import 'package:jserializer_generator/src/resolved_type.dart';
import 'package:jserializer_generator/src/util.dart';
import 'package:path/path.dart' as p;

class TypeResolver {
  final List<LibraryElement> libs;
  final Uri? targetFile;

  /// Element → exporting library index, built once at construction.
  /// Replaces the O(libs × exports) scan per resolveImport call.
  late final Map<Element, LibraryElement> _elementToLib = _buildElementIndex();

  /// Cache for resolveImport results (Element → import string).
  final Map<Element, String?> _importCache = {};

  /// Cache for resolveType results (DartType → ResolvedType).
  /// Uses DartType identity (identical object) for cache key.
  final Map<DartType, ResolvedType> _typeCache = {};

  TypeResolver(this.libs, this.targetFile);

  /// Builds a reverse index: Element → the first LibraryElement that exports it.
  /// This runs once and replaces the O(libs) scan in every resolveImport call.
  Map<Element, LibraryElement> _buildElementIndex() {
    final index = <Element, LibraryElement>{};
    for (final lib in libs) {
      if (_isCoreDartType(lib)) continue;
      for (final element in lib.exportNamespace.definedNames2.values) {
        // First library wins (matches original firstWhereOrNull behavior)
        index.putIfAbsent(element, () => lib);
      }
    }
    return index;
  }

  String? resolveImport(Element? element) {
    // return early if element has no library or element is a core type
    if (element?.library == null || _isCoreDartType(element!)) {
      return null;
    }

    // Check cache first
    if (_importCache.containsKey(element)) {
      return _importCache[element];
    }

    final lib = _elementToLib[element];
    String? result;
    if (lib != null) {
      result = targetFile == null
          ? lib.identifier
          : _relative(
              lib.uri,
              targetFile!,
            );
    }

    _importCache[element] = result;
    return result;
  }

  String _relative(Uri fileUri, Uri to) {
    var libName = to.pathSegments.first;
    if ((to.scheme == 'package' &&
            fileUri.scheme == 'package' &&
            fileUri.pathSegments.first == libName) ||
        (to.scheme == 'asset' && fileUri.scheme != 'package')) {
      if (fileUri.path == to.path) {
        return fileUri.pathSegments.last;
      } else {
        return p.posix
            .relative(fileUri.path, from: to.path)
            .replaceFirst('../', '');
      }
    } else {
      return fileUri.toString();
    }
  }

  bool _isCoreDartType(Element element) {
    return element.library?.isDartCore ?? false;
  }

  List<ResolvedType> _resolveTypeArguments(DartType typeToCheck) {
    final importableTypes = <ResolvedType>[];
    if (typeToCheck is ParameterizedType) {
      for (DartType type in typeToCheck.typeArguments) {
        importableTypes.add(resolveType(type));
      }
    }
    return importableTypes;
  }

  ResolvedType resolveType(DartType type) {
    // Check cache — DartType objects are identity-stable within a build session
    final cached = _typeCache[type];
    if (cached != null) return cached;

    final resolved = ResolvedType(
      dartType: type,
      name: type.element?.name ?? type.getDisplayStringWithoutNullability(),
      isNullable: type.nullabilitySuffix == NullabilitySuffix.question,
      import: resolveImport(type.element),
      typeArguments: _resolveTypeArguments(type),
    );

    _typeCache[type] = resolved;
    return resolved;
  }
}
