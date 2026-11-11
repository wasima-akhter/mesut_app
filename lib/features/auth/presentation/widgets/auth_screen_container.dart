import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'auth_back_button.dart';
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
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          surfaceTintColor: const Color(0xFFF8F8F8),
          leadingWidth: 60.w,
          leading: showBack
              ? Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: const AuthBackButton(),
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
          child: Column(
            children: [
              AuthLogo(height: 80.h),
              SizedBox(height: 34.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
