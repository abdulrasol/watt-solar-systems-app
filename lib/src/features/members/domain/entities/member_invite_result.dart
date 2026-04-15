class MemberInviteResult {
  final bool requiresRegistration;
  final String message;
  final String messageUser;

  const MemberInviteResult({
    required this.requiresRegistration,
    required this.message,
    required this.messageUser,
  });
}
