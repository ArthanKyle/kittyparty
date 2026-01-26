import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

import '../../../features/landing/model/agency.dart';

/* =========================
 * LOGO UPLOAD MODEL
 * ========================= */

class AgencyLogoUpload {
  final Uint8List bytes;
  final String filename;
  final String mimeType;

  AgencyLogoUpload({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });
}

/* =========================
 * AGENCY SERVICE
 * ========================= */

class AgencyService {
  final String baseUrl;

  AgencyService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /* =========================
   * HELPERS
   * ========================= */

  Map<String, String> _jsonHeaders() => {
    "Content-Type": "application/json",
  };

  void _log(String msg) => print("🟡 [AgencyService] $msg");

  Exception _fail(String msg) {
    _log("🔴 $msg");
    return Exception(msg);
  }

  Uri _uri(String path) => Uri.parse("$baseUrl$path");

  /* =========================
   * CREATE AGENCY
   * ========================= */

  Future<AgencyDto> createAgency({
    required String userIdentification,
    required String name,
    String description = "",
    String? logoUrl,
    AgencyLogoUpload? logo,
  }) async {
    final path = "/agencies";

    if (logo != null) {
      final req = http.MultipartRequest("POST", _uri(path));

      req.fields["UserIdentification"] = userIdentification;
      req.fields["name"] = name;
      req.fields["description"] = description;

      if (logoUrl != null && logoUrl.isNotEmpty) {
        req.fields["logoUrl"] = logoUrl;
      }

      req.files.add(
        http.MultipartFile.fromBytes(
          "logo",
          logo.bytes,
          filename: logo.filename,
          contentType: http_parser.MediaType.parse(logo.mimeType),
        ),
      );

      _log("Creating agency (multipart): ${req.url}");
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw _fail("Failed to create agency");
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return AgencyDto.fromJson(data["agency"]);
    }

    final res = await http.post(
      _uri(path),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "UserIdentification": userIdentification,
        "name": name,
        "description": description,
        "logoUrl": logoUrl,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw _fail("Failed to create agency");
    }

    final data = jsonDecode(res.body);
    return AgencyDto.fromJson(data["agency"]);
  }

  /* =========================
   * FETCH MY AGENCY
   * ========================= */

  Future<MyAgencyResult> fetchMyAgency({
    required String userIdentification,
  }) async {
    final url =
        "$baseUrl/agencies/me?UserIdentification=$userIdentification";

    _log("Fetching my agency: $url");

    final res = await http.get(Uri.parse(url), headers: _jsonHeaders());

    if (res.statusCode == 404) {
      /// User has NO agency
      return MyAgencyResult(
        status: "none",
        agency: null,
        myRole: null,
      );
    }

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch my agency");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final String status =
        (data["status"] as String?) ??
            _inferStatus(
              agencyJson: data["agency"],
              role: data["myRole"],
            );

    return MyAgencyResult(
      status: status,
      agency: data["agency"] != null
          ? AgencyDto.fromJson(data["agency"])
          : null,
      myRole: data["myRole"]?.toString(),
    );
  }

  /// Fallback logic if backend does NOT send status
  String _inferStatus({
    required dynamic agencyJson,
    required dynamic role,
  }) {
    if (agencyJson == null) return "none";
    if (role == "owner") return "owner";
    return "member";
  }

  /* =========================
   * FETCH AGENCY BY CODE
   * ========================= */

  Future<AgencyDto> fetchAgencyByCode(String agencyCode) async {
    final res = await http.get(
      _uri("/agencies/$agencyCode"),
      headers: _jsonHeaders(),
    );

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch agency");
    }

