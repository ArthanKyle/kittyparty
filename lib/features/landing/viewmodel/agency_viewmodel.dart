import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api/agency_service.dart';
import '../../../core/utils/user_provider.dart';
import '../model/agency.dart';

class AgencyViewModel extends ChangeNotifier {
  final AgencyService service;

  AgencyViewModel({required this.service});

  /* =========================
   * STATE
   * ========================= */

  bool isLoading = false;
  String? error;

  List<AgencyDto> agencies = [];
  String? membershipStatus; // none | pending | member | owner

  AgencyDto? myAgency;
  String? myRole; // owner | member

  AgencyDto? viewingAgency;
  MembersResult? membersResult;
  List<AgencyJoinRequestDto> joinRequests = [];

  late UserProvider _userProvider;
  String? _userIdentification;

  /* =========================
   * LOGGING
   * ========================= */

  void _log(String msg) => print("🟡 [AgencyViewModel] $msg");

  /* =========================
   * USER BINDING
   * ========================= */

  void bindUser(BuildContext context) {
    _userProvider = context.read<UserProvider>();
    _userIdentification = _userProvider.currentUser?.userIdentification;
    _log("bindUser() user=$_userIdentification");
  }

  String get _uid {
    final uid = _userIdentification;
    if (uid == null || uid.isEmpty) {
      throw Exception("User not bound to AgencyViewModel");
    }
    return uid;
  }

  /* =========================
   * COMPUTED
   * ========================= */

  bool get isOwner => myRole == "owner";

  bool get canBrowseAgencies => membershipStatus == "none";

  int get membersCount =>
      viewingAgency?.membersCount ??
          myAgency?.membersCount ??
          membersResult?.membersCount ??
          0;

  int get maxMembers =>
      viewingAgency?.maxMembers ??
          myAgency?.maxMembers ??
          membersResult?.maxMembers ??
          10;

  bool get isFull => membersCount >= maxMembers;

  /* =========================
   * LOAD / REFRESH
   * ========================= */



  Future<void> load() async {
    final uid = _uid;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      /// 1️⃣ Membership info
      final me = await service.fetchMyAgency(userIdentification: uid);
      membershipStatus = me.status;
      myAgency = me.agency;
      myRole = me.myRole;

      /// 2️⃣ Always fetch agencies unless already a member/owner
      if (canBrowseAgencies) {
        agencies = await service.fetchAgencies(userIdentification: uid);
      } else {
        agencies = [];
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();
  /* =========================
   * VIEW AGENCY
   * ========================= */

  Future<void> viewAgencyByCode({
    required String agencyCode,
  }) async {
    final uid = _uid;
    _log("viewAgencyByCode() code=$agencyCode user=$uid");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      viewingAgency = await service.fetchAgencyByCode(agencyCode);

      await loadMembers(agencyCode: agencyCode, notify: false);

      if (isOwner) {
        await loadJoinRequests(agencyCode: agencyCode, notify: false);
      } else {
        joinRequests = [];
      }
    } catch (e) {
      error = e.toString();
      _log("❌ viewAgencyByCode error: $error");
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
    if (notify) notifyListeners();

    try {
      membersResult = await service.fetchMembers(agencyCode);

      if (viewingAgency?.agencyCode == agencyCode && viewingAgency != null) {
        viewingAgency = _copyAgencyWithCounts(
          viewingAgency!,
          membersCount: membersResult!.membersCount,
          maxMembers: membersResult!.maxMembers,
        );
      }

      if (myAgency?.agencyCode == agencyCode && myAgency != null) {
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
   * JOIN REQUESTS (OWNER)
   * ========================= */

  Future<void> loadJoinRequests({
    required String agencyCode,
    bool notify = true,
  }) async {
    final uid = _uid;
    if (notify) notifyListeners();

    try {
      joinRequests = await service.fetchJoinRequests(
        ownerUserIdentification: uid,
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
    required String name,
    String description = "",
    AgencyLogoUpload? logo,
  }) async {
    final uid = _uid;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final agency = await service.createAgency(
        userIdentification: uid,
        name: name,
        description: description,
        logo: logo,
      );

      myAgency = agency;
      myRole = "owner";
      viewingAgency = agency;

      await loadMembers(agencyCode: agency.agencyCode, notify: false);
      await loadJoinRequests(agencyCode: agency.agencyCode, notify: false);

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
   * APPLY TO JOIN (FIXED)
   * ========================= */

  Future<bool> applyToJoin({
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
    final uid = _uid;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.applyToJoin(
        userIdentification: uid,
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

      /// ✅ USER IS NOW PENDING (DO NOT CLEAR LIST)
      membershipStatus = "pending";

      /// ✅ MARK ONLY THE TARGET AGENCY AS PENDING
      agencies = agencies.map((a) {
        if (a.agencyCode == agencyCode) {
          return AgencyDto(
            id: a.id,
            agencyCode: a.agencyCode,
            name: a.name,
            description: a.description,
            media: a.media,
            ownerUserIdentification: a.ownerUserIdentification,
            maxMembers: a.maxMembers,
            membersCount: a.membersCount,
            hasPendingRequest: true,
          );
        }
        return a;
      }).toList();

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
   * EDIT AGENCY (OWNER)
   * ========================= */

  Future<bool> editAgency({
    required String agencyCode,
    String? name,
    String? description,
    AgencyLogoUpload? logo,
  }) async {
    final uid = _uid;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final updated = await service.updateAgency(
        ownerUserIdentification: uid,
        agencyCode: agencyCode,
        name: name,
        description: description,
        logo: logo,
      );

      if (viewingAgency?.agencyCode == agencyCode) {
        viewingAgency = updated;
      }
      if (myAgency?.agencyCode == agencyCode) {
        myAgency = updated;
      }

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
    required String agencyCode,
    required String requestId,
  }) async {
    final uid = _uid;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.approveRequest(
        ownerUserIdentification: uid,
        agencyCode: agencyCode,
        requestId: requestId,
      );

      await loadJoinRequests(agencyCode: agencyCode, notify: false);
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
    required String agencyCode,
    required String requestId,
    String reason = "",
  }) async {
    final uid = _uid;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.rejectRequest(
        ownerUserIdentification: uid,
        agencyCode: agencyCode,
        requestId: requestId,
        reason: reason,
      );

      await loadJoinRequests(agencyCode: agencyCode, notify: false);

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
      media: a.media,
      ownerUserIdentification: a.ownerUserIdentification,
      maxMembers: maxMembers,
      membersCount: membersCount,
    );
  }
}
