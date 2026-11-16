import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../core/localization/context_extensions.dart';

class SiteManagerHomeHeader extends StatelessWidget {
  const SiteManagerHomeHeader({
    super.key,
    required this.userName,
    required this.unreadCount,
    this.avatarUrl,
  });

  final String userName;
  final int unreadCount;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.loc.welcomeBack,
                style: TextStyle(
                  fontSize: 19.sp,
                  color: const Color(0xFF777777),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF171717),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: Color(0xFF6B7280), size: 22)
                : null,
          ),
        ),
        const SizedBox(width: 9),
        GestureDetector(
          onTap: () => context.push(RouteConstants.notifications),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE4E4E4)),
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  size: 21,
                  color: Color(0xFF777777),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE22B3B),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
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
