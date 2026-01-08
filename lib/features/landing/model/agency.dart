class AgencyDto {
  final String id;
  final String agencyCode;
  final String name;
  final String description;
  final String? logoUrl;
  final String ownerUserIdentification;
  final String status;
  final int maxMembers;
  final int membersCount;

  AgencyDto({
    required this.id,
    required this.agencyCode,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.ownerUserIdentification,
    required this.status,
    required this.maxMembers,
    required this.membersCount,
  });

  factory AgencyDto.fromJson(Map<String, dynamic> j) {
    return AgencyDto(
      id: (j["id"] ?? "").toString(),
      agencyCode: (j["agencyCode"] ?? "").toString(),
      name: (j["name"] ?? "").toString(),
      description: (j["description"] ?? "").toString(),
      logoUrl: j["logoUrl"]?.toString(),
      ownerUserIdentification: (j["ownerUserIdentification"] ?? "").toString(),
      status: (j["status"] ?? "").toString(),
      maxMembers: (j["maxMembers"] ?? 10) is int ? (j["maxMembers"] ?? 10) : int.tryParse("${j["maxMembers"]}") ?? 10,
      membersCount: (j["membersCount"] ?? 0) is int ? (j["membersCount"] ?? 0) : int.tryParse("${j["membersCount"]}") ?? 0,
    );
  }
}

class AgencyMemberDto {
  final String userIdentification;
  final String role;
  final DateTime? joinedAt;

  AgencyMemberDto({
    required this.userIdentification,
    required this.role,
    required this.joinedAt,
  });

  factory AgencyMemberDto.fromJson(Map<String, dynamic> j) {
    return AgencyMemberDto(
      userIdentification: (j["userIdentification"] ?? "").toString(),
      role: (j["role"] ?? "member").toString(),
      joinedAt: j["joinedAt"] == null ? null : DateTime.tryParse(j["joinedAt"].toString()),
    );
  }
}

class AgencyJoinRequestDto {
  final String id;
  final String applicantUserIdentification;
  final String status;
  final String agentContactValue;
  final String contactType;
  final String? agentIdCardUrl;
  final DateTime? createdAt;

  AgencyJoinRequestDto({
    required this.id,
    required this.applicantUserIdentification,
    required this.status,
    required this.agentContactValue,
    required this.contactType,
    required this.agentIdCardUrl,
    required this.createdAt,
  });

  factory AgencyJoinRequestDto.fromJson(Map<String, dynamic> j) {
    return AgencyJoinRequestDto(
      id: (j["_id"] ?? j["id"] ?? "").toString(),
      applicantUserIdentification: (j["applicantUserIdentification"] ?? "").toString(),
      status: (j["status"] ?? "").toString(),
      agentContactValue: (j["agentContactValue"] ?? "").toString(),
      contactType: (j["contactType"] ?? "").toString(),
      agentIdCardUrl: j["agentIdCardUrl"]?.toString(),
      createdAt: j["createdAt"] == null ? null : DateTime.tryParse(j["createdAt"].toString()),
    );
  }
}
