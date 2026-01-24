import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgencyDto {
  final String id;
  final String agencyCode;
  final String name;
  final String description;
  final List<dynamic> media;
  final String ownerUserIdentification;
  final int maxMembers;
  final int membersCount;
  final bool hasPendingRequest;

  AgencyDto({
    required this.id,
    required this.agencyCode,
    required this.name,
    required this.description,
    required this.media,
    required this.ownerUserIdentification,
    required this.maxMembers,
    required this.membersCount,
    this.hasPendingRequest = false,
  });

  factory AgencyDto.fromJson(Map<String, dynamic> j) {
    final baseUrl = dotenv.env['BASE_URL'] ?? "";

    String? resolvedLogoUrl;

    final logo = j["logo"];
    if (logo is Map<String, dynamic>) {
      final logoId = logo["id"]?.toString();
      if (logoId != null && logoId.isNotEmpty) {
        resolvedLogoUrl = "$baseUrl/media/$logoId";
      }
    }

    return AgencyDto(
      id: (j["id"] ?? "").toString(),
      agencyCode: (j["agencyCode"] ?? "").toString(),
      name: (j["name"] ?? "").toString(),
      description: (j["description"] ?? "").toString(),
      media: j["media"] ?? [],
      ownerUserIdentification: (j["ownerUserIdentification"] ?? "").toString(),
      maxMembers: j["maxMembers"] ?? 10,
      membersCount: j["membersCount"] ?? 0,
      hasPendingRequest: j["hasPendingRequest"] == true,
    );
  }
  /// Convenience
  String? get logoUrl {
    if (media.isEmpty) return null;
    final url = media.first["url"];
    return url is String ? url : null;
  }
}


class AgencyMemberDto {
  final String userIdentification;
  final String role;
  final String? username;
  final String? fullName;

  AgencyMemberDto({
    required this.userIdentification,
    required this.role,
    this.username,
    this.fullName,
  });

  factory AgencyMemberDto.fromJson(Map<String, dynamic> json) {
    return AgencyMemberDto(
      userIdentification: json['userIdentification'] ?? '',
      role: json['role'] ?? '',
      username: json['username'],
      fullName: json['fullName'],
    );
  }
}


class AgencyJoinRequestDto {
  final String id;
  final String applicantUserIdentification;

  // ✅ NEW FIELDS
  final String? applicantUsername;
  final String? applicantFullName;

  final String status;
  final String agentContactValue;
  final String contactType;
  final String? agentIdCardUrl;
  final DateTime? createdAt;

  AgencyJoinRequestDto({
    required this.id,
    required this.applicantUserIdentification,
    required this.applicantUsername,
    required this.applicantFullName,
    required this.status,
    required this.agentContactValue,
    required this.contactType,
    required this.agentIdCardUrl,
    required this.createdAt,
  });

  factory AgencyJoinRequestDto.fromJson(Map<String, dynamic> j) {
    return AgencyJoinRequestDto(
      id: (j["_id"] ?? j["id"] ?? "").toString(),
      applicantUserIdentification:
      (j["applicantUserIdentification"] ?? "").toString(),

      // ✅ MAP NEW FIELDS
      applicantUsername: j["applicantUsername"]?.toString(),
      applicantFullName: j["applicantFullName"]?.toString(),

      status: (j["status"] ?? "").toString(),
      agentContactValue: (j["agentContactValue"] ?? "").toString(),
      contactType: (j["contactType"] ?? "").toString(),
      agentIdCardUrl: j["agentIdCardUrl"]?.toString(),
      createdAt: j["createdAt"] == null
          ? null
          : DateTime.tryParse(j["createdAt"].toString()),
    );
  }
}
