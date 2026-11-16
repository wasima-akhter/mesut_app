import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/enums/backend_enums.dart';
import '../../../../../core/errors/app_error_resolver.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../../mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../providers/mobile_time_tracking_provider.dart';

class MobileManualTimeDialog extends ConsumerStatefulWidget {
  const MobileManualTimeDialog({super.key});

  @override
  ConsumerState<MobileManualTimeDialog> createState() =>
      _MobileManualTimeDialogState();
}

class _MobileManualTimeDialogState
    extends ConsumerState<MobileManualTimeDialog> {
  String? _selectedPhaseId;
  BackendActivityType _activity = BackendActivityType.erection;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  int _breakMinutes = 30;
  bool _submitting = false;

  Future<void> _submit() async {
    final phaseId = _selectedPhaseId;
    if (phaseId == null || phaseId.isEmpty) return;

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime.hour,
      _startTime.minute,
    );
    var end = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime.hour,
      _endTime.minute,
    );
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(mobileTimeLogsProvider.notifier)
          .logManualTime(
            phaseId: phaseId,
            activityType: _activity,
            startTime: start,
            endTime: end,
            breakMinutes: _breakMinutes,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppSnackBar.showSuccess(context, context.loc.timeEntryAdded);
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
    final projects = ref.watch(mobileProjectsProvider).asData?.value ?? const [];
    final phaseItems = <DropdownMenuItem<String>>[
      for (final p in projects)
        for (final ph in p.phases)
          DropdownMenuItem(
            value: ph.id,
            child: Text(
              '${p.name} • ${MobilePhaseLocalizer.phaseType(context, ph.type)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
    ];

    if (_selectedPhaseId == null && phaseItems.isNotEmpty) {
      _selectedPhaseId = phaseItems.first.value;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18.w,
        18.h,
        18.w,
        MediaQuery.of(context).viewInsets.bottom + 18.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.manualLabel,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          DropdownButtonFormField<String>(
            initialValue: phaseItems.any((i) => i.value == _selectedPhaseId)
                ? _selectedPhaseId
                : null,
            isExpanded: true,
            items: phaseItems,
            onChanged: (v) => setState(() => _selectedPhaseId = v),
            decoration: InputDecoration(
              labelText: context.loc.phase,
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12.h),
          DropdownButtonFormField<BackendActivityType>(
            initialValue: _activity,
            items: BackendActivityType.values
                .map(
                  (a) => DropdownMenuItem(
                    value: a,
                    child: Text(
                      MobilePhaseLocalizer.phaseType(
                        context,
                        a.serializedName,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _activity = v);
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (picked != null) setState(() => _startTime = picked);
                  },
                  child: Text(_startTime.format(context)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (picked != null) setState(() => _endTime = picked);
                  },
                  child: Text(_endTime.format(context)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text('${context.loc.breakLabel}: $_breakMinutes min'),
              const Spacer(),
              IconButton(
                onPressed: () => setState(
                  () => _breakMinutes = (_breakMinutes - 15).clamp(0, 180),
                ),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              IconButton(
                onPressed: () => setState(
                  () => _breakMinutes = (_breakMinutes + 15).clamp(0, 180),
                ),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: _submitting ? null : _submit,
              text: _submitting ? '...' : context.loc.save,
            ),
          ),
        ],
      ),
    );
  }
}
