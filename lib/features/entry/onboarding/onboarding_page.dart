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
      image: 'assets/images/onboarding_1.png',
      title: 'Stay on top of your work',
      description:
          'See your assigned jobs, project details, '
          'tasks, and safety instructions in one place.',
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_2.png',
      title: 'Track your time easily',
      description:
          'Start and manage your working time, breaks, '
          'and activities without unnecessary paperwork.',
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_2.png',
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // PageView
                PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_items[index].image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            _buildTopBar(),

                            Expanded(
                              child: _OnboardingContent(item: _items[index]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Dots + Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomSection(),
                ),
              ],
            ),
          ),
        ],
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        150.h, // Space for dots + button
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
            ),

            SizedBox(height: 12.h),

            Text(
              item.description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                height: 1.55,
              ),
            ),
          ],
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
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}
