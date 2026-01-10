import 'package:flutter/material.dart';
import '../../../core/services/api/agency_service.dart';
import '../model/agency.dart';

class AgencyViewModel extends ChangeNotifier {
  final AgencyService service;

  AgencyViewModel({required this.service});

  bool isLoading = false;
  String? error;
  List<AgencyDto> agencies = [];

  // current context
  String? _userIdentification;
  String? get userIdentification => _userIdentification;

  // data
  AgencyDto? myAgency;
  String? myRole; // owner | member

  AgencyDto? viewingAgency; // agency by code (browse)
  MembersResult? membersResult;
  List<AgencyJoinRequestDto> joinRequests = [];

  /* =========================
   * LOGGING
   * ========================= */
  void _log(String msg) => print("🟡 [AgencyViewModel] $msg");

  /* =========================
   * COMPUTED
   * ========================= */

  bool get isOwner {
    final result = myRole == "owner";
    _log("isOwner = $result (role=$myRole)");
    return result;
  }

  int get membersCount {
    final count =
        viewingAgency?.membersCount ??
            myAgency?.membersCount ??
            membersResult?.membersCount ??
            0;

    _log("membersCount = $count");
    return count;
  }

  int get maxMembers {
    final max =
        viewingAgency?.maxMembers ??
            myAgency?.maxMembers ??
            membersResult?.maxMembers ??
            10;

    _log("maxMembers = $max");
    return max;
  }

  bool get isFull {
    final full = membersCount >= maxMembers;
    _log("isFull = $full ($membersCount / $maxMembers)");
    return full;
  }

  /* =========================
   * LOAD / REFRESH
   * ========================= */

  Future<void> load({required String userIdentification}) async {
    _log("load() start → user=$userIdentification");

    isLoading = true;
    error = null;
    _userIdentification = userIdentification;
    notifyListeners();

    try {
      myAgency = null;
      myRole = null;

      agencies = await service.fetchAgencies(
        userIdentification: userIdentification,
      );

      _log("Fetched agencies count=${agencies.length}");
    } catch (e) {
      error = e.toString();
      _log("❌ load() error: $error");
    } finally {
      isLoading = false;
      notifyListeners();
      _log("load() end");
    }
  }

