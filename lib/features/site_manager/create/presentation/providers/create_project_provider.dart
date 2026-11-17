import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/helpers/device_location_helper.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/services/address_resolver_service.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../map/services/location_service.dart';
import '../../../offline_sync/models/site_manager_sync_action.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../projects/presentation/providers/site_manager_projects_provider.dart';
import '../../data/repositories/create_project_repository_impl.dart';
import '../../domain/entities/create_project_entity.dart';
import '../../domain/repositories/create_project_repository.dart';
import 'create_project_state.dart';

export 'create_project_state.dart';

class CreateProjectNotifier extends Notifier<CreateProjectState> {
  CreateProjectRepository get _repository =>
      ref.read(createProjectRepositoryProvider);

  @override
  CreateProjectState build() {
    final user = ref.watch(authProvider).user;
    final now = DateTime.now();

    final initialSchedules = [
      CreateScheduleItem(
        type: 'erection',
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
        durationDays: 3,
      ),
      CreateScheduleItem(
        type: 'dismantling',
        startDate: now.add(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 17)),
        durationDays: 3,
      ),
    ];

    return CreateProjectState(
      siteManagerId: user?.id ?? '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      scheduleData: initialSchedules,
    );
  }

  void setStep(int step) {
    if (step < 0 || step > 2) return;
    state = state.copyWith(currentStep: step);
  }

  void updateStepOne({
    String? projectName,
    bool? isExistingClient,
    String? selectedClientId,
    String? clientName,
    String? clientCategory,
    String? priority,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? contactRole,
  }) {
    state = state.copyWith(
      projectName: projectName,
      isExistingClient: isExistingClient,
      selectedClientId: selectedClientId,
      clientName: clientName,
      clientCategory: clientCategory,
      priority: priority,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      contactRole: contactRole,
    );
  }

  void updateStepTwo({
    String? street,
    String? postalCode,
    String? city,
    double? lat,
    double? lng,
    String? placeLabel,
    String? siteManagerId,
    String? phaseType,
    String? status,
  }) {
    state = state.copyWith(
      street: street,
      postalCode: postalCode,
      city: city,
      lat: lat,
      lng: lng,
      placeLabel: placeLabel,
      siteManagerId: siteManagerId,
      phaseType: phaseType,
      status: status,
    );
  }

  void updateStepThree({
    double? scaffoldArea,
    double? scaffoldHeight,
    String? scaffoldType,
    String? noteCategory,
    String? noteContent,
    List<PhotoPayload>? photos,
  }) {
    state = state.copyWith(
      scaffoldArea: scaffoldArea,
      scaffoldHeight: scaffoldHeight,
      scaffoldType: scaffoldType,
      noteCategory: noteCategory,
      noteContent: noteContent,
      photos: photos,
    );
  }

  void addScheduleItem({String type = 'erection'}) {
    final now = DateTime.now();
    final item = CreateScheduleItem(
      type: type,
      startDate: now,
      endDate: now.add(const Duration(days: 2)),
      durationDays: 2,
    );
    state = state.copyWith(scheduleData: [...state.scheduleData, item]);
  }

  void removeScheduleItem(int index) {
    if (index < 0 || index >= state.scheduleData.length) return;
    final updated = List<CreateScheduleItem>.from(state.scheduleData)
      ..removeAt(index);
    state = state.copyWith(scheduleData: updated);
  }

  void updateScheduleItem(int index, CreateScheduleItem item) {
    if (index < 0 || index >= state.scheduleData.length) return;
    final updated = List<CreateScheduleItem>.from(state.scheduleData);
    updated[index] = item;
    state = state.copyWith(scheduleData: updated);
  }

  void setCoordinates({
    required double lat,
    required double lng,
    String? placeLabel,
  }) {
    final resolved = placeLabel ?? AddressResolverService.resolveSync(lat, lng);
    state = state.copyWith(
      lat: lat,
      lng: lng,
      placeLabel: resolved,
    );
  }

  Future<bool> useCurrentLocation() async {
    const locationService = LocationService();
    var hasPermission = await locationService.hasLocationPermission();
    if (!hasPermission) {
      hasPermission = await locationService.requestLocationPermission();
    }
    if (!hasPermission) return false;

    final coord = await locationService.getCurrentLocation();
    if (coord != null) {
      final resolved = AddressResolverService.resolveSync(
        coord.latitude,
        coord.longitude,
      );
      state = state.copyWith(
        lat: coord.latitude,
        lng: coord.longitude,
        placeLabel: resolved,
      );
      return true;
    }
    return false;
  }

  Future<bool> submit(BuildContext context) async {
    if (state.projectName.trim().isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseEnterProjectName);
      return false;
    }

    if (state.isExistingClient && state.selectedClientId.trim().isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseSelectExistingCustomer);
      return false;
    }

    if (!state.isExistingClient && state.clientName.trim().isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseEnterCustomerName);
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    final resolvedLabel = state.placeLabel.trim().isNotEmpty
        ? state.placeLabel.trim()
        : AddressResolverService.resolveSync(state.lat, state.lng);

    final payload = CreateProjectPayload(
      name: state.projectName.trim(),
      lat: state.lat,
      lng: state.lng,
      placeLabel: resolvedLabel.isNotEmpty ? resolvedLabel : null,
      scaffoldSpecification: ScaffoldSpecification(
        area: state.scaffoldArea > 0 ? state.scaffoldArea : 100.0,
        height: state.scaffoldHeight > 0 ? state.scaffoldHeight : 10.0,
        type: state.scaffoldType.isNotEmpty ? state.scaffoldType : 'Façade',
      ),
      priority: state.priority,
      phaseType: state.phaseType,
      status: state.status,
      siteManagerId: state.siteManagerId.isNotEmpty
          ? state.siteManagerId
          : null,
      customer: CustomerPayload(
        mode: state.isExistingClient ? 'EXISTING' : 'NEW',
        customerId: state.isExistingClient ? state.selectedClientId : null,
        name: !state.isExistingClient ? state.clientName : null,
        category: !state.isExistingClient ? state.clientCategory : null,
      ),
      contact: ContactPayload(
        name: state.contactName.trim().isNotEmpty ? state.contactName.trim() : 'Lead',
        phone: state.contactPhone.trim().isNotEmpty ? state.contactPhone.trim() : '+491701234567',
        email: state.contactEmail.trim().isNotEmpty ? state.contactEmail.trim() : 'contact@example.com',
        role: state.contactRole.trim().isNotEmpty ? state.contactRole.trim() : 'Project lead',
      ),
      scheduleData: state.scheduleData.isNotEmpty
          ? state.scheduleData
          : [
              CreateScheduleItem(
                type: 'erection',
                startDate: DateTime.now(),
                endDate: DateTime.now().add(const Duration(days: 3)),
                durationDays: 3,
              ),
            ],
      note: state.noteContent.trim().isNotEmpty
          ? NotePayload(
              category: state.noteCategory,
              content: state.noteContent.trim(),
            )
          : null,
      photos: state.photos,
    );

    try {
      await _repository.createProject(payload);
      state = state.copyWith(isSubmitting: false);
      ref
          .read(siteManagerProjectsProvider.notifier)
          .loadInitial(isRefresh: true);
      AppSnackBar.showSuccess(context, context.loc.projectCreatedSuccess);
      return true;
    } catch (_) {
      final action = SiteManagerSyncAction(
        id: 'create_proj_${DateTime.now().millisecondsSinceEpoch}',
        actionType: SiteManagerSyncActionType.createProject,
        endpoint: ApiConstants.mobileProjects,
        httpMethod: 'POST',
        displayTitle: 'Project: ${payload.name}',
        createdAt: DateTime.now(),
        payload: payload.toJson(),
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);
      state = state.copyWith(isSubmitting: false);
      AppSnackBar.showSuccess(context, context.loc.savedOffline);
      return true;
    }
  }
}

final createProjectProvider =
    NotifierProvider<CreateProjectNotifier, CreateProjectState>(
      CreateProjectNotifier.new,
    );
