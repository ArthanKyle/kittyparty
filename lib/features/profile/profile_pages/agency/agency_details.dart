import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:kittyparty/core/constants/colors.dart';
import 'package:kittyparty/core/utils/user_provider.dart';
import '../../../../core/services/api/agency_service.dart';
import '../../../../core/utils/profile_picture_helper.dart';

import '../../../landing/model/agency.dart';
import '../../../landing/viewmodel/agency_viewmodel.dart';
import '../../../landing/viewmodel/agency_withdraw_viewmodel.dart';

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
  late AgencyWithdrawViewModel _withdrawVm;

  bool _didInit = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _withdrawVm = AgencyWithdrawViewModel(
      userProvider: context.read<UserProvider>(),
      agencyCode: widget.agencyCode,
    );
  }

  @override
  void dispose() {
    _withdrawVm.dispose();
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
      await vm.loadMembers(agencyCode: widget.agencyCode);
      _rebuildTabs(vm);
      _didInit = true;
      if (mounted) setState(() {});
    });
  }

  bool _isOwnerOfThisAgency(AgencyViewModel vm) {
    final uid = context.read<UserProvider>().currentUser?.userIdentification;
    if (uid == null) return false;

    return vm.membersResult?.members.any(
          (m) => m.role == "owner" && m.userIdentification == uid,
    ) ??
        false;
  }

  bool _isMember(AgencyViewModel vm) {
    final uid = context.read<UserProvider>().currentUser?.userIdentification;
    if (uid == null) return false;

    return vm.membersResult?.members.any(
          (m) => m.userIdentification == uid,
    ) ??
        false;
  }

  void _rebuildTabs(AgencyViewModel vm) {
    final isOwner = _isOwnerOfThisAgency(vm);
    final isMember = _isMember(vm);

    final desiredLength = isOwner
        ? 4
        : isMember
        ? 3
        : 2;

    if (_tabController.length == desiredLength) return;

    _tabController.dispose();
    _tabController = TabController(length: desiredLength, vsync: this);

    if (isOwner) {
      vm.loadJoinRequests(agencyCode: widget.agencyCode);
    }
  }

  Future<void> _refreshAll(AgencyViewModel vm) async {
    await vm.viewAgencyByCode(agencyCode: widget.agencyCode);
    await vm.loadMembers(agencyCode: widget.agencyCode);

    if (_isOwnerOfThisAgency(vm)) {
      await vm.loadJoinRequests(agencyCode: widget.agencyCode);
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
        final isMember = _isMember(vm);

        final tabs = isOwner
            ? const ["Info", "Members", "Approvals", "Withdraw"]
            : isMember
            ? const ["Info", "Members", "Withdraw"]
            : const ["Info", "Members"];

        final membersCount =
            agency?.membersCount ?? vm.membersResult?.membersCount ?? 0;
        final maxMembers =
            agency?.maxMembers ?? vm.membersResult?.maxMembers ?? 10;

        final ownerMember = vm.membersResult?.members
            .where((m) => m.role == "owner")
            .cast<AgencyMemberDto?>()
            .firstWhere((m) => m != null, orElse: () => null);

        final ownerName = ownerMember?.username?.isNotEmpty == true
            ? ownerMember!.username!
            : ownerMember?.userIdentification ?? "-";

        return Scaffold(
          appBar: AppBar(
            title: Text(agency?.name ?? "Agency"),
            bottom: TabBar(
              controller: _tabController,
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          body: agency == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () => _refreshAll(vm),
            child: TabBarView(
              controller: _tabController,
              children: [
                _InfoTabDto(
                  agency: agency,
                  membersCount: membersCount,
                  maxMembers: maxMembers,
                  isOwner: isOwner,
                  onEdit: isOwner ? () => _editAgency(vm) : null,
                  onApply: isOwner ? null : () => _applyToJoin(vm),
                  isFull: membersCount >= maxMembers,
                  ownerName: ownerName,
                ),
                _MembersTabDto(
                  loading:
                  vm.isLoading && vm.membersResult == null,
                  members: vm.membersResult?.members ?? const [],
                  membersCount: membersCount,
                  maxMembers: maxMembers,
                ),
                if (isOwner)
                  _ApprovalsTabDto(
                    loading: vm.isLoading,
                    requests: vm.joinRequests,
                    onRefresh: () =>
                        vm.loadJoinRequests(
                          agencyCode: widget.agencyCode,
                        ),
                    onApprove: (id) => vm.approveRequest(
                      agencyCode: widget.agencyCode,
                      requestId: id,
                    ),
                    onReject: (id) async {
                      final reason = await _askReason(context);
                      await vm.rejectRequest(
                        agencyCode: widget.agencyCode,
                        requestId: id,
                        reason: reason ?? "",
                      );
                    },
                  ),
                if (isMember)
                  ChangeNotifierProvider.value(
                    value: _withdrawVm,
                    child: Consumer<AgencyWithdrawViewModel>(
                      builder: (_, vm, __) =>
                          _WithdrawTab(vm: vm),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* ================= ACTIONS ================= */

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
          filename:
          pickedLogoName ?? "agency_logo.jpg",
          mimeType:
          pickedLogoMime ?? "image/jpeg",
        ),
      );
    }
  }

  Future<void> _applyToJoin(AgencyViewModel vm) async {
    final user = context.read<UserProvider>().currentUser;

    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AgencyRegistrationApplicationPage(
              title: "Agency Registration Application",
              initialDisplayName: user?.username ?? "",
              initialUserId:
              user?.userIdentification ?? "",
              isCreateAgency: false,
              agencyCode: widget.agencyCode,
            ),
      ),
    );

    if (ok == true && mounted) {
      await vm.viewAgencyByCode(
          agencyCode: widget.agencyCode);
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
            child: const Text("Skip"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, c.text.trim()),
            child: const Text("Submit"),
          ),
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
  final String ownerName;

  const _InfoTabDto({
    required this.agency,
    required this.membersCount,
    required this.maxMembers,
    required this.isOwner,
    required this.onEdit,
    required this.onApply,
    required this.isFull,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      children: [
        _HeaderCard(
          name: agency.name,
          code: agency.agencyCode,
          media: agency.media ?? const [],
          subtitle: "$membersCount/$maxMembers members",
        ),
        const SizedBox(height: 12),
        _InfoRow(title: "Description", value: agency.description),
        _InfoRow(title: "Owner", value: ownerName),
        const SizedBox(height: 18),
        if (isOwner && onEdit != null)
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onEdit,
              child: const Text(
                "Edit Agency",
                style: TextStyle(color: AppColors.accentWhite),
              ),
            ),
          ),
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
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      children: [
        Text(
          "$membersCount/$maxMembers members",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ...members.map((m) {
          final displayName =
          m.username?.isNotEmpty == true
              ? m.username!
              : m.userIdentification;

          return Card(
            child: ListTile(
              leading: UserAvatarHelper.circleAvatar(
                userIdentification: m.userIdentification,
                displayName: displayName,
                localBytes: null,
                radius: 22,
                frameUrl:null
              ),
              title: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "Role: ${m.role}",
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/* ================= WITHDRAW TAB ================= */

class _WithdrawTab extends StatefulWidget {
  final AgencyWithdrawViewModel vm;

  const _WithdrawTab({required this.vm});

  @override
  State<_WithdrawTab> createState() => _WithdrawTabState();
}

class _WithdrawTabState extends State<_WithdrawTab> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return RefreshIndicator(
      onRefresh: vm.load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// BALANCE CARD
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Agency Commission",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Withdrawals are processed weekly.\nSettlement runs automatically on the 15th and 30th.",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// WITHDRAW FORM
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Withdraw Diamonds",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Diamonds",
                      hintText: "Enter amount",
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                        final value = int.tryParse(_ctrl.text);
                        if (value != null && value > 0) {
                          await vm.requestWithdraw(value);
                          _ctrl.clear();
                        }
                      },
                      child: vm.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                        "Request Withdrawal",
                        style: TextStyle(color: AppColors.accentWhite),
                      ),
                    ),
                  ),
                  if (vm.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        vm.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// HISTORY
          const Text(
            "Withdrawal History",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          if (vm.isLoading && vm.withdrawals.isEmpty)
            const Center(child: CircularProgressIndicator()),

          ...vm.withdrawals.map((w) {
            Color color;
            switch (w.status) {
              case "paid":
                color = Colors.green;
                break;
              case "approved":
                color = Colors.blue;
                break;
              case "rejected":
                color = Colors.red;
                break;
              default:
                color = Colors.orange;
            }

            return Card(
              child: ListTile(
                title: Text("💎 ${w.diamonds}"),
                subtitle: Text(
                  "${w.createdAt.toLocal()}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  w.status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: [
          if (requests.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text("No pending applications.")),
            ),

          ...requests.map((r) {
            final id = r.id;

            // ✅ DISPLAY NAME RESOLUTION (IMPORTANT)
            final displayName =
            (r.applicantUsername?.isNotEmpty == true)
                ? r.applicantUsername!
                : (r.applicantFullName?.isNotEmpty == true)
                ? r.applicantFullName!
                : r.applicantUserIdentification;

            final contact = r.agentContactValue;
            final contactType = r.contactType;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatarHelper.circleAvatar(
                      userIdentification: r.applicantUserIdentification,
                      displayName: displayName, // ✅ FIXED
                      localBytes: null,
                      radius: 26,
                      frameUrl: null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Applicant: $displayName", // ✅ FIXED
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
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
                                    style: TextStyle(
                                      color: AppColors.accentWhite,
                                    ),
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
  final List<dynamic> media;
  final String subtitle;

  const _HeaderCard({
    required this.name,
    required this.code,
    required this.media,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final base = dotenv.env['BASE_URL'] ?? "";

    String? imageUrl;
    if (media.isNotEmpty && media.first is Map<String, dynamic>) {
      final id = media.first['id']?.toString();
      if (id != null && id.isNotEmpty) {
        imageUrl = "$base/media/$id";
      }
    }

    return Card(
      child: ListTile(
        leading: Container(
          width: 64,
          height: 64, // ✅ perfect square
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4), // 🔥 almost square
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: imageUrl != null
              ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackAvatar(),
          )
              : _fallbackAvatar(),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text("Code: $code\n$subtitle"),
        isThreeLine: true,
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "A",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
        title:
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