  Future<void> fetchAgenciesIfFree({
    required String userIdentification,
  }) async {
    _log("fetchAgenciesIfFree() user=$userIdentification");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      agencies = await service.fetchAgencies(
        userIdentification: userIdentification,
      );

      _log("Fetched agencies count=${agencies.length}");
    } catch (e) {
      error = e.toString();
      _log("❌ fetchAgenciesIfFree error: $error");
    } finally {
      isLoading = false;
      notifyListeners();
      _log("fetchAgenciesIfFree() end");
    }
  }

  Future<void> refresh({required String userIdentification}) {
    _log("refresh()");
    return load(userIdentification: userIdentification);
  }

  /* =========================
   * BROWSE AGENCY BY CODE
   * ========================= */

  Future<void> viewAgencyByCode({
    required String agencyCode,
    required String userIdentification,
  }) async {
    _log("viewAgencyByCode() code=$agencyCode user=$userIdentification");

    isLoading = true;
    error = null;
    _userIdentification = userIdentification;
    notifyListeners();

    try {
      viewingAgency = await service.fetchAgencyByCode(agencyCode);
      _log("Loaded agency: ${viewingAgency?.name}");

      await loadMembers(
        agencyCode: agencyCode,
        notify: false,
      );

      if (isOwner) {
        _log("User is owner → loading join requests");
        await loadJoinRequests(
          ownerUserIdentification: userIdentification,
          agencyCode: agencyCode,
          notify: false,
        );
      } else {
        _log("User not owner → clearing join requests");
        joinRequests = [];
      }
    } catch (e) {
      error = e.toString();
      _log("❌ viewAgencyByCode error: $error");
    } finally {
      isLoading = false;
      notifyListeners();
      _log("viewAgencyByCode() end");
    }
  }

  /* =========================
   * MEMBERS
   * ========================= */

  Future<void> loadMembers({
    required String agencyCode,
    bool notify = true,
  }) async {
    _log("loadMembers() code=$agencyCode notify=$notify");

    error = null;
    if (notify) notifyListeners();

    try {
      membersResult = await service.fetchMembers(agencyCode);

      _log(
        "Members loaded: count=${membersResult?.membersCount}, max=${membersResult?.maxMembers}",
      );

      if (viewingAgency != null &&
          viewingAgency!.agencyCode == agencyCode) {
        viewingAgency = _copyAgencyWithCounts(
          viewingAgency!,
          membersCount: membersResult!.membersCount,
          maxMembers: membersResult!.maxMembers,
        );
        _log("Updated viewingAgency counts");
      }

      if (myAgency != null && myAgency!.agencyCode == agencyCode) {
        myAgency = _copyAgencyWithCounts(
          myAgency!,
          membersCount: membersResult!.membersCount,
          maxMembers: membersResult!.maxMembers,
        );
        _log("Updated myAgency counts");
      }
    } catch (e) {
      error = e.toString();
      _log("❌ loadMembers error: $error");
    } finally {
      if (notify) notifyListeners();
      _log("loadMembers() end");
    }
  }

  /* =========================
   * APPROVALS (OWNER)
   * ========================= */

  Future<void> loadJoinRequests({
    required String ownerUserIdentification,
    required String agencyCode,
    bool notify = true,
  }) async {
    _log(
      "loadJoinRequests() code=$agencyCode owner=$ownerUserIdentification",
    );

    error = null;
    if (notify) notifyListeners();

    try {
      joinRequests = await service.fetchJoinRequests(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
      );

      _log("Join requests loaded: ${joinRequests.length}");
    } catch (e) {
      error = e.toString();
      _log("❌ loadJoinRequests error: $error");
    } finally {
      if (notify) notifyListeners();
      _log("loadJoinRequests() end");
    }
  }

  /* =========================
   * ACTIONS
   * ========================= */

  Future<bool> createAgency({
    required String userIdentification,
    required String name,
    String description = "",
    String? logoUrl,
  }) async {
    _log("createAgency() name=$name user=$userIdentification");

    isLoading = true;
    error = null;
    _userIdentification = userIdentification;
    notifyListeners();

    try {
      final agency = await service.createAgency(
        userIdentification: userIdentification,
        name: name,
        description: description,
        logoUrl: logoUrl,
      );

      myAgency = agency;
      myRole = "owner";
      viewingAgency = agency;

      _log("Agency created: ${agency.agencyCode}");

      await loadMembers(
        agencyCode: agency.agencyCode,
        notify: false,
      );

      await loadJoinRequests(
        ownerUserIdentification: userIdentification,
        agencyCode: agency.agencyCode,
        notify: false,
      );

      return true;
    } catch (e) {
      error = e.toString();
      _log("❌ createAgency error: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      _log("createAgency() end");
    }
  }

  Future<bool> editAgency({
    required String ownerUserIdentification,
    required String agencyCode,
    String? name,
    String? description,
    String? logoUrl,
  }) async {
    _log("editAgency() code=$agencyCode");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final updated = await service.updateAgency(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
        name: name,
        description: description,
        logoUrl: logoUrl,
      );

      if (myAgency?.agencyCode == agencyCode) myAgency = updated;
      if (viewingAgency?.agencyCode == agencyCode) {
        viewingAgency = updated;
      }

      _log("Agency updated");
      return true;
    } catch (e) {
      error = e.toString();
      _log("❌ editAgency error: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyToJoin({
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
    _log("applyToJoin() code=$agencyCode user=$userIdentification");

    isLoading = true;
    error = null;
    _userIdentification = userIdentification;
    notifyListeners();

    try {
      await service.applyToJoin(
        userIdentification: userIdentification,
        agencyCode: agencyCode,
        agencyAvatarUrl: agencyAvatarUrl,
        agencyName: agencyName,
        agentContactCountryCode: agentContactCountryCode,
        agentContactValue: agentContactValue,
        contactType: contactType,
        agentIdCardUrl: agentIdCardUrl,
        inviterId: inviterId,
        inviterPicUrl: inviterPicUrl,
      );

      _log("Apply to join success");
      return true;
    } catch (e) {
      error = e.toString();
      _log("❌ applyToJoin error: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveRequest({
    required String ownerUserIdentification,
    required String agencyCode,
    required String requestId,
  }) async {
    _log("approveRequest() request=$requestId");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.approveRequest(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
        requestId: requestId,
      );

      _log("Request approved");

      await loadJoinRequests(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
        notify: false,
      );

      await loadMembers(
        agencyCode: agencyCode,
        notify: false,
      );

      return true;
    } catch (e) {
      error = e.toString();
      _log("❌ approveRequest error: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectRequest({
    required String ownerUserIdentification,
    required String agencyCode,
    required String requestId,
    String reason = "",
  }) async {
    _log("rejectRequest() request=$requestId reason=$reason");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.rejectRequest(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
        requestId: requestId,
        reason: reason,
      );

      _log("Request rejected");

      await loadJoinRequests(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
        notify: false,
      );

      return true;
    } catch (e) {
      error = e.toString();
      _log("❌ rejectRequest error: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* =========================
   * UTIL
   * ========================= */

  void clearError() {
    _log("clearError()");
    error = null;
    notifyListeners();
  }

  AgencyDto _copyAgencyWithCounts(
      AgencyDto a, {
        required int membersCount,
        required int maxMembers,
      }) {
    return AgencyDto(
      id: a.id,
      agencyCode: a.agencyCode,
      name: a.name,
      description: a.description,
      logoUrl: a.logoUrl,
      ownerUserIdentification: a.ownerUserIdentification,
      status: a.status,
      maxMembers: maxMembers,
      membersCount: membersCount,
    );
  }
}
