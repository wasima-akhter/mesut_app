import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';
import 'customer_selection_sheet.dart';

class CustomerDropdownField extends ConsumerWidget {
  final String? selectedCustomerId;
  final String? selectedCustomerName;
  final ValueChanged<CustomerEntity> onCustomerSelected;
  final String? hintText;

  const CustomerDropdownField({
    super.key,
    required this.selectedCustomerId,
    this.selectedCustomerName,
    required this.onCustomerSelected,
    this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerListProvider);

    // Resolve name from state if not directly provided
    String displayName = selectedCustomerName ?? '';
    if (displayName.isEmpty && selectedCustomerId != null) {
      final match = state.customers.where((c) => c.id == selectedCustomerId);
      if (match.isNotEmpty) {
        displayName = match.first.name;
      }
    }

    final hasSelection = displayName.isNotEmpty;
    final effectiveHint = hintText ?? context.loc.selectExistingCustomer;

    return GestureDetector(
      onTap: () async {
        final selected = await CustomerSelectionSheet.show(
          context,
          selectedCustomerId: selectedCustomerId,
        );
        if (selected != null) {
          onCustomerSelected(selected);
        }
      },
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: const Color(0xFFDCDCDC)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.business_outlined,
              size: 20,
              color: Color(0xFF666666),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                hasSelection ? displayName : effectiveHint,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w400,
                  color: hasSelection
                      ? const Color(0xFF222222)
                      : const Color(0xFF999999),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (state.isLoading)
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF666666),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
