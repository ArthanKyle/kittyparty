import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittyparty/features/auth/widgets/arrow_back.dart';
import '../../../core/constants/colors.dart';

class ConvertDiamondsAppBar extends StatelessWidget {
  const ConvertDiamondsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // makes status bar icons white
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12, // ✅ cover status bar
          left: 24,
          right: 24,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.diamondGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ArrowBack(onTap: () => Navigator.pop(context)),
            const Text(
              "Convert Diamonds",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 24), // keeps title centered
          ],
        ),
      ),
    );
  }
}