    final data = jsonDecode(res.body);
    return AgencyDto.fromJson(data["agency"]);
  }

  /* =========================
   * UPDATE AGENCY
   * ========================= */

  Future<AgencyDto> updateAgency({
    required String ownerUserIdentification,
    required String agencyCode,
    String? name,
    String? description,
    String? logoUrl,
    AgencyLogoUpload? logo,
  }) async {
    final path = "/agencies/$agencyCode";

    if (logo != null) {
      final req = http.MultipartRequest("PATCH", _uri(path));

      req.fields["UserIdentification"] = ownerUserIdentification;
      if (name != null) req.fields["name"] = name;
      if (description != null) req.fields["description"] = description;
      if (logoUrl != null) req.fields["logoUrl"] = logoUrl;

      req.files.add(
        http.MultipartFile.fromBytes(
          "logo",
          logo.bytes,
          filename: logo.filename,
          contentType: http_parser.MediaType.parse(logo.mimeType),
        ),
      );

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200) {
        throw _fail("Failed to update agency");
      }

      final data = jsonDecode(res.body);
      return AgencyDto.fromJson(data["agency"]);
    }

    final res = await http.patch(
      _uri(path),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "UserIdentification": ownerUserIdentification,
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (logoUrl != null) "logoUrl": logoUrl,
      }),
    );

    if (res.statusCode != 200) {
      throw _fail("Failed to update agency");
    }

    final data = jsonDecode(res.body);
    return AgencyDto.fromJson(data["agency"]);
  }

  /* =========================
   * FETCH MEMBERS
   * ========================= */

  Future<MembersResult> fetchMembers(String agencyCode) async {
    final res = await http.get(
      _uri("/agencies/$agencyCode/members"),
      headers: _jsonHeaders(),
    );

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch members");
    }

    final data = jsonDecode(res.body);

    final members = (data["members"] as List<dynamic>? ?? [])
        .map((e) => AgencyMemberDto.fromJson(e))
        .toList();

    return MembersResult(
      members: members,
      membersCount: data["membersCount"] ?? members.length,
      maxMembers: data["maxMembers"] ?? 10,
    );
  }

  /* =========================
   * APPLY TO JOIN
   * ========================= */

  Future<void> applyToJoin({
    required String userIdentification,
    required String agencyCode,
    required String agencyAvatarUrl,
    required String agencyName,
    required String agentContactCountryCode,
    required String agentContactValue,
    required String contactType,
    required String agentIdCardUrl,
    String inviterId = "",
    String? inviterPicUrl,
  }) async {
    final res = await http.post(
      _uri("/agencies/$agencyCode/apply"),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "UserIdentification": userIdentification,
        "agencyAvatarUrl": agencyAvatarUrl,
        "agencyName": agencyName,
        "agentContactCountryCode": agentContactCountryCode,
        "agentContactValue": agentContactValue,
        "contactType": contactType,
        "agentIdCardUrl": agentIdCardUrl,
        "inviterId": inviterId,
        "inviterPicUrl": inviterPicUrl,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw _fail("Failed to apply to join agency");
    }
  }

  /* =========================
   * FETCH JOIN REQUESTS
   * ========================= */

  Future<List<AgencyJoinRequestDto>> fetchJoinRequests({
    required String ownerUserIdentification,
    required String agencyCode,
  }) async {
    final res = await http.get(
      _uri(
        "/agencies/$agencyCode/requests?UserIdentification=$ownerUserIdentification",
      ),
      headers: _jsonHeaders(),
    );

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch join requests");
    }

    final data = jsonDecode(res.body);
    final list = (data["requests"] as List<dynamic>? ?? []);

    return list
        .map((e) => AgencyJoinRequestDto.fromJson(e))
        .toList();
  }

  /* =========================
   * APPROVE / REJECT
   * ========================= */

  Future<void> approveRequest({
    required String ownerUserIdentification,
    required String agencyCode,
    required String requestId,
  }) async {
    final res = await http.post(
      _uri("/agencies/$agencyCode/requests/$requestId/approve"),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "UserIdentification": ownerUserIdentification,
      }),
    );

    if (res.statusCode != 200) {
      throw _fail("Failed to approve request");
    }
  }

  Future<void> rejectRequest({
    required String ownerUserIdentification,
    required String agencyCode,
    required String requestId,
    String reason = "",
  }) async {
    final res = await http.post(
      _uri("/agencies/$agencyCode/requests/$requestId/reject"),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "UserIdentification": ownerUserIdentification,
        "reason": reason,
      }),
    );

    if (res.statusCode != 200) {
      throw _fail("Failed to reject request");
    }
  }

  /* =========================
   * FETCH AGENCIES
   * ========================= */

  Future<List<AgencyDto>> fetchAgencies({
    required String userIdentification,
  }) async {
    final res = await http.get(
      _uri("/agencies?UserIdentification=$userIdentification"),
      headers: _jsonHeaders(),
    );

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch agencies");
    }

    final data = jsonDecode(res.body);
    final list = (data["agencies"] as List<dynamic>? ?? []);

    return list.map((e) => AgencyDto.fromJson(e)).toList();
  }
}

/* =========================
 * RESULT MODELS
 * ========================= */

class MyAgencyResult {
  /// none | pending | member | owner
  final String status;
  final AgencyDto? agency;
  final String? myRole;

  MyAgencyResult({
    required this.status,
    required this.agency,
    required this.myRole,
  });
}

class MembersResult {
  final List<AgencyMemberDto> members;
  final int membersCount;
  final int maxMembers;

  MembersResult({
    required this.members,
    required this.membersCount,
    required this.maxMembers,
  });
}
