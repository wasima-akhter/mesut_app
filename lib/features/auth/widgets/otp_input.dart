// lib/features/auth/presentation/widgets/otp_input.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({required this.controller, super.key, this.onCompleted});

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(6, (_) => TextEditingController());

    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _updateValue() {
    final value = _controllers.map((e) => e.text).join();

    widget.controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );

    if (value.length == 6) {
      widget.onCompleted?.call(value);
    }
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');

      for (var i = 0; i < digits.length; i++) {
        final target = index + i;

        if (target >= 6) {
          break;
        }

        _controllers[target].text = digits[i];
      }

      final nextIndex = (index + digits.length).clamp(0, 5);

      if (digits.length < 6) {
        _focusNodes[nextIndex].requestFocus();
      } else {
        _focusNodes[5].unfocus();
      }

      _updateValue();
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    _updateValue();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final hasValue = _controllers[index].text.isNotEmpty;

        return SizedBox(
          width: 38.w,
          height: 38.h,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.r),
                borderSide: BorderSide(
                  color: hasValue ? AppColors.primary400 : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.r),
                borderSide: BorderSide(color: AppColors.primary400, width: 1.2),
              ),
            ),
            onChanged: (value) {
              _onChanged(index, value);
            },
          ),
        );
      }),
    );
  }
}
