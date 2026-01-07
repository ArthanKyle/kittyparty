import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kittyparty/features/profile/profile_pages/agency_room.dart';
import 'package:kittyparty/features/wallet/view/wallet_page.dart';

import '../../../../app.dart';

class ProfileCards extends StatelessWidget {
  const ProfileCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          // Wallet & Agency row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 28,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Wallet",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AgencyRoom()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        FaIcon(
                          FontAwesomeIcons.users,
                          size: 28,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Agency",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // VIP Card
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.vip);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Color(0xFFFFD966),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD966), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  FaIcon(
                    FontAwesomeIcons.crown,
                    size: 28,
                    color: Color(0xFFb37400),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "VIP",
                    style: TextStyle(
                      color: Color(0xFFb37400),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
