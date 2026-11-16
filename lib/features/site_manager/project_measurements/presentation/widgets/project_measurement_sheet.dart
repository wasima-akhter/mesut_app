import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../domain/entities/project_measurement_entity.dart';
import '../providers/project_measurements_provider.dart';
import 'project_measurement_inputs.dart';

/// Bottom sheet dialog for creating or updating a scaffold measurement line item.
class ProjectMeasurementSheet extends ConsumerStatefulWidget {
  final ProjectMeasurementEntity? initialItem;

  const ProjectMeasurementSheet({super.key, this.initialItem});

  static Future<bool?> show(
    BuildContext context, {
    ProjectMeasurementEntity? initialItem,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProjectMeasurementSheet(initialItem: initialItem),
    );
  }

  @override
  ConsumerState<ProjectMeasurementSheet> createState() =>
      _ProjectMeasurementSheetState();
}

class _ProjectMeasurementSheetState
    extends ConsumerState<ProjectMeasurementSheet> {
  late final TextEditingController _positionController;
  late final TextEditingController _lengthController;
  late final TextEditingController _heightController;
  late final TextEditingController _remarkController;

  late int _quantity;
  late String _unit;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _positionController = TextEditingController(text: item?.position ?? '');
    _lengthController = TextEditingController(
      text: item != null && item.length > 0 ? _formatNumber(item.length) : '',
    );
    _heightController = TextEditingController(
      text: item != null && item.height > 0 ? _formatNumber(item.height) : '',
    );
    _remarkController = TextEditingController(text: item?.remark ?? '');
    _quantity = item != null && item.quantity > 0 ? item.quantity : 1;
    _unit = _normalizeUnit(item?.unit);
  }

  static String _formatNumber(double val) {
    if (val <= 0) return '';
    if (val == val.roundToDouble()) return val.toInt().toString();
    return val.toString();
  }

  static String _normalizeUnit(String? unit) {
    if (unit == null) return 'M²';
    final u = unit.trim().toUpperCase();
    if (u == 'M' || u == 'METER' || u == 'METERS') return 'M';
    if (u == 'PCS' || u == 'STK' || u == 'STÜCK') return 'PCS';
    return 'M²';
  }

  @override
  void dispose() {
    _positionController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  double _parseNumber(String text) {
    final clean = text.trim().replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  double get _currentLength => _parseNumber(_lengthController.text);
  double get _currentHeight => _parseNumber(_heightController.text);
  double get _calculatedArea => _currentLength * _currentHeight * _quantity;

  Future<void> _submit() async {
    final position = _positionController.text.trim();
    final length = _currentLength;
    final height = _currentHeight;

    if (position.isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseEnterPosition);
      return;
    }

    if (_lengthController.text.trim().isEmpty || length <= 0) {
      AppSnackBar.showError(context, context.loc.pleaseEnterLength);
      return;
    }

    if (_heightController.text.trim().isEmpty || height <= 0) {
      AppSnackBar.showError(context, context.loc.pleaseEnterHeight);
      return;
    }

    setState(() => _isSubmitting = true);

    final notifier = ref.read(projectMeasurementsProvider.notifier);
    final bool success;

    if (widget.initialItem == null) {
      success = await notifier.createMeasurement(
        position: position,
        length: length,
        height: height,
        quantity: _quantity,
        unit: _unit,
        remark: _remarkController.text.trim(),
      );
      if (mounted && success) {
        AppSnackBar.showSuccess(context, context.loc.measurementCreated);
      }
    } else {
      success = await notifier.updateMeasurement(
        measurementId: widget.initialItem!.id,
        position: position,
        length: length,
        height: height,
        quantity: _quantity,
        unit: _unit,
        remark: _remarkController.text.trim(),
      );
      if (mounted && success) {
        AppSnackBar.showSuccess(context, context.loc.measurementUpdated);
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        AppSnackBar.showError(context, context.loc.operationFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;
    final title = isEdit
        ? context.loc.editMeasurementItem
        : context.loc.addMeasurementItem;
    final buttonText =
        isEdit ? context.loc.saveChanges : context.loc.saveLineItem;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.90,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD5D5D5),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 8.h),
              child: Text(
                title,
                style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w800),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MeasurementFieldWithLabel(
                      label: context.loc.position,
                      controller: _positionController,
                      hint: 'e.g. North Facade (Front Wall)',
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: MeasurementFieldWithLabel(
                            label: context.loc.length,
                            controller: _lengthController,
                            hint: '30.00 m',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*[\.,]?\d{0,2}'),
                              ),
                            ],
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: MeasurementFieldWithLabel(
                            label: context.loc.height,
                            controller: _heightController,
                            hint: '10.00 m',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*[\.,]?\d{0,2}'),
                              ),
                            ],
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: MeasurementQuantityCounter(
                            quantity: _quantity,
                            onChanged: (val) => setState(() => _quantity = val),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: MeasurementUnitDropdown(
                            unit: _unit,
                            onChanged: (val) => setState(() => _unit = val),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    MeasurementCalculatedAreaBox(
                      length: _currentLength,
                      height: _currentHeight,
                      quantity: _quantity,
                      area: _calculatedArea,
                    ),
                    SizedBox(height: 14.h),
                    MeasurementFieldWithLabel(
                      label: context.loc.remark,
                      controller: _remarkController,
                      hint: 'e.g. Standard steel frames required',
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 22.h),
                    AppButton(
                      text: buttonText,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submit,
                      borderRadius: 6.r,
                    ),
                    SizedBox(height: 4.h),
                    AppTextButton(
                      text: context.loc.cancel,
                      onPressed: () => Navigator.pop(context),
                      foregroundColor: const Color(0xFF555555),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
