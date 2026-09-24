import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/app_text_button.dart';
import '../../../app/constants/route_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      icon: Icons.assignment_rounded,
      title: 'Stay on top of your work',
      description:
          'See your assigned jobs, project details, '
          'tasks, and safety instructions in one place.',
    ),
    _OnboardingItem(
      icon: Icons.timer_rounded,
      title: 'Track your time easily',
      description:
          'Start and manage your working time, breaks, '
          'and activities without unnecessary paperwork.',
    ),
    _OnboardingItem(
      icon: Icons.groups_rounded,
      title: 'Keep the whole team connected',
      description:
          'Stay aligned with your team, projects, '
          'schedules, and day-to-day site operations.',
    ),
  ];

  bool get _isLastPage => _currentPage == _items.length - 1;

  void _next() {
    if (_isLastPage) {
      _finish();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _skip() {
    _finish();
  }

  void _finish() {
    context.go(RouteConstants.signIn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingContent(item: _items[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 56.h,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppTextButton(text: 'Skip', onPressed: _skip),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          _PageIndicator(count: _items.length, currentIndex: _currentPage),
          SizedBox(height: 24.h),
          AppButton(
            text: _isLastPage ? 'Get Started' : 'Continue',
            onPressed: _next,
          ),
        ],
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 480.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 24.h),
            _Illustration(icon: item.icon),
            SizedBox(height: 48.h),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220.r,
      height: 220.r,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 132.r,
          height: 132.r,
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Icon(icon, size: 64.r, color: AppColors.primary600),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final selected = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: selected ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary600 : AppColors.primary200,
            borderRadius: BorderRadius.circular(20.r),
          ),
        );
      }),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
