enum SessionStatus {
  restoring,
  unauthenticated,
  authenticatedOffline,
  authenticatedOnline,
}

class SessionSnapshot {
  const SessionSnapshot({
    required this.status,
    required this.epoch,
    this.accountId,
  });

  final SessionStatus status;
  final int epoch;
  final String? accountId;

  bool get isAuthenticated =>
      status == SessionStatus.authenticatedOffline ||
      status == SessionStatus.authenticatedOnline;
}
