import 'package:flutter/material.dart';

class AgencyCard extends StatelessWidget {
  final String username;
  final String agentId;
  final int membersCount;
  final int maxMembers;
  final VoidCallback onJoin;

  const AgencyCard({
    super.key,
    required this.username,
    required this.agentId,
    required this.membersCount,
    required this.maxMembers,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(60, 24, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: Row(
            children: [
              const SizedBox(width: 56),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(color: Colors.amber),
                  ),
                  Text(
                    'Agent ID: $agentId',
                    style: const TextStyle(color: Colors.amber),
                  ),
                  Text(
                    '$membersCount/$maxMembers',
                    style: const TextStyle(color: Colors.amber),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          top: -10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.amber),
              ),
              child: const Icon(Icons.person),
            ),
          ),
        ),
      ],
    );
  }
}
