import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:kittyparty/core/constants/colors.dart';
import 'package:kittyparty/core/utils/user_provider.dart';
import '../../../../core/services/api/agency_service.dart';

import '../../../../core/utils/profile_picture_helper.dart';
import '../../../landing/model/agency.dart';
import '../../../landing/viewmodel/agency_viewmodel.dart';
import 'create_agency.dart';

class AgencyDetailPage extends StatefulWidget {
  final String agencyCode;

  const AgencyDetailPage({
    super.key,
    required this.agencyCode,
  });

  @override
  State<AgencyDetailPage> createState() => _AgencyDetailPageState();
}

class _AgencyDetailPageState extends State<AgencyDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;

    final user = context.read<UserProvider>().currentUser;
    if (user == null || user.userIdentification.isEmpty) return;

    final vm = context.read<AgencyViewModel>();
    vm.bindUser(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await vm.load();
      await vm.viewAgencyByCode(agencyCode: widget.agencyCode);
      _rebuildTabs(vm);
      _didInit = true;
      if (mounted) setState(() {});
    });
  }

  bool _isOwnerOfThisAgency(AgencyViewModel vm) {
    final uid =
        context.read<UserProvider>().currentUser?.userIdentification;
    if (uid == null) return false;

    final members = vm.membersResult?.members ?? const [];
    return members.any(
          (m) => m.role == "owner" && m.userIdentification == uid,
    );
  }

  void _rebuildTabs(AgencyViewModel vm) {
    final isOwner = _isOwnerOfThisAgency(vm);
    final desiredLength = isOwner ? 4 : 3;

    if (_tabController.length == desiredLength) return;

    _tabController.dispose();
    _tabController = TabController(length: desiredLength, vsync: this);

    if (isOwner) {
      vm.loadJoinRequests(agencyCode: widget.agencyCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgencyViewModel>(
      builder: (context, vm, _) {
        final agency = vm.viewingAgency;

        if (agency != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _rebuildTabs(vm);
          });
        }

        final isOwner = _isOwnerOfThisAgency(vm);
        final tabs = isOwner
            ? const ["Info", "Members", "Approvals", "Withdraw"]
            : const ["Info", "Members", "Withdraw"];

        final membersCount =
            agency?.membersCount ?? vm.membersResult?.membersCount ?? 0;
        final maxMembers =
            agency?.maxMembers ?? vm.membersResult?.maxMembers ?? 10;

        return Scaffold(
          appBar: AppBar(
            title: Text(agency?.name ?? "Agency"),
            bottom: TabBar(
              controller: _tabController,
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          body: (vm.isLoading && agency == null)
              ? const Center(child: CircularProgressIndicator())
              : (agency == null
              ? _ErrorBox(
            message: vm.error ?? "Agency not found.",
            onRetry: () async {
              vm.clearError();
              await vm.viewAgencyByCode(
                agencyCode: widget.agencyCode,
              );
              _rebuildTabs(vm);
            },
          )
              : TabBarView(
            controller: _tabController,
            children: [
              _InfoTabDto(
                agency: agency,
                membersCount: membersCount,
                maxMembers: maxMembers,
                isOwner: isOwner,
                onEdit:
                isOwner ? () => _editAgency(vm) : null,
                onApply:
                isOwner ? null : () => _applyToJoin(vm),
                isFull: membersCount >= maxMembers,
              ),
              _MembersTabDto(
                loading: vm.isLoading &&
                    vm.membersResult == null,
                members:
                vm.membersResult?.members ?? const [],
                membersCount: membersCount,
                maxMembers: maxMembers,
              ),
              if (isOwner)
                _ApprovalsTabDto(
                  loading: vm.isLoading,
                  requests: vm.joinRequests,
                  onRefresh: () => vm.loadJoinRequests(
                    agencyCode: widget.agencyCode,
                  ),
                  onApprove: (id) => vm.approveRequest(
                    agencyCode: widget.agencyCode,
                    requestId: id,
                  ),
                  onReject: (id) async {
                    final reason =
                    await _askReason(context);
                    await vm.rejectRequest(
                      agencyCode: widget.agencyCode,
                      requestId: id,
                      reason: reason ?? "",
                    );
                  },
                ),
            ],
          )),
        );
      },
    );
  }

  Future<void> _editAgency(AgencyViewModel vm) async {
    final agency = vm.viewingAgency!;
    final name = TextEditingController(text: agency.name);
    final desc = TextEditingController(text: agency.description);

    Uint8List? pickedLogoBytes;
    String? pickedLogoName;
    String? pickedLogoMime;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Agency"),
        content: StatefulBuilder(
          builder: (context, setLocalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration:
                  const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: desc,
                  decoration:
                  const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Change Logo"),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );

                    if (file != null) {
                      pickedLogoBytes = await file.readAsBytes();
                      pickedLogoName = file.name;
                      pickedLogoMime =
                          file.mimeType ?? "image/jpeg";
                      setLocalState(() {});
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await vm.editAgency(
        agencyCode: widget.agencyCode,
        name: name.text.trim(),
        description: desc.text.trim(),
        logo: pickedLogoBytes == null
            ? null
            : AgencyLogoUpload(
          bytes: pickedLogoBytes!,
          filename: pickedLogoName ?? "agency_logo.jpg",
          mimeType: pickedLogoMime ?? "image/jpeg",
        ),
      );
    }
  }

  Future<void> _applyToJoin(AgencyViewModel vm) async {
    final user = context.read<UserProvider>().currentUser;

    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AgencyRegistrationApplicationPage(
          title: "Agency Registration Application",
          initialDisplayName: user?.username ?? "",
          initialUserId: user?.userIdentification ?? "",
          isCreateAgency: false,
          agencyCode: widget.agencyCode,
        ),
      ),
    );

    if (ok == true && mounted) {
      await vm.viewAgencyByCode(agencyCode: widget.agencyCode);
      _rebuildTabs(vm);
    }
  }

  Future<String?> _askReason(BuildContext context) async {
    final c = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject reason (optional)"),
        content: TextField(controller: c),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Skip")),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, c.text.trim()),
              child: const Text("Submit")),
        ],
      ),
    );
  }
}


