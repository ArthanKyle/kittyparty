import 'package:flutter/material.dart';
import 'colors.dart';


class Inputs {
  static OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Colors.transparent,
    ),
    borderRadius: BorderRadius.circular(8.0),
  );

  static OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: AppColors.accentWhite,
    ),
    borderRadius: BorderRadius.circular(30),
  );

  static OutlineInputBorder errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: AppColors.errorColor,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(30),
  );

  static OutlineInputBorder blackBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: AppColors.solidBlack,
      width: 1.5,
    ),
    borderRadius: BorderRadius.circular(30),
  );
}