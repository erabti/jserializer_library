class JKey {
  const JKey({
    this.name,
    this.ignore = false,
  })  : isExtras = false,
        overridesFields = false;

  const JKey.extras({
    this.overridesFields = false,
  })  : name = null,
        ignore = true,
        isExtras = true;

  final bool isExtras;
  final bool ignore;
  final String? name;
  final bool overridesFields;
}
