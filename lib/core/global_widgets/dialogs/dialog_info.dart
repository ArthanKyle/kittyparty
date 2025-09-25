import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class DialogInfo {
  final String headerText;
  final String subText;
  final String? cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  DialogInfo({
    required this.headerText,
    required this.subText,
    this.cancelText,
    required this.confirmText,
    required this.onCancel,
    required this.onConfirm,
  });

  build(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                decoration: const BoxDecoration(
                  color: AppColors.accentWhite,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                height: 150,
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      headerText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.accentBlack,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.accentBlack,
                        overflow: subText.length >= 100
                            ? TextOverflow.ellipsis
                            : TextOverflow.visible,
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onCancel,
                            child: Text(
                              cancelText ?? "Cancel",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.accentBlack,

                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              confirmText,
                              style: const TextStyle(
                                color: AppColors.accentWhite,

                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}