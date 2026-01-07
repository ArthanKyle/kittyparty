// lib/features/landing/landing_widgets/profile_widgets/daily_widgets/daily_task_header.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../../../core/global_widgets/dialogs/dialog_loading.dart';
import '../../../../auth/widgets/arrow_back.dart';
import '../../../viewmodel/dailyTask_viewmodel.dart';

class DailyTaskHeader extends StatelessWidget {
  /// This is USER IDENTIFICATION (e.g. "46634"), NOT JWT
  final String? userIdentification;

  const DailyTaskHeader({
    super.key,
    required this.userIdentification,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 16,
          right: 16,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE4A0),
              Color(0xFFFFF0D1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            ArrowBack(onTap: () => Navigator.pop(context)),

            const Text(
              'Task Center',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),


            const SizedBox(height: 14),

            // ================= SIGN-IN BUTTON =================
            Consumer<DailyTaskViewModel>(
              builder: (context, vm, _) {
                final bool disabled =
                    vm.signedInToday || vm.isSigningIn || userIdentification == null;

                return ElevatedButton(
                  onPressed: disabled
                      ? null
                      : () async {
                    DialogLoading(subtext: "Signing in...")
                        .build(context);

                    try {
                      await context
                          .read<DailyTaskViewModel>()
                          .signIn(userIdentification!);

                      Navigator.of(context, rootNavigator: true).pop();

                      DialogInfo(
                        headerText: "Success",
                        subText: "Daily sign-in reward claimed!",
                        confirmText: "OK",
                        onConfirm: () =>
                            Navigator.of(context, rootNavigator: true)
                                .pop(),
                        onCancel: () =>
                            Navigator.of(context, rootNavigator: true)
                                .pop(),
                      ).build(context);
                    } catch (_) {
                      Navigator.of(context, rootNavigator: true).pop();

                      DialogInfo(
                        headerText: "Notice",
                        subText: "You have already signed in today.",
                        confirmText: "OK",
                        onConfirm: () =>
                            Navigator.of(context, rootNavigator: true)
                                .pop(),
                        onCancel: () =>
                            Navigator.of(context, rootNavigator: true)
                                .pop(),
                      ).build(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    disabled ? Colors.grey : Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    vm.signedInToday ? "Signed Today" : "Sign in now",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
