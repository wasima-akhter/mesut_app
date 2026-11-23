import '../../domain/entities/create_project_entity.dart';

class CreateProjectState {
  final int currentStep;
  final bool isSubmitting;
  final String? errorMessage;

  // Step 1: General & Customer
  final String projectName;
  final bool isExistingClient;
  final String selectedClientId;
  final String clientName;
  final String clientCategory;
  final String priority;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String contactRole;

  // Step 2: Site Location & Status
  final String street;
  final String postalCode;
  final String city;
  final double lat;
  final double lng;
  final String placeLabel;
  final String siteManagerId;
  final String phaseType;
  final String status;

  // Step 3: Scaffold Specs & Schedule
  final double scaffoldArea;
  final double scaffoldHeight;
  final String scaffoldType;
  final List<CreateScheduleItem> scheduleData;
  final String noteCategory;
  final String noteContent;
  final List<PhotoPayload> photos;

  const CreateProjectState({
    this.currentStep = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.projectName = '',
    this.isExistingClient = true,
    this.selectedClientId = '',
    this.clientName = '',
    this.clientCategory = 'COMMERCIAL',
    this.priority = 'MEDIUM',
    this.contactName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.contactRole = '',
    this.street = '',
    this.postalCode = '',
    this.city = '',
    this.lat = 50.9082,
    this.lng = 6.9723,
    this.placeLabel = '',
    this.siteManagerId = '',
    this.phaseType = 'ERECTION',
    this.status = 'ENQUIRY',
    this.scaffoldArea = 0.0,
    this.scaffoldHeight = 0.0,
    this.scaffoldType = '',
    this.scheduleData = const [],
    this.noteCategory = 'SITE_ACCESS',
    this.noteContent = '',
    this.photos = const [],
  });

  CreateProjectState copyWith({
    int? currentStep,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
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
    String? street,
    String? postalCode,
    String? city,
    double? lat,
    double? lng,
    String? placeLabel,
    String? siteManagerId,
    String? phaseType,
    String? status,
    double? scaffoldArea,
    double? scaffoldHeight,
    String? scaffoldType,
    List<CreateScheduleItem>? scheduleData,
    String? noteCategory,
    String? noteContent,
    List<PhotoPayload>? photos,
  }) {
    return CreateProjectState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      projectName: projectName ?? this.projectName,
      isExistingClient: isExistingClient ?? this.isExistingClient,
      selectedClientId: selectedClientId ?? this.selectedClientId,
      clientName: clientName ?? this.clientName,
      clientCategory: clientCategory ?? this.clientCategory,
      priority: priority ?? this.priority,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      contactRole: contactRole ?? this.contactRole,
      street: street ?? this.street,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      placeLabel: placeLabel ?? this.placeLabel,
      siteManagerId: siteManagerId ?? this.siteManagerId,
      phaseType: phaseType ?? this.phaseType,
      status: status ?? this.status,
      scaffoldArea: scaffoldArea ?? this.scaffoldArea,
      scaffoldHeight: scaffoldHeight ?? this.scaffoldHeight,
      scaffoldType: scaffoldType ?? this.scaffoldType,
      scheduleData: scheduleData ?? this.scheduleData,
      noteCategory: noteCategory ?? this.noteCategory,
      noteContent: noteContent ?? this.noteContent,
      photos: photos ?? this.photos,
    );
  }
}
