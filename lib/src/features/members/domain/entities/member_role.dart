enum MemberRole {
  admin,
  manager,
  staff,
  accountant,
  delivery,
  installer,
  inventory,
  sales;

  String get value => name;

  static MemberRole fromValue(String? value) {
    return MemberRole.values.firstWhere(
      (role) => role.value == value?.toLowerCase(),
      orElse: () => MemberRole.staff,
    );
  }
}
