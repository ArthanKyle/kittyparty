import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../landing/landing_widgets/profile_widgets/vip_widgets/vip_button_renew.dart';
import '../../landing/landing_widgets/profile_widgets/vip_widgets/vip_header.dart';
import '../../landing/landing_widgets/profile_widgets/vip_widgets/vip_identification_section.dart';
import '../../landing/landing_widgets/profile_widgets/vip_widgets/vip_privelages_section.dart';
import '../../landing/landing_widgets/profile_widgets/vip_widgets/vip_section_title.dart';
import '../../landing/viewmodel/profile_viewmodel.dart';


class VipPage extends StatefulWidget {
  const VipPage({super.key});

  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  final int maxVipLevel = 7;

  int vipLevel = 1;
  final bool obtainedVip = false;

  final int renewCostCoins = 70000;
  final int renewDays = 30;

  final PageController _vipController = PageController(viewportFraction: 0.92);

  @override
  void dispose() {
    _vipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ LOCAL provider for this route (fixes ProviderNotFoundException)
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel()..loadProfile(context),
      child: Scaffold(
        body: Stack(
          children: [
            const _VipBackground(),
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    title: 'VIP Center',
                    onBack: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        children: [
                          // ✅ swipeable vip header
                          SizedBox(
                            height: 160,
                            child: PageView.builder(
                              controller: _vipController,
                              itemCount: maxVipLevel,
                              onPageChanged: (index) =>
                                  setState(() => vipLevel = index + 1),
                              itemBuilder: (context, index) {
                                final level = index + 1;

                                return AnimatedBuilder(
                                  animation: _vipController,
                                  builder: (context, child) {
                                    double scale = 1.0;

                                    if (_vipController.hasClients &&
                                        _vipController.position.haveDimensions) {
                                      final page = _vipController.page ??
                                          _vipController.initialPage.toDouble();
                                      scale = (1 - ((page - index).abs() * 0.18))
                                          .clamp(0.88, 1.0);
                                    }

                                    return Center(
                                      child: Transform.scale(
                                        scale: scale,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: VipHeaderCard(
                                    vipLevel: level,
                                    obtainedVip: obtainedVip,
                                    subtitle: obtainedVip
                                        ? 'VIP active'
                                        : 'Not obtained VIP',
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 10),

                          _VipDotsIndicator(
                            count: maxVipLevel,
                            activeIndex: vipLevel - 1,
                          ),

                          const SizedBox(height: 18),

                          const VipSectionTitle(title: 'Identification'),
                          const SizedBox(height: 10),

                          // ✅ now has access to ProfileViewModel because VipPage provides it
                          VipIdentificationSection(vipLevel: vipLevel),

                          const SizedBox(height: 18),

                          const VipSectionTitle(
                            title: 'Exclusive Privileges',
                            trailingText: '(3/24)',
                          ),
                          const SizedBox(height: 10),

                          const VipPrivilegesSection(),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  VipBottomRenewBar(
                    coinsText: '$renewCostCoins / ${renewDays}Days',
                    buttonText: 'Renew',
                    onRenew: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VipDotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _VipDotsIndicator({
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 18 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFE7D6A5).withOpacity(0.9)
                : const Color(0xFFE7D6A5).withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center title is truly centered on the screen
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),


          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


class _VipBackground extends StatelessWidget {
  const _VipBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF170C03),
            Color(0xFF0B0A08),
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFFFC857).withOpacity(0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
