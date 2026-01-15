import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kittyparty/core/constants/colors.dart';
import 'package:kittyparty/core/global_widgets/buttons/gradient_button.dart';
import 'package:kittyparty/features/auth/widgets/text_field.dart';
import 'package:kittyparty/core/utils/user_provider.dart';

import '../../landing/landing_widgets/profile_widgets/agency_widgets/agency_card.dart';
import '../../landing/viewmodel/agency_viewmodel.dart';
import 'agency/create_agency.dart';

class AgencyRoom extends StatefulWidget {
  const AgencyRoom({super.key});

  @override
  State<AgencyRoom> createState() => _AgencyRoomState();
}

class _AgencyRoomState extends State<AgencyRoom> {
  final _searchController = TextEditingController();
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;

    final user = context.read<UserProvider>().currentUser;
    if (user == null || user.userIdentification.isEmpty) return;

    final vm = context.read<AgencyViewModel>();
    vm.bindUser(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.load();
    });

    _didInit = true;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Agency'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: BasicTextField(
                labelText: 'Agency Code',
                controller: _searchController,
                hintText: 'Please enter the Agency Code to search',
                validator: (_) => null,
              ),
            ),
          ),
        ),
        body: Consumer<AgencyViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return _ErrorState(
                message: vm.error!,
                onRetry: () {
                  vm.clearError();
                  vm.load();
                },
              );
            }

            /// =======================
            /// NO AGENCY
            /// =======================
            if (vm.myAgency == null) {
              final user = context.read<UserProvider>().currentUser;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _NoAgencyYet(),
                    const SizedBox(height: 20),

                    GradientButton(
                      text: "Create Agency",
                      gradient: AppColors.goldShineGradient,
                      onPressed: () async {
                        final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AgencyRegistrationApplicationPage(
                                  title: "Create Agency",
                                  initialDisplayName: user?.username ?? "",
                                  initialUserId:
                                  user?.userIdentification ?? "",
                                  isCreateAgency: true,
                                ),
                          ),
                        );

                        if (ok == true && mounted) {
                          vm.refresh();
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    /// AVAILABLE AGENCIES
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.agencies.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final agency = vm.agencies[index];
                        return AgencyCard(
                          username: agency.name,
                          agentId: agency.agencyCode,
                          membersCount: agency.membersCount,
                          maxMembers: agency.maxMembers,
                          onJoin: () => _showDialog(context),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            /// =======================
            /// HAS AGENCY
            /// =======================
            return Padding(
              padding: const EdgeInsets.all(16),
              child: _AgencyHeaderCard(
                name: vm.myAgency!.name,
                code: vm.myAgency!.agencyCode,
                membersCount: vm.myAgency!.membersCount,
                maxMembers: vm.myAgency!.maxMembers,
                role: vm.myRole ?? "",
              ),
            );
          },
        ),
      ),
    );
  }
}

/// =======================================================
/// EMPTY STATE
/// =======================================================
class _NoAgencyYet extends StatelessWidget {
  const _NoAgencyYet();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 3,
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'No agency yet. Create one or join an existing agency.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// ERROR STATE
/// =======================================================
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.black,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              GradientButton(
                text: "Retry",
                gradient: AppColors.mainGradient,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// AGENCY CARD (MAIN)
/// =======================================================
class _AgencyHeaderCard extends StatelessWidget {
  final String name;
  final String code;
  final int membersCount;
  final int maxMembers;
  final String role;

  const _AgencyHeaderCard({
    required this.name,
    required this.code,
    required this.membersCount,
    required this.maxMembers,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                const Icon(Icons.apartment, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _RoleChip(role: role),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.amber.withOpacity(0.2)),

            _InfoRow(label: "Agency Code", value: code),
            _InfoRow(
              label: "Members",
              value: "$membersCount / $maxMembers",
            ),

            const SizedBox(height: 18),

            GradientButton(
              text: "Manage Agency",
              gradient: AppColors.goldShineGradient,
              onPressed: () {
                // TODO: Navigate to agency management
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// SMALL COMPONENTS
/// =======================================================
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.amber.withOpacity(0.15),
        border: Border.all(color: Colors.amber),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// =======================================================
/// JOIN CONFIRM DIALOG
/// =======================================================
void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apply to join this agency?',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      text: 'Cancel',
                      gradient: AppColors.grayGradient,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      text: 'Confirm',
                      gradient: AppColors.mainGradient,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
