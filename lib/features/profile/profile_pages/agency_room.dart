import 'package:flutter/material.dart';
import 'package:kittyparty/app.dart';
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
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;

    final uid = context
        .read<UserProvider>()
        .currentUser
        ?.userIdentification ?? "";
    if (uid.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<AgencyViewModel>();

      await vm.load(userIdentification: uid);

      if (vm.myAgency == null) {
        await vm.fetchAgenciesIfFree(userIdentification: uid);
      }
    });

    _didLoad = true;
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
                labelText: 'UserName',
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
                  final uid = context
                      .read<UserProvider>()
                      .currentUser
                      ?.userIdentification ?? "";
                  if (uid.isNotEmpty) {
                    vm.refresh(userIdentification: uid);
                  }
                },
              );
            }


            /// ✅ NO AGENCY STATE (with Create button)
            if (vm.myAgency == null) {
              final user = context
                  .read<UserProvider>()
                  .currentUser;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
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
                                  initialUserId: user?.userIdentification ?? "",
                                  isCreateAgency: true,
                                ),
                          ),
                        );

                        if (ok == true && context.mounted) {
                          final uid = user?.userIdentification ?? "";
                          if (uid.isNotEmpty) {
                            context
                                .read<AgencyViewModel>()
                                .refresh(userIdentification: uid);
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _AgencyHeader(
                      name: vm.myAgency!.name,
                      code: vm.myAgency!.agencyCode,
                      membersCount: vm.myAgency!.membersCount,
                      maxMembers: vm.myAgency!.maxMembers,
                      role: vm.myRole ?? "",
                    ),
                    const SizedBox(height: 10),
                    // ✅ LIST AVAILABLE AGENCIES
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.agencies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
class _NoAgencyYet extends StatelessWidget {
  const _NoAgencyYet();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'No agency yet. Create one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            GradientButton(
              text: "Retry",
              gradient: AppColors.mainGradient,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _AgencyHeader extends StatelessWidget {
  final String name;
  final String code;
  final int membersCount;
  final int maxMembers;
  final String role;

  const _AgencyHeader({
    required this.name,
    required this.code,
    required this.membersCount,
    required this.maxMembers,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text("Code: $code", style: const TextStyle(color: Colors.amber)),
          const SizedBox(height: 4),
          Text("Members: $membersCount/$maxMembers", style: const TextStyle(color: Colors.amber)),
          const SizedBox(height: 4),
          Text("Role: $role", style: const TextStyle(color: Colors.amber)),
        ],
      ),
    );
  }
}

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Apply to join?'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                    text: 'Cancel',
                    gradient: AppColors.grayGradient,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    text: 'Confirm',
                    gradient: AppColors.mainGradient,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
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