/* =========================
 * TABS
 * ========================= */

class _InfoTabDto extends StatelessWidget {
  final AgencyDto agency;
  final int membersCount;
  final int maxMembers;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onApply;
  final bool isFull;

  const _InfoTabDto({
    required this.agency,
    required this.membersCount,
    required this.maxMembers,
    required this.isOwner,
    required this.onEdit,
    required this.onApply,
    required this.isFull,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _HeaderCard(
          name: agency.name,
          code: agency.agencyCode,
          logoUrl: agency.logoUrl,
          subtitle: "$membersCount/$maxMembers members",
        ),
        const SizedBox(height: 12),
        _InfoRow(title: "Description", value: agency.description),
        _InfoRow(title: "Owner", value: agency.ownerUserIdentification),
        const SizedBox(height: 18),
        if (isOwner && onEdit != null)
          SizedBox(height: 44, child: ElevatedButton(onPressed: onEdit, child: const Text("Edit Agency",style: TextStyle(
            color: AppColors.accentWhite
          ),))),
        if (!isOwner && onApply != null)
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: isFull ? null : onApply,
              child: Text(isFull ? "Agency Full" : "Apply to Join"),
            ),
          ),
      ],
    );
  }
}

class _MembersTabDto extends StatelessWidget {
  final bool loading;
  final List<AgencyMemberDto> members;
  final int membersCount;
  final int maxMembers;

  const _MembersTabDto({
    required this.loading,
    required this.members,
    required this.membersCount,
    required this.maxMembers,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text("$membersCount/$maxMembers members", style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...members.map((m) {
          final role = m.role;
          final id = m.userIdentification;
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(id.isNotEmpty ? id[0] : "U")),
              title: Text("User: $id"),
              subtitle: Text("Role: $role"),
            ),
          );
        }),
      ],
    );
  }
}

class _ApprovalsTabDto extends StatelessWidget {
  final bool loading;
  final List<AgencyJoinRequestDto> requests;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String requestId) onApprove;
  final Future<void> Function(String requestId) onReject;

  const _ApprovalsTabDto({
    required this.loading,
    required this.requests,
    required this.onRefresh,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (requests.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text("No pending applications.")),
            ),
          ...requests.map((r) {
            final id = r.id;
            final applicant = r.applicantUserIdentification;
            final contact = r.agentContactValue;
            final contactType = r.contactType;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👤 USER AVATAR (LEFT)
                    UserAvatarHelper.circleAvatar(
                      userIdentification: applicant,
                      displayName: applicant,
                      localBytes: null,
                      radius: 26,
                      frameAsset: null,
                    ),

                    const SizedBox(width: 12),

                    // 📄 CONTENT (RIGHT)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Applicant: $applicant",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text("Contact: $contact ($contactType)"),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => onApprove(id),
                                  child: const Text(
                                    "Approve",
                                    style: TextStyle(color: AppColors.accentWhite),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => onReject(id),
                                  child: const Text("Reject"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/* =========================
 * SMALL UI PARTS
 * ========================= */

class _HeaderCard extends StatelessWidget {
  final String name;
  final String code;
  final String? logoUrl;
  final String subtitle;

  const _HeaderCard({
    required this.name,
    required this.code,
    required this.logoUrl,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
          logoUrl != null && logoUrl!.isNotEmpty
              ? NetworkImage(logoUrl!)
              : null,
          child: (logoUrl == null || logoUrl!.isEmpty)
              ? Text(name.isNotEmpty ? name[0].toUpperCase() : "A")
              : null,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text("Code: $code\n$subtitle"),
        isThreeLine: true,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? "-" : value),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}
