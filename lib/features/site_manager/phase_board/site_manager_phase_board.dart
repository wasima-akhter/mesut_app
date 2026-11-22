import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/app_error_resolver.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/pending_refetch_controller.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../../../core/widgets/states/app_empty_widget.dart';
import 'domain/entities/mobile_phase_entity.dart';
import 'presentation/providers/mobile_phase_provider.dart';
import 'models/backend_phase_status.dart';
import 'widgets/site_manager_phase_card.dart';
import 'widgets/site_manager_phase_status_sheet.dart';
import 'widgets/site_manager_phase_tabs.dart';

class SiteManagerPhaseBoardPage extends ConsumerStatefulWidget {
  const SiteManagerPhaseBoardPage({super.key});

  @override
  ConsumerState<SiteManagerPhaseBoardPage> createState() =>
      _SiteManagerPhaseBoardPageState();
}

class _SiteManagerPhaseBoardPageState
    extends ConsumerState<SiteManagerPhaseBoardPage> {
  String _selectedColumn = 'ALL';
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpdateStatus(MobilePhaseEntity phase) async {
    final chosen = await SiteManagerPhaseStatusSheet.show(context, phase);
    if (chosen == null || chosen == phase.status) return;

    try {
      await ref
          .read(mobilePhasesProvider.notifier)
          .updateStatus(phase.id, chosen);
      if (!mounted) return;
      final oldStatusName =
          BackendPhaseStatus.fromString(phase.status).localizedName(context);
      final newStatusName =
          BackendPhaseStatus.fromString(chosen).localizedName(context);
      AppSnackBar.showSuccess(
        context,
        context.loc.phaseChanged(oldStatusName, newStatusName),
      );
    } catch (e) {
      if (!mounted) return;
      final lang = ref.read(appLanguageProvider).code;
      final resolved = AppErrorResolver.resolve(e, languageCode: lang);
      AppSnackBar.showError(context, resolved.displayMessage);
    }
  }

  void _onTabSelected(String code) {
    setState(() => _selectedColumn = code);
    ref.read(mobilePhasesProvider.notifier).setColumn(code);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final phasesAsync = ref.watch(mobilePhasesProvider);

    final tabs = <(String, String)>[
      ('ALL', context.loc.mapFilterAll),
      ('ENQUIRY', context.loc.enquiry),
      ('ERECTION', context.loc.erectionPhase),
      ('STANDING', context.loc.standing),
      ('DISMANTLING', context.loc.dismantlingPhase),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 0),
              child: _buildHeader(),
            ),
            if (_isSearchOpen)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: context.loc.search,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                  ),
                  onChanged: (q) => setState(() => _searchQuery = q.trim()),
                ),
              ),
            SizedBox(height: 12.h),
            SiteManagerPhaseTabs(
              tabs: tabs,
              selectedColumn: _selectedColumn,
              onTabSelected: _onTabSelected,
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: PendingPollEffect(
                hasPending: anyLocalizationPending(
                  (phasesAsync.asData?.value ?? const [])
                      .map((p) => p.localization),
                ),
                onPoll: () => ref
                    .read(mobilePhasesProvider.notifier)
                    .refresh(column: _selectedColumn),
                child: RefreshIndicator(
                  onRefresh: () => ref
                      .read(mobilePhasesProvider.notifier)
                      .refresh(column: _selectedColumn),
                  child: phasesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.loc.somethingWentWrong),
                        SizedBox(height: 10.h),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(mobilePhasesProvider.notifier)
                              .refresh(column: _selectedColumn),
                          child: Text(context.loc.mapRetry),
                        ),
                      ],
                    ),
                  ),
                  data: (phases) {
                    var visible = phases;
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      visible = visible
                          .where(
                            (p) =>
                                p.project.name.toLowerCase().contains(q) ||
                                p.project.address.toLowerCase().contains(q) ||
                                p.type.toLowerCase().contains(q) ||
                                p.status.toLowerCase().contains(q),
                          )
                          .toList();
                    }

                    if (visible.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: 72.h),
                          AppEmptyWidget(
                            icon: Icons.view_kanban_outlined,
                            title: context.loc.noPhasesFound,
                            onRetry: () => ref
                                .read(mobilePhasesProvider.notifier)
                                .refresh(column: _selectedColumn),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 20.h),
                      itemCount: visible.length,
                      itemBuilder: (_, index) {
                        final phase = visible[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: SiteManagerPhaseCard(
                            phase: phase,
                            onTapProject: () => context.push(
                              RouteConstants.siteManagerProjectDetail,
                              extra: phase.project.id,
                            ),
                            onUpdateStatus: () => _pickAndUpdateStatus(phase),
                          ),
                        );
                      },
                    );
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

  Widget _buildHeader() {
    return Row(
      children: [
        const AppBackButton(),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            context.loc.phaseBoard,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        AppIconButton.circle(
          iconData: _isSearchOpen ? Icons.close : Icons.search_rounded,
          onPressed: () {
            setState(() {
              _isSearchOpen = !_isSearchOpen;
              if (!_isSearchOpen) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
          borderColor: AppColors.border,
          size: 38.w,
          iconSize: 18.sp,
        ),
        SizedBox(width: 8.w),
        AppIconButton.circle(
          iconData: Icons.refresh_rounded,
          onPressed: () => ref
              .read(mobilePhasesProvider.notifier)
              .refresh(column: _selectedColumn),
          borderColor: AppColors.border,
          size: 38.w,
          iconSize: 18.sp,
        ),
      ],
    );
  }
}
