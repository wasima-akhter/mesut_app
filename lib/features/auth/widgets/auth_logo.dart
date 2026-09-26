// lib/features/auth/presentation/widgets/auth_logo.dart

import 'package:construction_app/core/widgets/images/app_image.dart';
import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: AppImage(assetPath: "assets/logo/app_icon.png"),
      //  Center(
      //   child: Text(
      //     'A',
      //     style: TextStyle(
      //       fontFamily: 'Raleway',
      //       fontSize: 56.sp,
      //       height: 1,
      //       fontWeight: FontWeight.w900,
      //       fontStyle: FontStyle.italic,
      //       color: AppColors.primary400,
      //     ),
      //   ),
      // ),
    );
  }
}
