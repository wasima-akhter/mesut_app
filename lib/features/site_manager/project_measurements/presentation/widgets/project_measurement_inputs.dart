import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';

/// Labeled input field with custom borders and optional input formatters.
class MeasurementFieldWithLabel extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const MeasurementFieldWithLabel({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13.5.sp,
              color: const Color(0xFF999999),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 11.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Quantity counter with (-) and (+) action buttons.
class MeasurementQuantityCounter extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const MeasurementQuantityCounter({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.quantity,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 46.h,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (quantity > 1) onChanged(quantity - 1);
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 38.w,
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 18.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(quantity + 1),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 38.w,
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 18.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Unit selection dropdown (M², M, PCS) with safe fallback.
class MeasurementUnitDropdown extends StatelessWidget {
  final String unit;
  final ValueChanged<String> onChanged;

  static const List<String> availableUnits = ['M²', 'M', 'PCS'];

  const MeasurementUnitDropdown({
    super.key,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUnit = availableUnits.contains(unit) ? unit : 'M²';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.unit,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveUnit,
              isExpanded: true,
              style: TextStyle(fontSize: 15.sp, color: const Color(0xFF444444)),
              items: availableUnits
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Grey preview banner displaying live calculated area.
class MeasurementCalculatedAreaBox extends StatelessWidget {
  final double length;
  final double height;
  final int quantity;
  final double area;

  const MeasurementCalculatedAreaBox({
    super.key,
    required this.length,
    required this.height,
    required this.quantity,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final calcDetails =
        '${length.toStringAsFixed(0)}m × ${height.toStringAsFixed(0)}m × $quantity';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      color: const Color(0xFFF0F0F0),
      child: Text(
        context.loc.calculatedArea(area.toStringAsFixed(2), calcDetails),
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF777777)),
      ),
    );
  }
}
