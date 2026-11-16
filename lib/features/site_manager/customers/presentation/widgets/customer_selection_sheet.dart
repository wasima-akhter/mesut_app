import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';

class CustomerSelectionSheet extends ConsumerStatefulWidget {
  final String? selectedCustomerId;

  const CustomerSelectionSheet({
    super.key,
    this.selectedCustomerId,
  });

  static Future<CustomerEntity?> show(
    BuildContext context, {
    String? selectedCustomerId,
  }) {
    return showModalBottomSheet<CustomerEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerSelectionSheet(
        selectedCustomerId: selectedCustomerId,
      ),
    );
  }

  @override
  ConsumerState<CustomerSelectionSheet> createState() =>
      _CustomerSelectionSheetState();
}

class _CustomerSelectionSheetState extends ConsumerState<CustomerSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);
    final height = MediaQuery.sizeOf(context).height * 0.78;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          _buildHeader(context, state.total),
          _buildSearchBar(),
          Expanded(child: _buildListContent(state)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int total) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 10.w, 10.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Text(
            context.loc.selectCustomer,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          SizedBox(width: 8.w),
          if (total > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$total',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) =>
              ref.read(customerListProvider.notifier).onSearchChanged(val),
          style: TextStyle(fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: context.loc.searchCustomerByName,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF888888),
            ),
            prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF777777)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(customerListProvider.notifier)
                          .onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
        ),
      ),
    );
  }

  Widget _buildListContent(CustomerListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.loc.failedToLoadCustomers,
              style: TextStyle(fontSize: 15.sp, color: Colors.red),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => ref
                  .read(customerListProvider.notifier)
                  .loadCustomers(isRefresh: true),
              child: Text(context.loc.retry),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Text(
          context.loc.noCustomersFound,
          style: TextStyle(fontSize: 15.sp, color: const Color(0xFF777777)),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 60) {
          ref.read(customerListProvider.notifier).loadNextPage();
        }
        return false;
      },
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
        itemCount: state.customers.length + (state.hasNextPage ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
        itemBuilder: (context, index) {
          if (index >= state.customers.length) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              alignment: Alignment.center,
              child: state.isLoadingMore
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SizedBox.shrink(),
            );
          }

          final customer = state.customers[index];
          final isSelected = customer.id == widget.selectedCustomerId;

          return _buildCustomerItem(customer, isSelected);
        },
      ),
    );
  }

  Widget _buildCustomerItem(CustomerEntity customer, bool isSelected) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(customer),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          customer.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFC8102E)
                                : const Color(0xFF222222),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          customer.category,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (customer.primaryContact != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Contact: ${customer.primaryContact!.name}${customer.primaryContact!.phone.isNotEmpty ? " • ${customer.primaryContact!.phone}" : ""}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF777777),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFC8102E),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
