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

  bool get isOwner => myRole == "owner";
  int get membersCount =>
      viewingAgency?.membersCount ?? myAgency?.membersCount ?? membersResult?.membersCount ?? 0;
  int get maxMembers =>
      viewingAgency?.maxMembers ?? myAgency?.maxMembers ?? membersResult?.maxMembers ?? 10;
  bool get isFull => membersCount >= maxMembers;

  /* =========================
   * LOAD / REFRESH (pattern you gave)
   * ========================= */

  Future<void> load({required String userIdentification}) async {
    isLoading = true;
    error = null;
    _userIdentification = userIdentification;
    notifyListeners();

    try {
      // ❌ REMOVE THIS
      // final result = await service.fetchMyAgency(...);

      myAgency = null;
      myRole = null;

      // ✅ Directly fetch agencies list
      agencies = await service.fetchAgencies(
        userIdentification: userIdentification,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchAgenciesIfFree({
    required String userIdentification,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      agencies = await service.fetchAgencies(
        userIdentification: userIdentification,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> refresh({required String userIdentification}) =>
      load(userIdentification: userIdentification);

  /* =========================
   * BROWSE AGENCY BY CODE
   * ========================= */

  Future<void> viewAgencyByCode({
    required String agencyCode,
    required String userIdentification,
  }) async {
    isLoading = true;
    error = null;
    _userIdentification = userIdentification;
    notifyListeners();

    try {
      viewingAgency = await service.fetchAgencyByCode(agencyCode);

      await loadMembers(agencyCode: agencyCode, notify: false);

      // Only load approvals if user is owner AND browsing own agency
      // (backend will block if not owner anyway)
      if (isOwner) {
        await loadJoinRequests(
          ownerUserIdentification: userIdentification,
          agencyCode: agencyCode,
          notify: false,
        );
      } else {
        joinRequests = [];
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* =========================
   * MEMBERS
   * ========================= */

  Future<void> loadMembers({
    required String agencyCode,
    bool notify = true,
  }) async {
    error = null;
    if (notify) notifyListeners();

    try {
      membersResult = await service.fetchMembers(agencyCode);

      // update counts if we have agency object loaded
      if (viewingAgency != null && viewingAgency!.agencyCode == agencyCode) {
        viewingAgency = _copyAgencyWithCounts(
          viewingAgency!,
          membersCount: membersResult!.membersCount,
          maxMembers: membersResult!.maxMembers,
        );
      }

      if (myAgency != null && myAgency!.agencyCode == agencyCode) {
        myAgency = _copyAgencyWithCounts(
          myAgency!,
          membersCount: membersResult!.membersCount,
          maxMembers: membersResult!.maxMembers,
        );
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (notify) notifyListeners();
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
    error = null;
    if (notify) notifyListeners();

    try {
      joinRequests = await service.fetchJoinRequests(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      if (notify) notifyListeners();
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

      // treat as my agency
      myAgency = agency;
      myRole = "owner";
      viewingAgency = agency;

      await loadMembers(agencyCode: agency.agencyCode, notify: false);
      await loadJoinRequests(
        ownerUserIdentification: userIdentification,
        agencyCode: agency.agencyCode,
        notify: false,
      );

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editAgency({
    required String ownerUserIdentification,
    required String agencyCode,
    String? name,
    String? description,
    String? logoUrl,
  }) async {
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

      // update local cached instances
      if (myAgency?.agencyCode == agencyCode) myAgency = updated;
      if (viewingAgency?.agencyCode == agencyCode) viewingAgency = updated;

      return true;
    } catch (e) {
      error = e.toString();
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
      return true;
    } catch (e) {
      error = e.toString();
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
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.approveRequest(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
        requestId: requestId,
      );

      // refresh approvals + members
      await loadJoinRequests(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
        notify: false,
      );
      await loadMembers(agencyCode: agencyCode, notify: false);

      return true;
    } catch (e) {
      error = e.toString();
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

      await loadJoinRequests(
        ownerUserIdentification: ownerUserIdentification,
        agencyCode: agencyCode,
        notify: false,
      );

      return true;
    } catch (e) {
      error = e.toString();
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
