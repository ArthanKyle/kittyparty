import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/global_widgets/dialogs/dialog_info.dart';
import '../../../../auth/widgets/arrow_back.dart';
import '../../../viewmodel/dailyTask_viewmodel.dart';

class DailyTaskHeader extends StatelessWidget {
  final String? token;

  const DailyTaskHeader({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // or .light if you want white icons
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20, // ✅ same as Wallet
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
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: token == null
                  ? null
                  : () async {
                final rootContext = context;

                try {
                  await context
                      .read<DailyTaskViewModel>()
                      .signIn(token!);
                } catch (e) {
                  DialogInfo(
                    headerText: "Notice",
                    subText: "You have already signed in today.",
                    confirmText: "OK",
                    onConfirm: () {
                      Navigator.of(
                        rootContext,
                        rootNavigator: true,
                      ).pop();
                    },
                    onCancel: () {
                      Navigator.of(
                        rootContext,
                        rootNavigator: true,
                      ).pop();
                    },
                  ).build(rootContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Sign in now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
