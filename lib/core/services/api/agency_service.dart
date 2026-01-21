import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

import '../../../features/landing/model/agency.dart';

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

class AgencyService {
  final String baseUrl;

  AgencyService({String? baseUrl}) : baseUrl = baseUrl ?? dotenv.env['BASE_URL']!;

  /* =========================
   * HELPERS
   * ========================= */

  Map<String, String> _jsonHeaders() => {"Content-Type": "application/json"};

  void _log(String msg) => print("🟡 [AgencyService] $msg");

  Exception _fail(String msg) {
    _log("🔴 $msg");
    return Exception(msg);
  }

  Uri _uri(String path) => Uri.parse("$baseUrl$path");

  /* =========================
   * CREATE AGENCY
   * POST /api/agencies
   * - JSON (legacy): { UserIdentification, name, description?, logoUrl? }
   * - Multipart (preferred): fields + file("logo")
   * ========================= */

  Future<AgencyDto> createAgency({
    required String userIdentification,
    required String name,
    String description = "",
    String? logoUrl,
    AgencyLogoUpload? logo, // ✅ NEW
  }) async {
    final path = "/agencies";

    if (logo != null) {
      final req = http.MultipartRequest("POST", _uri(path));

      req.fields["UserIdentification"] = userIdentification;
      req.fields["name"] = name;
      req.fields["description"] = description;

      // Optional legacy url field
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

      _log("Creating agency (multipart) URL: ${req.url}");
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      _log("Status code: ${res.statusCode}");
      _log("Raw response: ${res.body}");

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw _fail("Failed to create agency");
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final agencyJson = (data["agency"] as Map<String, dynamic>);
      return AgencyDto.fromJson(agencyJson);
    }

    // Fallback: JSON request (no file)
    final url = "$baseUrl$path";

    _log("Creating agency (json)");
    _log("URL: $url");

    final res = await http.post(
      Uri.parse(url),
      headers: _jsonHeaders(),
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

    final res = await http.get(Uri.parse(url), headers: _jsonHeaders());

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode == 404) {
      _log("No agency found → returning null agency");
      return MyAgencyResult(agency: null, myRole: null);
    }

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch my agency");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final agencyJson = data["agency"] as Map<String, dynamic>;
    final role = data["myRole"]?.toString();

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

    final res = await http.get(Uri.parse(url), headers: _jsonHeaders());

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch agency");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final agencyJson = (data["agency"] as Map<String, dynamic>);
    return AgencyDto.fromJson(agencyJson);
  }

  /* =========================
   * UPDATE AGENCY (OWNER ONLY)
   * PATCH /api/agencies/:agencyCode
   * - JSON (legacy) OR Multipart with file("logo")
   * ========================= */

  Future<AgencyDto> updateAgency({
    required String ownerUserIdentification,
    required String agencyCode,
    String? name,
    String? description,
    String? logoUrl,
    AgencyLogoUpload? logo, // ✅ NEW
  }) async {
    final path = "/agencies/$agencyCode";

    if (logo != null) {
      final req = http.MultipartRequest("PATCH", _uri(path));

      req.fields["UserIdentification"] = ownerUserIdentification;
      if (name != null) req.fields["name"] = name;
      if (description != null) req.fields["description"] = description;
      if (logoUrl != null && logoUrl.isNotEmpty) req.fields["logoUrl"] = logoUrl;

      req.files.add(
        http.MultipartFile.fromBytes(
          "logo",
          logo.bytes,
          filename: logo.filename,
          contentType: http_parser.MediaType.parse(logo.mimeType),
        ),
      );

      _log("Updating agency (multipart) URL: ${req.url}");
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      _log("Status code: ${res.statusCode}");
      _log("Raw response: ${res.body}");

      if (res.statusCode != 200) {
        throw _fail("Failed to update agency");
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final agencyJson = (data["agency"] as Map<String, dynamic>);
      return AgencyDto.fromJson(agencyJson);
    }

    // JSON fallback
    final url = "$baseUrl$path";

    final body = <String, dynamic>{
      "UserIdentification": ownerUserIdentification,
      if (name != null) "name": name,
      if (description != null) "description": description,
      if (logoUrl != null) "logoUrl": logoUrl,
    };

    _log("Updating agency (json)");
    _log("URL: $url");
    _log("Body: ${jsonEncode(body)}");

    final res = await http.patch(Uri.parse(url), headers: _jsonHeaders(), body: jsonEncode(body));

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

    final res = await http.get(Uri.parse(url), headers: _jsonHeaders());

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

    final maxMembers = maxMembersRaw is int ? maxMembersRaw : int.tryParse(maxMembersRaw.toString()) ?? 10;

    final membersCount =
    membersCountRaw is int ? membersCountRaw : int.tryParse(membersCountRaw.toString()) ?? members.length;

    return MembersResult(members: members, membersCount: membersCount, maxMembers: maxMembers);
  }

  /* =========================
   * APPLY TO JOIN
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

    final res = await http.post(Uri.parse(url), headers: _jsonHeaders(), body: jsonEncode(body));

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw _fail("Failed to apply to join");
    }
  }

  /* =========================
   * LIST JOIN REQUESTS
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

    final res = await http.get(Uri.parse(url), headers: _jsonHeaders());

    _log("Status code: ${res.statusCode}");
    _log("Raw response: ${res.body}");

    if (res.statusCode != 200) {
      throw _fail("Failed to fetch join requests");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["requests"] as List<dynamic>? ?? []);

    return list.map((x) => AgencyJoinRequestDto.fromJson(x as Map<String, dynamic>)).toList();
  }

  /* =========================
   * APPROVE REQUEST
   * POST /api/agencies/:agencyCode/requests/:requestId/approve
   * ========================= */

  Future<void> approveRequest({
    required String ownerUserIdentification,
    required String agencyCode,
    required String requestId,
  }) async {
    final url = "$baseUrl/agencies/$agencyCode/requests/$requestId/approve";
    final body = {"UserIdentification": ownerUserIdentification};

    final res = await http.post(Uri.parse(url), headers: _jsonHeaders(), body: jsonEncode(body));

    if (res.statusCode != 200) {
      throw _fail("Failed to approve request");
    }
  }

  /* =========================
   * REJECT REQUEST
   * POST /api/agencies/:agencyCode/requests/:requestId/reject
   * ========================= */

  Future<void> rejectRequest({
    required String ownerUserIdentification,
    required String agencyCode,
    required String requestId,
    String reason = "",
  }) async {
    final url = "$baseUrl/agencies/$agencyCode/requests/$requestId/reject";
    final body = {"UserIdentification": ownerUserIdentification, "reason": reason};

    final res = await http.post(Uri.parse(url), headers: _jsonHeaders(), body: jsonEncode(body));

    if (res.statusCode != 200) {
      throw _fail("Failed to reject request");
    }
  }

  Future<List<AgencyDto>> fetchAgencies({
    required String userIdentification,
  }) async {
    final url = "$baseUrl/agencies?UserIdentification=$userIdentification";

    final res = await http.get(Uri.parse(url), headers: _jsonHeaders());

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch agencies");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["agencies"] as List<dynamic>? ?? []);

    return list.map((e) => AgencyDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}

/* =========================
 * SMALL RESULT TYPES
 * ========================= */

class MyAgencyResult {
  final AgencyDto? agency;
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
