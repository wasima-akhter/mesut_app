import 'package:flutter/material.dart';

import '../../../app/theme/app_text_styles.dart';

import '../buttons/buttons.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
        if (actionText != null)
          AppTextButton(onPressed: onAction, text: actionText!),
      ],
    );
  }
}
