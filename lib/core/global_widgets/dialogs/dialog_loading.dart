import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class DialogLoading {
  final String subtext;
  final bool? willPop;

  DialogLoading({required this.subtext, this.willPop});

  Future<void> build(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => willPop ?? true,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.accentWhite,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                height: 200,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtext,
                      style: const TextStyle(
                        color: AppColors.accentBlack,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
