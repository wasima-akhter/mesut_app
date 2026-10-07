import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// add
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';

class LegalWebPage extends StatefulWidget {
  final String title;

  /// Complete HTML + CSS received from backend.
  final String html;

  const LegalWebPage({super.key, required this.title, required this.html});

  @override
  State<LegalWebPage> createState() => _LegalWebPageState();
}

class _LegalWebPageState extends State<LegalWebPage> {
  Key _contentKey = UniqueKey();

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    setState(() {
      _contentKey = UniqueKey();
    });

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.error,

                onRefresh: _refresh,

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 35.h),

                  child: HtmlWidget(
                    key: _contentKey,

                    widget.html,

                    // ==================================================
                    // HTML + CSS
                    // ==================================================
                    customStylesBuilder: (element) {
                      switch (element.localName) {
                        case 'body':
                          return {'font-size': '16px', 'line-height': '1.7'};

                        case 'h1':
                          return {
                            'font-size': '28px',
                            'font-weight': '700',
                            'margin-bottom': '20px',
                          };

                        case 'h2':
                          return {
                            'font-size': '22px',
                            'font-weight': '700',
                            'margin-top': '25px',
                            'margin-bottom': '10px',
                          };

                        case 'h3':
                          return {
                            'font-size': '19px',
                            'font-weight': '600',
                            'margin-top': '20px',
                            'margin-bottom': '8px',
                          };

                        case 'p':
                          return {
                            'font-size': '16px',
                            'line-height': '1.7',
                            'margin-bottom': '15px',
                          };

                        case 'li':
                          return {
                            'font-size': '16px',
                            'line-height': '1.7',
                            'margin-bottom': '7px',
                          };

                        default:
                          return null;
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 10.h),

      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              widget.title,

              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 19.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          _circleButton(icon: Icons.refresh_rounded, onTap: _refresh),
        ],
      ),
    );
  }

  // ============================================================
  // CIRCLE BUTTON
  // ============================================================

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(50.r),

        child: Container(
          width: 39.w,
          height: 39.w,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            border: Border.all(color: AppColors.border),
          ),

          child: Icon(icon, size: 19.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
