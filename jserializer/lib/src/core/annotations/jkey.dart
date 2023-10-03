class JKey {
  const JKey({
    this.name,
    this.ignore = false,
  })  : isExtras = false,
        overridesToJsonModelFields = false;

  const JKey.extras({this.overridesToJsonModelFields = false})
      : name = null,
        ignore = true,
        isExtras = true;

  final bool isExtras;
  final bool ignore;
  final String? name;
  final bool overridesToJsonModelFields;
}
