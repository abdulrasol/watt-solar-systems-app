class PosterEntity {
  final int id;
  final int companyId;
  final String? companyName;
  final String? imageUrl;
  final String? text;
  final String actionType;
  final int? actionId;
  final String status;
  final bool isActive;
  final int? durationDays;
  final DateTime? approvedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PosterEntity({
    required this.id,
    required this.companyId,
    this.companyName,
    this.imageUrl,
    this.text,
    required this.actionType,
    this.actionId,
    required this.status,
    required this.isActive,
    this.durationDays,
    this.approvedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
}
