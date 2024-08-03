class JKey {
  const JKey({
    this.name,
    this.ignore = false,
    this.fallbackName,
    this.mockValue,
  })  : isExtras = false,
        overridesToJsonModelFields = false;

  const JKey.extras({this.overridesToJsonModelFields = false})
      : name = null,
        ignore = true,
        isExtras = true,
        mockValue = null,
        fallbackName = null;

  final bool isExtras;
  final bool ignore;
  final String? name;
  final bool overridesToJsonModelFields;
  final String? fallbackName;
  final dynamic mockValue;
}
