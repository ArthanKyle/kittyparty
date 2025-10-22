import 'package:flutter/material.dart';

// Directly import your LevelPage here
import '../../profile/profile_pages/collection_page.dart';

class LoginSelection extends StatefulWidget {
  const LoginSelection({super.key});

  @override
  State<LoginSelection> createState() => _LoginSelectionState();
}

class _LoginSelectionState extends State<LoginSelection> {
  @override
  Widget build(BuildContext context) {
    // 👉 Just display the LevelPage instead of the login buttons
    return const CollectionPage();
  }
}
