import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kittyparty/core/utils/user_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/gradient_button.dart';
import '../../landing/landing_widgets/profile_widgets/agency_widgets/agency_list_card.dart';
import '../../landing/viewmodel/agency_viewmodel.dart';
import 'agency/agency_details.dart';
import 'agency/create_agency.dart';

class AgencyRoom extends StatefulWidget {
  const AgencyRoom({super.key});

  @override
  State<AgencyRoom> createState() => _AgencyRoomState();
}

class _AgencyRoomState extends State<AgencyRoom> {
  bool _didInit = false;

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
    });

    _didInit = true;
  }

  Future<void> _handleCreateAgency(
      BuildContext context,
      dynamic user,
      ) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AgencyRegistrationApplicationPage(
          title: "Create Agency",
          initialDisplayName: user.username ?? "",
          initialUserId: user.userIdentification,
          isCreateAgency: true,
        ),
      ),
    );

    if (ok == true && mounted) {
      context.read<AgencyViewModel>().refresh();
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency'),
        centerTitle: true,
      ),
      body: Consumer<AgencyViewModel>(
        builder: (context, vm, _) {
          /// =====================
          /// LOADING
          /// =====================
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// =====================
          /// ERROR
          /// =====================
          if (vm.error != null) {
            return Center(
              child: Text(
                vm.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }


          /// =====================
          /// NO AGENCY → SHOW LIST
          /// =====================
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// CREATE AGENCY BUTTON
                GradientButton(
                  text: "Create Agency",
                  gradient: AppColors.goldShineGradient,
                  onPressed: () {
                    if (user == null) return;
                    _handleCreateAgency(context, user);
                  },
                ),
                const SizedBox(height: 20),

                /// AGENCY LIST
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vm.agencies.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final agency = vm.agencies[index];

                    return AgencyListCard(
                      name: agency.name,
                      agencyCode: agency.agencyCode,
                      members: agency.membersCount,
                      maxMembers: agency.maxMembers,
                      logoUrl: agency.logoUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AgencyDetailPage(
                              agencyCode: agency.agencyCode,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
