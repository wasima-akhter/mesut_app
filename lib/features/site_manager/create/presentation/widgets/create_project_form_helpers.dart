import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/buttons/buttons.dart';

class FormSectionTitle extends StatelessWidget {
  final String title;

  const FormSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111111),
      ),
    );
  }
}

class FormFieldLabel extends StatelessWidget {
  final String label;

  const FormFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF222222),
      ),
    );
  }
}

class FormFieldLabelSmall extends StatelessWidget {
  final String label;

  const FormFieldLabelSmall({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF555555),
      ),
    );
  }
}

class FormCard extends StatelessWidget {
  final Widget child;

  const FormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class FormTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const FormTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(fontSize: 17.sp, color: const Color(0xFF222222)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 16.sp, color: const Color(0xFF999999)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: Color(0xFFC8102E)),
        ),
      ),
    );
  }
}

class StepActionButtons extends StatelessWidget {
  final String previousText;
  final String nextText;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isSubmitting;

  const StepActionButtons({
    super.key,
    required this.previousText,
    required this.nextText,
    required this.onPrevious,
    required this.onNext,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppOutlinedButton(
            text: previousText,
            onPressed: isSubmitting ? null : onPrevious,
            borderRadius: 6.r,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: AppButton(
            text: nextText,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onNext,
            borderRadius: 6.r,
          ),
        ),
      ],
    );
  }
}
