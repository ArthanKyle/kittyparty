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
  final TextEditingController _searchCtrl = TextEditingController();

  /* =========================
   * INIT
   * ========================= */

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

  /* =========================
   * NAVIGATION ONLY (NO SERVICE)
   * ========================= */

  void _goToAgencyDetail(BuildContext context, String agencyCode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgencyDetailPage(
          agencyCode: agencyCode,
        ),
      ),
    );
  }

  Future<void> _handleCreateAgency(
      BuildContext context, dynamic user) async {
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

  /* =========================
   * UI
   * ========================= */

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Agency'), centerTitle: true),
      body: Consumer<AgencyViewModel>(
        builder: (context, vm, _) {
          final canCreateOrJoin = vm.canCreateOrJoin;
          final query = _searchCtrl.text.toLowerCase();

          final filteredAgencies = vm.agencies.where((a) {
            return a.name.toLowerCase().contains(query) ||
                a.agencyCode.toLowerCase().contains(query);
          }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                children: [
                  if (canCreateOrJoin) ...[
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search agency name or code",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (!canCreateOrJoin)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Text(
                        "You already belong to an agency.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  else if (filteredAgencies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("No agencies found"),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAgencies.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final agency = filteredAgencies[i];

                        return AgencyListCard(
                          name: agency.name,
                          agencyCode: agency.agencyCode,
                          members: agency.membersCount,
                          maxMembers: agency.maxMembers,
                          media: agency.media,
                          waveAsset:
                          'assets/image/gold_wave_bg.png',
                          onTap: canCreateOrJoin
                              ? () => _goToAgencyDetail(
                              context, agency.agencyCode)
                              : null,
                          hasPendingRequest: agency.hasPendingRequest,
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<AgencyViewModel>(
        builder: (_, vm, __) {
          if (!vm.canCreateOrJoin || user == null) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GradientButton(
                text: "Create Agency",
                gradient: AppColors.goldShineGradient,
                onPressed: () =>
                    _handleCreateAgency(context, user),
              ),
            ),
          );
        },
      ),
    );
  }
}
