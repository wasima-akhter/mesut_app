import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/buttons/buttons.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppBackButton(
      onPressed: onPressed,
      size: 40.r,
      iconSize: 22.r,
    );
  }
}
