import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:kittyparty/core/utils/user_provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/global_widgets/buttons/gradient_button.dart';
import '../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../landing/landing_widgets/profile_widgets/agency_widgets/agency_list_card.dart';
import '../../landing/viewmodel/agency_viewmodel.dart';
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
   * HELPERS
   * ========================= */

  String? _buildMediaUrl(List<dynamic> media) {
    final base = dotenv.env['BASE_URL'] ?? "";

    if (media.isNotEmpty && media.first is Map<String, dynamic>) {
      final id = media.first['id']?.toString();
      if (id != null && id.isNotEmpty) {
        return "$base/media/$id";
      }
    }
    return null;
  }

  String countryToDialCode(String country) {
    switch (country.toUpperCase()) {
      case 'PH':
        return '+63';
      case 'US':
        return '+1';
      case 'JP':
        return '+81';
      default:
        return '';
    }
  }

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

  Future<void> _handleCreateAgency(BuildContext context, dynamic user) async {
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
      appBar: AppBar(
        title: const Text('Agency'),
        centerTitle: true,
      ),
      body: Consumer<AgencyViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.agencies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
            );
          }

          final query = _searchCtrl.text.toLowerCase();
          final filteredAgencies = vm.agencies.where((a) {
            return a.name.toLowerCase().contains(query) ||
                a.agencyCode.toLowerCase().contains(query);
          }).toList();

          return Stack(
            children: [
              /// =====================
              /// CONTENT
              /// =====================
              RefreshIndicator(
                onRefresh: () => vm.refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// SEARCH
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

                      /// AGENCY LIST
                      if (filteredAgencies.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: Text("No agencies found")),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredAgencies.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final agency = filteredAgencies[index];

                            return AgencyListCard(
                              name: agency.name,
                              agencyCode: agency.agencyCode,
                              members: agency.membersCount,
                              maxMembers: agency.maxMembers,
                              media: agency.media,
                              waveAsset: 'assets/image/gold_wave_bg.png',
                              onTap: () async {
                                final currentUser = context.read<UserProvider>().currentUser;

                                if (currentUser == null) {
                                  print("🧪 USER DEBUG ❌ user is null");
                                  return;
                                }

                                print("🧪 USER DEBUG ✅");
                                print("UserIdentification = ${currentUser.userIdentification}");
                                print("Username           = ${currentUser.username}");
                                print("CountryCode(raw)   = '${currentUser.countryCode}'");
                                print("PhoneNumber(raw)   = '${currentUser.phoneNumber}'");
                                print("DialCode(mapped)   = '${countryToDialCode(currentUser.countryCode)}'");


                                final vm =
                                context.read<AgencyViewModel>();
                                final user =
                                    context.read<UserProvider>().currentUser;

                                if (user == null) return;

                                /// ❌ Prevent duplicate
                                if (agency.hasPendingRequest) {
                                  DialogInfo(
                                    headerText: "Notice",
                                    subText:
                                    "Your application to this agency is already pending.",
                                    confirmText: "OK",
                                    onConfirm: () =>
                                        Navigator.pop(context),
                                    onCancel: () =>
                                        Navigator.pop(context),
                                  ).build(context);
                                  return;
                                }

                                final confirmCompleter =
                                Completer<bool>();

                                /// 1️⃣ CONFIRM
                                DialogInfo(
                                  headerText: "Apply to Join",
                                  subText:
                                  "Do you want to apply to join ${agency.name}?",
                                  confirmText: "Apply",
                                  cancelText: "Cancel",
                                  onConfirm: () {
                                    Navigator.pop(context);
                                    confirmCompleter.complete(true);
                                  },
                                  onCancel: () {
                                    Navigator.pop(context);
                                    confirmCompleter.complete(false);
                                  },
                                ).build(context);

                                final confirm =
                                await confirmCompleter.future;
                                if (confirm != true) return;

                                /// 2️⃣ VALIDATE DATA
                                final contactCountryCode = countryToDialCode(user.countryCode);
                                final contactValue = user.phoneNumber ?? "";
                                final agentIdCardUrl =
                                _buildMediaUrl(agency.media);

                                if (contactCountryCode.isEmpty ||
                                    contactValue.isEmpty) {
                                  DialogInfo(
                                    headerText:
                                    "Missing Information",
                                    subText:
                                    "Please complete your phone number in your profile.",
                                    confirmText: "OK",
                                    onConfirm: () =>
                                        Navigator.pop(context),
                                    onCancel: () =>
                                        Navigator.pop(context),
                                  ).build(context);
                                  return;
                                }

                                if (agentIdCardUrl == null) {
                                  DialogInfo(
                                    headerText: "Missing ID",
                                    subText:
                                    "This agency has no valid ID card.",
                                    confirmText: "OK",
                                    onConfirm: () =>
                                        Navigator.pop(context),
                                    onCancel: () =>
                                        Navigator.pop(context),
                                  ).build(context);
                                  return;
                                }

                                /// 3️⃣ LOADING
                                DialogLoading(
                                  subtext:
                                  "Submitting application...",
                                ).build(context);

                                bool ok = false;

                                try {
                                  ok = await vm.applyToJoin(
                                    agencyCode:
                                    agency.agencyCode,
                                    agencyAvatarUrl:
                                    agency.logoUrl ?? "",
                                    agencyName: agency.name,
                                    agentContactCountryCode:
                                    contactCountryCode,
                                    agentContactValue:
                                    contactValue,
                                    contactType: "phone",
                                    agentIdCardUrl:
                                    agentIdCardUrl,
                                  );
                                } finally {
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                }

                                /// 4️⃣ RESULT
                                DialogInfo(
                                  headerText:
                                  ok ? "Success" : "Notice",
                                  subText: ok
                                      ? "Application submitted successfully."
                                      : "Failed to submit application.",
                                  confirmText: "OK",
                                  onConfirm: () =>
                                      Navigator.pop(context),
                                  onCancel: () =>
                                      Navigator.pop(context),
                                ).build(context);
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              /// =====================
              /// CREATE BUTTON
              /// =====================
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: SafeArea(
                  child: GradientButton(
                    text: "Create Agency",
                    gradient: AppColors.goldShineGradient,
                    onPressed: () {
                      if (user == null) return;
                      _handleCreateAgency(context, user);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
