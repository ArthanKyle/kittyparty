import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kittyparty/features/landing/landing_widgets/landing_widgets/room_card.dart';
import 'package:kittyparty/features/livestream/view/live_audio_room.dart';
import 'package:kittyparty/core/services/api/room_service.dart';
import 'package:kittyparty/core/utils/user_provider.dart';
import '../../../../app.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../viewmodel/recommend_tab_viewmodel.dart';
import 'banner_carousel.dart';
import 'mode_card.dart';

enum RoomSectionType { hot, newest, country }

class RecommendTab extends StatefulWidget {
  const RecommendTab({super.key});

  @override
  State<RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends State<RecommendTab> {
  late RecommendViewModel vm;
  String? userId;

  // ✅ added
  String? userCountryCode;
  RoomSectionType _section = RoomSectionType.hot;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    userId = userProvider.currentUser?.userIdentification;


    // ✅ added
    userCountryCode = userProvider.currentUser?.countryCode;
    _selectedCountry = (userCountryCode != null && userCountryCode!.isNotEmpty)
        ? userCountryCode!.toUpperCase()
        : null;

    vm = RecommendViewModel(RoomService());
    vm.fetchRooms(userId);
  }

  Future<void> _refreshRooms() async {
    await vm.fetchRooms(userId);
  }

