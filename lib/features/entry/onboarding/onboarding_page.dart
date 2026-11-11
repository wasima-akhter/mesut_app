import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/app_text_button.dart';
import '../../../app/constants/route_constants.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  List<_OnboardingItem> _getItems() {
    final loc = AppLocalization.current;
    return [
      _OnboardingItem(
        image: 'assets/images/onboarding_1.png',
        title: loc.onboarding1Title,
        description: loc.onboarding1Subtitle,
      ),
      _OnboardingItem(
        image: 'assets/images/onboarding_2.png',
        title: loc.onboarding2Title,
        description: loc.onboarding2Subtitle,
      ),
      _OnboardingItem(
        image: 'assets/images/onboarding_2.png',
        title: loc.onboarding3Title,
        description: loc.onboarding3Subtitle,
      ),
    ];
  }

  bool _isLastPage(int length) => _currentPage == length - 1;

  void _next(int length) {
    if (_isLastPage(length)) {
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
    ref.read(storageServiceProvider).setOnboardingCompleted(true);
    context.go(RouteConstants.signIn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems();
    final isLast = _isLastPage(items.length);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // PageView
                PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(items[index].image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            _buildTopBar(),

                            Expanded(
                              child: _OnboardingContent(item: items[index]),
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
                  child: _buildBottomSection(items.length, isLast),
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
          child: AppTextButton(
            text: AppLocalization.current.skip,
            onPressed: _skip,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(int count, bool isLast) {
    final loc = AppLocalization.current;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          children: [
            _PageIndicator(count: count, currentIndex: _currentPage),

            SizedBox(height: 24.h),

            AppButton(
              text: isLast ? loc.getStarted : loc.next,
              onPressed: () => _next(count),
            ),
          ],
        ),
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
