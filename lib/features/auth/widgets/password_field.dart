import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';


class PasswordField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String) validator;
  final String? hintText;

  const PasswordField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.validator,
    this.hintText,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          validator: (value) => widget.validator(widget.controller.text),
          obscureText: !passwordVisible,
          cursorColor: AppColors.accentBlack,
          decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18.5),
            filled: true,
            fillColor: AppColors.accentWhite,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: AppColors.gray,
              fontSize: 11.5,
              fontWeight: FontWeight.w300,
            ),
            errorStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              color: AppColors.errorColor,
              fontSize: 12,
            ),
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
            suffixIcon: IconButton(
              color: AppColors.primary,
              icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
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