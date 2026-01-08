import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/landing/model/agency.dart';

class AgencyService {
  final String baseUrl;

  AgencyService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /* =========================
   * HELPERS
   * ========================= */

  Map<String, String> _headers() => {"Content-Type": "application/json"};

  void _log(String msg) => print("🟡 [AgencyService] $msg");

  Exception _fail(String msg) {
    _log("🔴 $msg");
    return Exception(msg);
  }

  /* =========================
   * CREATE AGENCY
   * POST /api/agencies
   * body: { UserIdentification, name, description?, logoUrl? }
   * ========================= */
  Future<AgencyDto> createAgency({
    required String userIdentification,
    required String name,
    String description = "",
    String? logoUrl,
  }) async {
    final url = "$baseUrl/agencies";

    _log("Creating agency");
    _log("URL: $url");
    _log("Body: ${jsonEncode({
      "UserIdentification": userIdentification,
      "name": name,
      "description": description,
      "logoUrl": logoUrl,
    })}");

    final res = await http.post(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode({
        "UserIdentification": userIdentification,
        "name": name,
        "description": description,
        "logoUrl": logoUrl,
      }),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw _fail("Failed to create agency");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final agencyJson = (data["agency"] as Map<String, dynamic>);

    _log("Parsed agencyCode: ${agencyJson["agencyCode"]}");

    return AgencyDto.fromJson(agencyJson);
  }

  /* =========================
   * GET MY AGENCY
   * GET /api/agencies/me?UserIdentification=...
   * ========================= */
  Future<MyAgencyResult> fetchMyAgency({
    required String userIdentification,
  }) async {
    final url = "$baseUrl/agencies/me?UserIdentification=$userIdentification";

    _log("Fetching my agency");
    _log("URL: $url");

    final res = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch my agency");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final agencyJson = (data["agency"] as Map<String, dynamic>);
    final role = data["myRole"]?.toString();

    _log("Parsed myRole: $role");
    _log("Parsed agencyCode: ${agencyJson["agencyCode"]}");

    return MyAgencyResult(
      agency: AgencyDto.fromJson(agencyJson),
      myRole: role,
    );
  }

  /* =========================
   * GET AGENCY BY CODE
   * GET /api/agencies/:agencyCode
   * ========================= */
  Future<AgencyDto> fetchAgencyByCode(String agencyCode) async {
    final url = "$baseUrl/agencies/$agencyCode";

    _log("Fetching agency by code");
    _log("URL: $url");

    final res = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch agency");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final agencyJson = (data["agency"] as Map<String, dynamic>);

    _log("Parsed agency name: ${agencyJson["name"]}");

    return AgencyDto.fromJson(agencyJson);
  }

  /* =========================
   * UPDATE AGENCY (OWNER ONLY)
   * PATCH /api/agencies/:agencyCode
   * body: { UserIdentification, name?, description?, logoUrl? }
   * ========================= */
  Future<AgencyDto> updateAgency({
    required String ownerUserIdentification,
    required String agencyCode,
    String? name,
    String? description,
    String? logoUrl,
  }) async {
    final url = "$baseUrl/agencies/$agencyCode";

    final body = <String, dynamic>{
      "UserIdentification": ownerUserIdentification,
      if (name != null) "name": name,
      if (description != null) "description": description,
      if (logoUrl != null) "logoUrl": logoUrl,
    };

    _log("Updating agency");
    _log("URL: $url");
    _log("Body: ${jsonEncode(body)}");

    final res = await http.patch(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(body),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to update agency");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final agencyJson = (data["agency"] as Map<String, dynamic>);

    return AgencyDto.fromJson(agencyJson);
  }

  /* =========================
   * LIST MEMBERS
   * GET /api/agencies/:agencyCode/members
   * ========================= */
  Future<MembersResult> fetchMembers(String agencyCode) async {
    final url = "$baseUrl/agencies/$agencyCode/members";

    _log("Fetching members");
    _log("URL: $url");

    final res = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch members");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["members"] as List<dynamic>? ?? []);

    final members = list
        .map((x) => AgencyMemberDto.fromJson(x as Map<String, dynamic>))
        .toList();

    final maxMembersRaw = data["maxMembers"] ?? 10;
    final membersCountRaw = data["membersCount"] ?? members.length;

    final maxMembers = maxMembersRaw is int
        ? maxMembersRaw
        : int.tryParse(maxMembersRaw.toString()) ?? 10;

    final membersCount = membersCountRaw is int
        ? membersCountRaw
        : int.tryParse(membersCountRaw.toString()) ?? members.length;

    _log("Parsed membersCount: $membersCount / $maxMembers");

    return MembersResult(
      members: members,
      membersCount: membersCount,
      maxMembers: maxMembers,
    );
  }

  /* =========================
   * APPLY TO JOIN (NON-OWNER)
   * POST /api/agencies/:agencyCode/apply
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
    final url = "$baseUrl/agencies/$agencyCode/apply";

    final body = {
      "UserIdentification": userIdentification,
      "agencyAvatarUrl": agencyAvatarUrl,
      "agencyName": agencyName,
      "agentContactCountryCode": agentContactCountryCode,
      "agentContactValue": agentContactValue,
      "contactType": contactType,
      "agentIdCardUrl": agentIdCardUrl,
      "inviterId": inviterId,
      "inviterPicUrl": inviterPicUrl,
    };

    _log("Applying to join agency");
    _log("URL: $url");
    _log("Body: ${jsonEncode(body)}");

    final res = await http.post(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(body),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw _fail("Failed to apply to join");
    }

    _log("Apply success");
  }

  /* =========================
   * LIST JOIN REQUESTS (OWNER ONLY)
   * GET /api/agencies/:agencyCode/requests?UserIdentification=OWNER
   * ========================= */
  Future<List<AgencyJoinRequestDto>> fetchJoinRequests({
    required String ownerUserIdentification,
    required String agencyCode,
  }) async {
    final url =
        "$baseUrl/agencies/$agencyCode/requests?UserIdentification=$ownerUserIdentification";

    _log("Fetching join requests");
    _log("URL: $url");

    final res = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch join requests");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["requests"] as List<dynamic>? ?? []);

    final reqs = list
        .map((x) => AgencyJoinRequestDto.fromJson(x as Map<String, dynamic>))
        .toList();

    _log("Parsed pending requests: ${reqs.length}");

    return reqs;
  }

  /* =========================
   * APPROVE REQUEST (OWNER ONLY)
   * POST /api/agencies/:agencyCode/requests/:requestId/approve
   * ========================= */
  Future<void> approveRequest({
    required String ownerUserIdentification,
    required String agencyCode,
    required String requestId,
  }) async {
    final url =
        "$baseUrl/agencies/$agencyCode/requests/$requestId/approve";

    final body = {"UserIdentification": ownerUserIdentification};

    _log("Approving request");
    _log("URL: $url");
    _log("Body: ${jsonEncode(body)}");

    final res = await http.post(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(body),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to approve request");
    }

    _log("Approve success");
  }

  /* =========================
   * REJECT REQUEST (OWNER ONLY)
   * POST /api/agencies/:agencyCode/requests/:requestId/reject
   * ========================= */
  Future<void> rejectRequest({
    required String ownerUserIdentification,
    required String agencyCode,
    required String requestId,
    String reason = "",
  }) async {
    final url =
        "$baseUrl/agencies/$agencyCode/requests/$requestId/reject";

    final body = {
      "UserIdentification": ownerUserIdentification,
      "reason": reason,
    };

    _log("Rejecting request");
    _log("URL: $url");
    _log("Body: ${jsonEncode(body)}");

    final res = await http.post(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(body),
    );

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to reject request");
    }

    _log("Reject success");
  }

  Future<List<AgencyDto>> fetchAgencies({
    required String userIdentification,
  }) async {
    final url =
        "$baseUrl/agencies?UserIdentification=$userIdentification";

    final res = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch agencies");
    }

    final data = jsonDecode(res.body);
    final list = data["agencies"] as List<dynamic>;

    return list.map((e) => AgencyDto.fromJson(e)).toList();
  }

}


/* =========================
 * SMALL RESULT TYPES
 * ========================= */

class MyAgencyResult {
  final AgencyDto agency;
  final String? myRole;

  MyAgencyResult({required this.agency, required this.myRole});
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
