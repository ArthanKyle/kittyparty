class AgencyWithdrawDto {
  final String id;
  final String agencyId;
  final String agentUserIdentification;
  final int diamonds;
  final double usdAmount;
  final String status;
  final String note;
  final DateTime createdAt;
  final DateTime? processedAt;

  AgencyWithdrawDto({
    required this.id,
    required this.agencyId,
    required this.agentUserIdentification,
    required this.diamonds,
    required this.usdAmount,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.processedAt,
  });

  factory AgencyWithdrawDto.fromJson(Map<String, dynamic> json) {
    return AgencyWithdrawDto(
      id: json["_id"],
      agencyId: json["agencyId"],
      agentUserIdentification: json["agentUserIdentification"],
      diamonds: json["diamonds"],
      usdAmount: (json["usdAmount"] as num).toDouble(),
      status: json["status"],
      note: json["note"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      processedAt: json["processedAt"] != null
          ? DateTime.parse(json["processedAt"])
          : null,
    );
  }
}
