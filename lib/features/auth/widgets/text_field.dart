import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';


class BasicTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String) validator;
  final Function(String)? onChange;
  final String? hintText;
  final TextInputType? inputType;
  final int? maxLength;
  final bool? enable;

  const BasicTextField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.validator,
    this.hintText,
    this.inputType,
    this.onChange,
    this.maxLength,
    this.enable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          cursorColor: AppColors.accentBlack,
          validator: (value) {
            return validator(controller.text);
          },
          onChanged: onChange,
          maxLength: maxLength,
          keyboardType: inputType,
          enabled: enable ?? true,
          decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18.5),
            filled: true,
            fillColor: AppColors.accentWhite,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.gray,
              fontWeight: FontWeight.w300,
            ),
            errorStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              color: AppColors.errorColor,
              fontSize: 12,
            ),

            // ✅ Apply radius 30 to all borders
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: AppColors.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: AppColors.errorColor),
            ),
          ),
          style: const TextStyle(
            color: AppColors.accentBlack,

            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}