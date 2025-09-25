import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class DialogUnsuccessful {
  final String headertext;
  final String subtext;
  final String textButton;
  final VoidCallback callback;
  DialogUnsuccessful(
      {required this.headertext,
        required this.subtext,
        required this.textButton,
        required this.callback});

  buildUnsuccessfulScreen(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.accentWhite,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              height: 375,
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: AppColors.primary,
                    size: 200,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    headertext,
                    style: const TextStyle(
                      color: AppColors.accentBlack,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtext,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.accentBlack,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      callback();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        AppColors.primary,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        const Size(50, 50),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        textButton,
                        style: const TextStyle(
                          color: AppColors.accentWhite,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}