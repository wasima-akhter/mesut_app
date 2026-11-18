import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/app_error_resolver.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import 'domain/entities/mobile_inspection_entity.dart';
import 'presentation/providers/mobile_inspection_provider.dart';

class InspectionSurveyPage extends ConsumerStatefulWidget {
  const InspectionSurveyPage({super.key});

  @override
  ConsumerState<InspectionSurveyPage> createState() =>
      _InspectionSurveyPageState();
}

class _InspectionSurveyPageState extends ConsumerState<InspectionSurveyPage> {
  final _formKey = GlobalKey<FormState>();
  final _areaCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  bool _seeded = false;
  bool _submitting = false;

  @override
  void dispose() {
    _areaCtrl.dispose();
    _heightCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  void _seedFields(MobileInspectionEntity item) {
    if (_seeded) return;
    _seeded = true;
    if (item.scaffoldArea > 0) _areaCtrl.text = '${item.scaffoldArea}';
    if (item.scaffoldHeight > 0) _heightCtrl.text = '${item.scaffoldHeight}';
    if (item.scaffoldType.isNotEmpty) _typeCtrl.text = item.scaffoldType;
  }

  Future<void> _submit(String id) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final area = double.tryParse(_areaCtrl.text.trim()) ?? 0;
    final height = double.tryParse(_heightCtrl.text.trim()) ?? 0;
    final type = _typeCtrl.text.trim();

    setState(() => _submitting = true);
    try {
      await ref
          .read(mobileInspectionsProvider.notifier)
          .completeInspection(
            id,
            scaffoldArea: area,
            scaffoldHeight: height,
            scaffoldType: type,
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, context.loc.surveyDone);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final lang = ref.read(appLanguageProvider).code;
      final resolved = AppErrorResolver.resolve(e, languageCode: lang);
      AppSnackBar.showError(context, resolved.displayMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final selectedId = ref.watch(selectedInspectionIdProvider);

    if (selectedId == null || selectedId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(context.loc.technicalFieldSurvey)),
        body: Center(child: Text(context.loc.noInspections)),
      );
    }

    final detailAsync = ref.watch(mobileInspectionDetailProvider(selectedId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.loc.technicalFieldSurvey)),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.loc.somethingWentWrong),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(mobileInspectionDetailProvider(selectedId)),
                child: Text(context.loc.mapRetry),
              ),
            ],
          ),
        ),
        data: (inspection) {
          _seedFields(inspection);
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inspection.siteTitle,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${inspection.address}, ${inspection.postalCode} ${inspection.city}'
                        .trim(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: _areaCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.loc.scaffoldAreaLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v?.trim() ?? '');
                      return (n == null || n <= 0)
                          ? context.loc.somethingWentWrong
                          : null;
                    },
                  ),
                  SizedBox(height: 14.h),
                  TextFormField(
                    controller: _heightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.loc.scaffoldHeightLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v?.trim() ?? '');
                      return (n == null || n <= 0)
                          ? context.loc.somethingWentWrong
                          : null;
                    },
                  ),
                  SizedBox(height: 14.h),
                  TextFormField(
                    controller: _typeCtrl,
                    decoration: InputDecoration(
                      labelText: context.loc.scaffoldTypeLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.loc.somethingWentWrong
                        : null,
                  ),
                  SizedBox(height: 24.h),
                  if (inspection.isPending)
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        onPressed: _submitting
                            ? null
                            : () => _submit(inspection.id),
                        text: _submitting ? '...' : context.loc.completeSurvey,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
