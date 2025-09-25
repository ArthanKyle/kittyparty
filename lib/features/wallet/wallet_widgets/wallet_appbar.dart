  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:kittyparty/features/auth/widgets/arrow_back.dart';
  import '../../../core/constants/colors.dart';

  enum WalletType { coins, diamonds }

  class WalletAppBar extends StatelessWidget {
    final WalletType type;
    final TabController controller;

    const WalletAppBar({
      super.key,
      required this.type,
      required this.controller,
    });

    @override
    Widget build(BuildContext context) {
      final gradientColors = type == WalletType.coins
          ? AppColors.goldShineGradient
          : AppColors.diamondGradient;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light, // makes status bar icons white
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12, // push below status bar
            left: 24,
            right: 24,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ArrowBack(onTap: () => Navigator.pop(context)),
                  const Text(
                    "Wallet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 16),

              // TabBar
              TabBar(
                controller: controller,
                indicatorColor: AppColors.accentPink,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Coins"),
                  Tab(text: "Diamonds"),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
