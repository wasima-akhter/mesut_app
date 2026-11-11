import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../helpers/phone_helper.dart';
import '../../localization/context_extensions.dart';

class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    required this.controller,
    required this.initialCountryCode,
    this.hint,
    this.borderRadius = 5,
    this.fillColor = Colors.white,
    this.borderColor,
    this.focusedBorderColor,
    this.contentPadding,
    this.onChanged,
    this.onCountryChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String initialCountryCode;
  final String? hint;
  final double borderRadius;
  final Color fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final EdgeInsetsGeometry? contentPadding;
  final ValueChanged<String>? onChanged;
  final ValueChanged<Country>? onCountryChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final langCode = loc.localeCode.toLowerCase().startsWith('de') ? 'de' : 'en';
    final effectiveBorderColor =
        borderColor ?? Colors.black.withValues(alpha: 0.12);
    final effectiveFocusedColor = focusedBorderColor ?? AppColors.primary;

    return IntlPhoneField(
      controller: controller,
      initialCountryCode: initialCountryCode,
      languageCode: langCode,
      enabled: enabled,
      disableLengthCheck: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      cursorColor: effectiveFocusedColor,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      dropdownTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      flagsButtonPadding: EdgeInsets.only(left: 10.w, right: 4.w),
      dropdownIconPosition: IconPosition.trailing,
      dropdownIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18.sp,
        color: AppColors.textSecondary,
      ),
      showCountryFlag: true,
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: AppColors.white,
        countryCodeStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        countryNameStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        searchFieldCursorColor: effectiveFocusedColor,
        searchFieldInputDecoration: InputDecoration(
          hintText: loc.searchCountry,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: effectiveFocusedColor, width: 1.4),
          ),
        ),
      ),
      onChanged: (phone) {
        onChanged?.call(phone.completeNumber);
      },
      onCountryChanged: (country) {
        onCountryChanged?.call(country);
        if (controller.text.isNotEmpty) {
          onChanged?.call(
            PhoneHelper.formatCompleteNumber(country, controller.text),
          );
        }
      },
      validator: (phone) {
        final country = PhoneHelper.findCountryByIso(
          phone?.countryISOCode ?? initialCountryCode,
        );
        return PhoneHelper.validate(
          nationalNumber: phone?.number ?? controller.text,
          country: country,
          languageCode: langCode,
        );
      },
      decoration: InputDecoration(
        hintText: hint ?? loc.enterPhone,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black26),
        counterText: '',
        filled: true,
        fillColor: fillColor,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: effectiveFocusedColor, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        errorMaxLines: 2,
      ),
    );
  }
}