  void _promptJoinRoom({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    DialogInfo(
      headerText: "Join Room",
      subText: "Do you want to join this room?",
      confirmText: "Join",
      onConfirm: () {
        Navigator.pop(context); // close dialog
        onConfirm();
      },
      onCancel: () => Navigator.pop(context),
    ).build(context);
  }

  void _showJoiningLoading(BuildContext context) {
    DialogLoading(subtext: "Joining room...").build(context);
  }


  // =======================
  // ✅ added helpers
  // =======================
  String? _readString(dynamic obj, List<String> keys) {
    if (obj == null) return null;

    for (final k in keys) {
      // toJson read
      try {
        final v = (obj as dynamic).toJson()[k];
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}

      // map-like read
      try {
        final v = (obj as dynamic)[k];
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}

      // direct property (best-effort)
      try {
        final dynamic v = (obj as dynamic).toJson()[k];
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
    }
    return null;
  }

  int _readInt(dynamic obj, List<String> keys) {
    if (obj == null) return 0;

    for (final k in keys) {
      try {
        final v = (obj as dynamic).toJson()[k];
        if (v is int) return v;
        if (v is num) return v.toInt();
      } catch (_) {}

      try {
        final v = (obj as dynamic)[k];
        if (v is int) return v;
        if (v is num) return v.toInt();
      } catch (_) {}
    }
    return 0;
  }

  DateTime? _readDate(dynamic obj, List<String> keys) {
    if (obj == null) return null;

    for (final k in keys) {
      try {
        final v = (obj as dynamic).toJson()[k];
        if (v is DateTime) return v;
        if (v is String) {
          final d = DateTime.tryParse(v);
          if (d != null) return d;
        }
      } catch (_) {}

      try {
        final v = (obj as dynamic)[k];
        if (v is DateTime) return v;
        if (v is String) {
          final d = DateTime.tryParse(v);
          if (d != null) return d;
        }
      } catch (_) {}
    }
    return null;
  }

  List<Map<String, String>> _orderedCountries() {
    final all = List<Map<String, String>>.from(Strings.countries);
    final ucc = userCountryCode?.toUpperCase();

    if (ucc == null || ucc.isEmpty) return all;

    final idx = all.indexWhere((c) => (c["code"] ?? "").toUpperCase() == ucc);
    if (idx <= 0) return all;

    final userCountry = all.removeAt(idx);
    all.insert(0, userCountry);
    return all;
  }

  Widget _chip({
    required bool selected,
    required Widget leading,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.black12 : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _filteredRooms(List<dynamic> rooms) {
    final list = List<dynamic>.from(rooms);

    if (_section == RoomSectionType.hot) {
      list.sort((a, b) {
        final aCount = _readInt(a, const [
          "audienceCount",
          "onlineCount",
          "membersCount",
          "viewerCount",
          "usersCount",
        ]);
        final bCount = _readInt(b, const [
          "audienceCount",
          "onlineCount",
          "membersCount",
          "viewerCount",
          "usersCount",
        ]);
        return bCount.compareTo(aCount);
      });
      return list;
    }

    if (_section == RoomSectionType.newest) {
      final now = DateTime.now().toUtc();
      final filtered = list.where((r) {
        final created = _readDate(r, const ["createdAt", "CreatedAt", "dateCreated"]);
        if (created == null) return true;
        return now.difference(created.toUtc()).inHours <= 24;
      }).toList();
      return filtered.isEmpty ? list : filtered;
    }

    if (_section == RoomSectionType.country) {
      final cc = _selectedCountry?.toUpperCase();
      if (cc == null || cc.isEmpty) return list;

      final filtered = list.where((r) {
        final roomCc = _readString(r, const ["countryCode", "CountryCode", "country"]);
        if (roomCc == null || roomCc.isEmpty) return true;
        return roomCc.toUpperCase() == cc;
      }).toList();
      return filtered.isEmpty ? list : filtered;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final countries = _orderedCountries();

    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<RecommendViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ use filtered rooms
          final rooms = _filteredRooms(vm.rooms);

          return RefreshIndicator(
            onRefresh: _refreshRooms,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ core parts kept
                  Row(
                    children: const [
                      Expanded(
                        child: ModeCard(
                          title: 'CLASSIC',
                          height: 110,
                          gradient: [Color(0xFFFF6B6B), Color(0xFFFF3B3B)],
                          icon: Icons.sports_esports_rounded,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ModeCard(
                          title: 'QUICK',
                          height: 110,
                          gradient: [Color(0xFF6B9EFF), Color(0xFF3B82F6)],
                          icon: Icons.bolt_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ✅ core parts kept (kept your 110 heights)
                  Row(
                    children: [
                      Expanded(
                        child: ModeCard(
                          title: 'RANKING',
                          height: 110,
                          gradient: const [Color(0xFFFDBA74), Color(0xFFF59E0B)],
                          icon: Icons.emoji_events_rounded,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.honorRanking);
                          },
                        ),
                      ),

                      const SizedBox(width: 12),
                      const Expanded(
                        child: ModeCard(
                          title: 'EVENT CENTER',
                          height: 110,
                          gradient: [Color(0xFFA78BFA), Color(0xFFD946EF)],
                          icon: Icons.campaign_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ✅ core parts kept
                  BannerCarousel(),
                  const SizedBox(height: 12),

                  // ✅ added: hot/new/countries row like your screenshot
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2 + countries.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return _chip(
                            selected: _section == RoomSectionType.hot,
                            leading: const Text("🔥", style: TextStyle(fontSize: 14)),
                            text: "Hot",
                            onTap: () {
                              setState(() {
                                _section = RoomSectionType.hot;
                              });
                            },
                          );
                        }

                        if (i == 1) {
                          return _chip(
                            selected: _section == RoomSectionType.newest,
                            leading: const Text("🆕", style: TextStyle(fontSize: 14)),
                            text: "New",
                            onTap: () {
                              setState(() {
                                _section = RoomSectionType.newest;
                              });
                            },
                          );
                        }

                        final c = countries[i - 2];
                        final flag = c["flag"] ?? "🏳️";
                        final code = (c["code"] ?? "").toUpperCase();

                        final selected = _section == RoomSectionType.country &&
                            (_selectedCountry?.toUpperCase() == code);

                        return _chip(
                          selected: selected,
                          leading: Text(flag, style: const TextStyle(fontSize: 14)),
                          text: code,
                          onTap: () {
                            setState(() {
                              _section = RoomSectionType.country;
                              _selectedCountry = code;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),


                  const SizedBox(height: 12),

                  // ✅ swapped vm.rooms -> rooms (filtered)
                  if (rooms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              "No active rooms right now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Check back later or create your own!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: rooms.map((room) {
                        return RoomCard(
                          room: room,
                          onTap: () {
                            final userProvider = context.read<UserProvider>();

                            _promptJoinRoom(
                              context: context,
                              onConfirm: () async {
                                // Optional loading
                                _showJoiningLoading(context);

                                // If no async work is needed, remove await + loading
                                await Future.delayed(const Duration(milliseconds: 300));

                                Navigator.pop(context); // close loading

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LiveAudioRoom(
                                      roomId: room.id!,
                                      hostId: room.hostId,
                                      roomName: room.roomName,
                                      userProvider: userProvider,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
