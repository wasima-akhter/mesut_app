import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/services/launcher_service.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsCustomerCard extends StatelessWidget {
  final ProjectCustomerDetail customer;

  const ProjectDetailsCustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    if (customer.isEmpty) return const SizedBox.shrink();

    final contact = customer.primaryContact;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.customer,
            style: TextStyle(
              fontSize: 17.sp,
              color: const Color(0xFF777777),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.business_outlined,
                size: 18.sp,
                color: const Color(0xFF555555),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
              if (customer.category.isNotEmpty) ...[
                SizedBox(width: 5.w),
                Text(
                  '• ${customer.category}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF777777),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (!contact.isEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Column(
                children: [
                  if (contact.name.isNotEmpty)
                    _ContactRow(
                      icon: Icons.person_outline,
                      text: context.loc.contactLabel(contact.name),
                    ),
                  if (contact.phone.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _ContactRow(
                      icon: Icons.phone_outlined,
                      text: contact.phone,
                      onTap: () =>
                          AppLauncherService.makePhoneCall(contact.phone),
                    ),
                  ],
                  if (contact.email.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _ContactRow(
                      icon: Icons.mail_outline,
                      text: contact.email,
                      onTap: () =>
                          AppLauncherService.sendEmail(email: contact.email),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (contact.phone.isNotEmpty || contact.email.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                if (contact.phone.isNotEmpty)
                  Expanded(
                    child: AppOutlinedButton(
                      text: context.loc.callClient,
                      leadingIcon: Icons.phone_outlined,
                      onPressed: () async {
                        final success = await AppLauncherService.makePhoneCall(
                          contact.phone,
                        );
                        if (!success && context.mounted) {
                          AppSnackBar.info(
                            context.loc.callingClient,
                            context: context,
                          );
                        }
                      },
                      foregroundColor: const Color(0xFF333333),
                      borderColor: const Color(0xFFD8D8D8),
                      borderRadius: 6.r,
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 7.h,
                      ),
                      size: AppButtonSize.small,
                    ),
                  ),
                if (contact.phone.isNotEmpty && contact.email.isNotEmpty)
                  SizedBox(width: 8.w),
                if (contact.email.isNotEmpty)
                  Expanded(
                    child: AppOutlinedButton(
                      text: context.loc.mailClient,
                      leadingIcon: Icons.mail_outline,
                      onPressed: () async {
                        final success = await AppLauncherService.sendEmail(
                          email: contact.email,
                          subject: 'Project Inquiry: ${customer.name}',
                        );
                        if (!success && context.mounted) {
                          AppSnackBar.info(
                            context.loc.openingEmail,
                            context: context,
                          );
                        }
                      },
                      foregroundColor: const Color(0xFF333333),
                      borderColor: const Color(0xFFD8D8D8),
                      borderRadius: 6.r,
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 7.h,
                      ),
                      size: AppButtonSize.small,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _ContactRow({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF777777)),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.5.sp,
              color: onTap != null
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}
