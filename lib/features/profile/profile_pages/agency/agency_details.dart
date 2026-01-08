import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kittyparty/core/utils/user_provider.dart';

import '../../../landing/model/agency.dart';
import '../../../landing/viewmodel/agency_viewmodel.dart';
import 'create_agency.dart';


class AgencyDetailPage extends StatefulWidget {
  final String agencyCode;

  final String currentDisplayName;
  final String currentUserId;

  const AgencyDetailPage({
    super.key,
    required this.agencyCode,
    required this.currentDisplayName,
    required this.currentUserId,
  });

  @override
  State<AgencyDetailPage> createState() => _AgencyDetailPageState();
}

class _AgencyDetailPageState extends State<AgencyDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _didLoad = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;

    final uid =
        context.read<UserProvider>().currentUser?.userIdentification ?? "";
    if (uid.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<AgencyViewModel>();

      // 1) Load my agency (role); allow browsing even if user has none
      await vm.load(userIdentification: uid);

      // 2) View target agency by code
      await vm.viewAgencyByCode(
        agencyCode: widget.agencyCode,
        userIdentification: uid,
      );

      // 3) Setup tabs depending on ownership of THIS agency
      _rebuildTabsFor(vm);

      _didLoad = true;
      if (mounted) setState(() {});
    });
  }

  void _rebuildTabsFor(AgencyViewModel vm) {
    final isOwnerOfThis = _isOwnerOfThisAgency(vm);
    final desiredLength = isOwnerOfThis ? 3 : 2;

    if (_tabController.length == desiredLength) return;

    _tabController.dispose();
    _tabController = TabController(length: desiredLength, vsync: this);

    // owner loads join requests (uses vm.joinRequests list)
    if (isOwnerOfThis) {
      final uid =
          context.read<UserProvider>().currentUser?.userIdentification ?? "";
      if (uid.isNotEmpty) {
        vm.loadJoinRequests(
          ownerUserIdentification: uid,
          agencyCode: widget.agencyCode,
        );
      }
    }
  }

  bool _isOwnerOfThisAgency(AgencyViewModel vm) {
    final members = vm.membersResult?.members ?? const [];
    return members.any((m) =>
    m.role == "owner" && m.userIdentification == widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgencyViewModel>(
      builder: (context, vm, _) {
        final a = vm.viewingAgency;

        if (a != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _rebuildTabsFor(vm);
          });
        }

        final isOwner = _isOwnerOfThisAgency(vm);

        final tabs = isOwner
            ? const ["Info", "Members", "Approvals"]
            : const ["Info", "Members"];

        final membersCount =
            a?.membersCount ?? vm.membersResult?.membersCount ?? 0;
        final maxMembers = a?.maxMembers ?? vm.membersResult?.maxMembers ?? 10;

        return Scaffold(
          appBar: AppBar(
            title: Text(a == null ? "Agency" : a.name),
            bottom: TabBar(
              controller: _tabController,
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          body: (vm.isLoading && a == null)
              ? const Center(child: CircularProgressIndicator())
              : (a == null
              ? _ErrorBox(
            message: vm.error ?? "Agency not found.",
            onRetry: () async {
              final uid = context
                  .read<UserProvider>()
                  .currentUser
                  ?.userIdentification ??
                  "";
              if (uid.isEmpty) return;

              await vm.viewAgencyByCode(
                agencyCode: widget.agencyCode,
                userIdentification: uid,
              );
              _rebuildTabsFor(vm);
            },
          )
              : TabBarView(
            controller: _tabController,
            children: [
              _InfoTabDto(
                agency: a,
                membersCount: membersCount,
                maxMembers: maxMembers,
                isOwner: isOwner,
                onEdit: isOwner ? () => _editAgency(vm) : null,
                onApply: isOwner ? null : () => _applyToJoin(vm),
                isFull: membersCount >= maxMembers,
              ),
              _MembersTabDto(
                loading: vm.isLoading && (vm.membersResult == null),
                members: vm.membersResult?.members ?? const [],
                membersCount: membersCount,
                maxMembers: maxMembers,
              ),
              if (isOwner)
                _ApprovalsTabDto(
                  loading: vm.isLoading,
                  requests: vm.joinRequests, // ✅ FIX: use joinRequests
                  onRefresh: () async {
                    final uid = context
                        .read<UserProvider>()
                        .currentUser
                        ?.userIdentification ??
                        "";
                    if (uid.isEmpty) return;
                    await vm.loadJoinRequests(
                      ownerUserIdentification: uid,
                      agencyCode: widget.agencyCode,
                    );
                  },
                  onApprove: (id) async {
                    final uid = context
                        .read<UserProvider>()
                        .currentUser
                        ?.userIdentification ??
                        "";
                    if (uid.isEmpty) return;

                    await vm.approveRequest(
                      ownerUserIdentification: uid,
                      agencyCode: widget.agencyCode,
                      requestId: id,
                    );
                  },
                  onReject: (id) async {
                    final uid = context
                        .read<UserProvider>()
                        .currentUser
                        ?.userIdentification ??
                        "";
                    if (uid.isEmpty) return;

                    final reason = await _askReason(context);
                    await vm.rejectRequest(
                      ownerUserIdentification: uid,
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
    final a = vm.viewingAgency!;
    final name = TextEditingController(text: a.name);
    final desc = TextEditingController(text: a.description);
    final logo = TextEditingController(text: a.logoUrl ?? "");

    final okPressed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Agency"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: logo, decoration: const InputDecoration(labelText: "Logo URL")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Save")),
        ],
      ),
    );

    if (okPressed == true) {
      final uid =
          context.read<UserProvider>().currentUser?.userIdentification ?? "";
      if (uid.isEmpty) return;

      await vm.editAgency(
        ownerUserIdentification: uid,
        agencyCode: widget.agencyCode,
        name: name.text.trim(),
        description: desc.text.trim(),
        logoUrl: logo.text.trim().isEmpty ? null : logo.text.trim(),
      );
    }
  }

  Future<void> _applyToJoin(AgencyViewModel vm) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AgencyRegistrationApplicationPage(
          title: "Agency Registration Application",
          initialDisplayName: widget.currentDisplayName,
          initialUserId: widget.currentUserId,
          isCreateAgency: false,
          agencyCode: widget.agencyCode,
        ),
      ),
    );

    if (ok == true && mounted) {
      final uid =
          context.read<UserProvider>().currentUser?.userIdentification ?? "";
      if (uid.isEmpty) return;

      await vm.viewAgencyByCode(
        agencyCode: widget.agencyCode,
        userIdentification: uid,
      );
      _rebuildTabsFor(vm);
    }
  }

  Future<String?> _askReason(BuildContext context) async {
    final c = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject reason (optional)"),
        content: TextField(controller: c, decoration: const InputDecoration(hintText: "Reason")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("Skip")),
          ElevatedButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text("Submit")),
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
          SizedBox(height: 44, child: ElevatedButton(onPressed: onEdit, child: const Text("Edit Agency"))),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Applicant: $applicant", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text("Contact: $contact ($contactType)"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => onApprove(id),
                            child: const Text("Approve"),
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
        leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : "A")),
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
