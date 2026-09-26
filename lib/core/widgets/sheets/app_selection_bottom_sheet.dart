import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

class AppSelectionBottomSheet<T> extends StatelessWidget {
  const AppSelectionBottomSheet({
    super.key,
    required this.items,
    required this.labelBuilder,
    this.selectedItem,
  });

  final List<T> items;
  final String Function(T item) labelBuilder;
  final T? selectedItem;

  static Future<T?> show<T>(
    BuildContext context, {
    required List<T> items,
    required String Function(T item) labelBuilder,
    T? selectedItem,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (_) {
        return AppSelectionBottomSheet<T>(
          items: items,
          labelBuilder: labelBuilder,
          selectedItem: selectedItem,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            title: Text(labelBuilder(item), style: AppTextStyles.bodyLarge),
            trailing: item == selectedItem ? const Icon(Icons.check) : null,
            onTap: () => context.pop(item),
          );
        },
      ),
    );
  }
}
