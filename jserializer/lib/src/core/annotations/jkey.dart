class JKey {
  const JKey({
    this.name,
    this.ignore = false,
    this.fallbackName,
  })  : isExtras = false,
        overridesToJsonModelFields = false;

  const JKey.extras({this.overridesToJsonModelFields = false})
      : name = null,
        ignore = true,
        isExtras = true,
        fallbackName = null;

  final bool isExtras;
  final bool ignore;
  final String? name;
  final bool overridesToJsonModelFields;
  final String? fallbackName;
}
