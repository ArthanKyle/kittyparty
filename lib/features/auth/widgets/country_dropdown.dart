import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

class CountryDropdown extends StatelessWidget {
  final String? selectedCountry;
  final Function(String?) onChanged;

  const CountryDropdown({
    super.key,
    required this.selectedCountry,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedCountry,
          decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18.5),
            filled: true,
            fillColor: AppColors.accentWhite,
            hintText: "Select country",
            hintStyle: const TextStyle(
              color: AppColors.gray,
              fontFamily: "Poppins",
              fontSize: 9,
              fontWeight: FontWeight.w300,
            ),
            errorStyle: const TextStyle(
              fontFamily: "Poppins",
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
          ),
          dropdownColor: AppColors.accentWhite,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: const TextStyle(
            color: AppColors.accentBlack,
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          items: Strings.countries.map((country) {
            return DropdownMenuItem<String>(
              value: country["code"],
              child: Text(
                "${country["flag"]} ${country["name"]}",
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentBlack,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select your nationality";
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}