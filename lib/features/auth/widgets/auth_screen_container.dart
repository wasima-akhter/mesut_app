// lib/features/auth/widgets/auth_screen_container.dart

import 'package:construction_app/features/auth/widgets/auth_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'auth_logo.dart';

class AuthScreenContainer extends StatelessWidget {
  final Widget child;
  final bool showBack;

  const AuthScreenContainer({
    super.key,
    required this.child,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          surfaceTintColor: const Color(0xFFF8F8F8),
          leadingWidth: 60.w,
          leading: (showBack)
              ? Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: AuthBackButton(),
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
          child: Column(
            children: [
              ...[AuthLogo(height: 80.h), SizedBox(height: 34.h)],

              child,
            ],
          ),
        ),
      ),
    );
  }
}
