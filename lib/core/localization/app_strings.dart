class AppStrings {
  final Map<String, String> _strings;

  const AppStrings(this._strings);

  static AppStrings current = const AppStrings({});

  String get(String key, String fallback, [Map<String, String>? params]) {
    String value = _strings[key] ?? fallback;
    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  // ============================================================
  // COMMON
  // ============================================================
  String get ok => get('common.ok', 'OK');
  String get call => get('common.call', 'Call');
  String get home => get('common.home', 'Home');
  String get map => get('common.map', 'Map');
  String get cancel => get('common.cancel', 'Cancel');
  String get save => get('common.save', 'Save');
  String get project => get('common.project', 'Project');
  String get delete => get('common.delete', 'Delete');
  String get edit => get('common.edit', 'Edit');
  String get close => get('common.close', 'Close');
  String get back => get('common.back', 'Back');
  String get search => get('common.search', 'Search');
  String get filter => get('common.filter', 'Filter');
  String get resetAll => get('common.resetAll', 'Reset All');
  String get applyFilters => get('common.applyFilters', 'Apply Filters');
  String get previous => get('common.previous', 'Previous');
  String get next => get('common.next', 'Next');
  String get loading => get('common.loading', 'Loading...');
  String get error => get('common.error', 'Error');
  String get success => get('common.success', 'Success');
  String get retry => get('common.retry', 'Retry');
  String get confirm => get('common.confirm', 'Confirm');
  String get settings => get('common.settings', 'Settings');
  String get download => get('common.download', 'Download');
  String get upload => get('common.upload', 'Upload');
  String get all => get('common.all', 'All');
  String get today => get('common.today', 'Today');
  String get thisWeek => get('common.thisWeek', 'This Week');
  String get thisMonth => get('common.thisMonth', 'This Month');
  String get viewAll => get('common.viewAll', 'View All');
  String get noData => get('common.noData', 'No data available');
  String get date => get('common.date', 'Date');
  String get time => get('common.time', 'Time');
  String get duration => get('common.duration', 'Duration');
  String get hrsShort => get('common.hrsShort', 'hrs');
  String durationDays(String count) =>
      get('common.durationDays', '{count} days', {'count': count});
  String durationHours(String count) =>
      get('common.durationHours', '{count} hours', {'count': count});
  String get searchCity => get('common.searchCity', 'Search City');
  String get noProjectsFound =>
      get('common.noProjectsFound', 'No projects found');
  String get synced => get('common.synced', 'Synced');
  String get pending => get('common.pending', 'Pending');
  String get high => get('common.high', 'High');
  String get medium => get('common.medium', 'Medium');
  String get low => get('common.low', 'Low');
  String get open => get('common.open', 'Open');
  String get completed => get('common.completed', 'Completed');
  String get inProgress => get('common.inProgress', 'In Progress');
  String get notStarted => get('common.notStarted', 'Not Started');
  String get postponed => get('common.postponed', 'Postponed');
  String get onHold => get('common.onHold', 'On Hold');
  String get commercial => get('common.commercial', 'Commercial');
  String get private => get('common.private', 'Private');

  // ============================================================
  // AUTH
  // ============================================================
  String get welcomeBack => get('auth.welcomeBack', 'Welcome Back');
  String get signInToAccount =>
      get('auth.signInToAccount', 'Sign in to continue to your account');
  String get workEmail => get('auth.workEmail', 'Work Email');
  String get enterEmail => get('auth.enterEmail', 'Enter your work email');
  String get password => get('auth.password', 'Password');
  String get enterPassword => get('auth.enterPassword', 'Enter your password');
  String get rememberMe => get('auth.rememberMe', 'Remember me');
  String get forgotPassword => get('auth.forgotPassword', 'Forgot Password?');
  String get forgotPasswordTitle =>
      get('auth.forgotPasswordTitle', 'Forgot Password');
  String get forgotPasswordSubtitle => get(
    'auth.forgotPasswordSubtitle',
    'Enter your email address to receive a verification code to reset your password.',
  );
  String get signIn => get('auth.signIn', 'Sign In');
  String get dontHaveAccount =>
      get('auth.dontHaveAccount', "Don't have an account? ");
  String get signUp => get('auth.signUp', 'Sign Up');
  String get createAccount => get('auth.createAccount', 'Create Account');
  String get startJourney => get(
    'auth.startJourney',
    'Fill in the details below to create your account.',
  );
  String get fullName => get('auth.fullName', 'Full Name');
  String get enterFullName => get('auth.enterFullName', 'Enter your full name');
  String get phone => get('auth.phone', 'Phone Number');
  String get enterPhone => get('auth.enterPhone', 'Enter your phone number');
  String get createPassword => get('auth.createPassword', 'Create Password');
  String get confirmPassword => get('auth.confirmPassword', 'Confirm Password');
  String get reenterPassword =>
      get('auth.reenterPassword', 'Confirm your password');
  String get alreadyHaveAccount =>
      get('auth.alreadyHaveAccount', 'Already have an account? ');
  String get resetPassword => get('auth.resetPassword', 'Reset Password');
  String get resetPasswordSubtitle => get(
    'auth.resetPasswordSubtitle',
    "Enter your new password below. Make sure it's secure and easy for you to remember.",
  );
  String get sendResetLink =>
      get('auth.sendResetLink', 'Send Verification Code');
  String get backToSignIn => get('auth.backToSignIn', 'Back to Sign In');
  String get enterOtp => get('auth.enterOtp', 'Enter OTP Code');
  String enterOtpSubtitle(String email) => get(
    'auth.enterOtpSubtitle',
    'We have sent a 4-digit verification code to {email}',
    {'email': email},
  );
  String get verifyCode => get('auth.verifyCode', 'Verify Code');
  String get resendCode => get('auth.resendCode', 'Resend Code');
  String get didNotReceiveCode =>
      get('auth.didNotReceiveCode', "Didn't receive the code? ");
  String get newPassword => get('auth.newPassword', 'New Password');
  String get newPasswordSubtitle =>
      get('auth.newPasswordSubtitle', 'Enter your new password below.');
  String get confirmNewPassword =>
      get('auth.confirmNewPassword', 'Confirm New Password');
  String get updatePassword => get('auth.updatePassword', 'Save New Password');
  String get passwordResetSuccess =>
      get('auth.passwordResetSuccess', 'Password Reset Successful');
  String get passwordResetSuccessSubtitle => get(
    'auth.passwordResetSuccessSubtitle',
    'Your password has been reset successfully. Please log in with your new password.',
  );
  String get emailRequired => get('auth.emailRequired', 'Email is required');
  String get invalidEmail =>
      get('auth.invalidEmail', 'Please enter a valid email address');
  String get passwordRequired =>
      get('auth.passwordRequired', 'Password is required');
  String get passwordTooShort =>
      get('auth.passwordTooShort', 'Password must be at least 6 characters');
  String get passwordConfirmRequired =>
      get('auth.passwordConfirmRequired', 'Please confirm your password');
  String get passwordsDoNotMatch =>
      get('auth.passwordsDoNotMatch', 'Passwords do not match');
  String get nameRequired => get('auth.nameRequired', 'Name is required');
  String get phoneRequired =>
      get('auth.phoneRequired', 'Phone number is required');
  String get otpRequired =>
      get('auth.otpRequired', 'Please enter the full 4-digit code');
  String get logout => get('auth.logout', 'Log Out');
  String get logoutTitle => get('auth.logoutTitle', 'Log Out?');
  String get logoutConfirmation => get(
    'auth.logoutConfirmation',
    'Are you sure you want to log out of your account?',
  );
  String get loggedOutSuccess =>
      get('auth.loggedOutSuccess', 'Logged out successfully');
  String get enterSiteInstructions => get(
    'auth.enterSiteInstructions',
    'Enter site instructions, gate codes, or client requests...',
  );

  // ============================================================
  // NAVIGATION
  // ============================================================
  String get navHome => get('nav.home', 'Home');
  String get navMyPlan => get('nav.myPlan', 'My Plan');
  String get navTime => get('nav.time', 'Time');
  String get navProfile => get('nav.profile', 'Profile');
  String get navProjects => get('nav.projects', 'Projects');
  String get navMap => get('nav.map', 'Map');
  String get navMore => get('nav.more', 'More');
  String get navTimer => get('nav.timer', 'Timer');
  String get navSchedule => get('nav.schedule', 'Schedule');
  String get navWorkforce => get('nav.workforce', 'Workforce');
  String get navSettings => get('nav.settings', 'Settings');

  // ============================================================
  // ONBOARDING & ENTRY
  // ============================================================
  String get onboarding1Title =>
      get('entry.onboarding1Title', 'Smart Workforce & Scaffold Management');
  String get onboarding1Subtitle => get(
    'entry.onboarding1Subtitle',
    'Track site operations, assign tasks to field crew, and monitor project stages seamlessly.',
  );
  String get onboarding2Title =>
      get('entry.onboarding2Title', 'Real-time Time Tracking & Verification');
  String get onboarding2Subtitle => get(
    'entry.onboarding2Subtitle',
    'Accurately log working hours, pauses, and overtime on active construction sites.',
  );
  String get onboarding3Title =>
      get('entry.onboarding3Title', 'Site Safety & Digital Inspections');
  String get onboarding3Subtitle => get(
    'entry.onboarding3Subtitle',
    'Perform routine scaffold safety audits, capture photos, and ensure full compliance.',
  );
  String get chooseLanguageTitle =>
      get('entry.chooseLanguageTitle', 'Choose Your Language');
  String get chooseLanguageSubtitle => get(
    'entry.chooseLanguageSubtitle',
    'Select your preferred language to customize your app experience.',
  );
  String get continueAction => get('entry.continueAction', 'Continue');
  String get getStarted => get('entry.getStarted', 'Get Started');
  String get skip => get('entry.skip', 'Skip');

  // ============================================================
  // LEGAL & PASSWORD
  // ============================================================
  String get termsAndConditions =>
      get('legal.termsAndConditions', 'Terms & Conditions');
  String get privacyPolicy => get('legal.privacyPolicy', 'Privacy Policy');
  String get legalNotice => get('legal.legalNotice', 'Legal Information');
  String lastUpdated(String date) =>
      get('legal.lastUpdated', 'Last updated: {date}', {'date': date});
  String get agreeAndContinue =>
      get('legal.agreeAndContinue', 'I Agree & Continue');
  String get changePassword => get('legal.changePassword', 'Change Password');
  String get currentPassword =>
      get('legal.currentPassword', 'Current Password');
  String get enterCurrentPassword =>
      get('legal.enterCurrentPassword', 'Enter your current password');
  String get passwordChangedSuccess =>
      get('legal.passwordChangedSuccess', 'Password changed successfully');

  // ============================================================
  // PROFILE
  // ============================================================
  String get profile => get('profile.profile', 'Profile');
  String get editProfile => get('profile.editProfile', 'Edit Profile');
  String get contactInformation =>
      get('profile.contactInformation', 'Contact Information');
  String get role => get('profile.role', 'Role');
  String get company => get('profile.company', 'Company');
  String get language => get('profile.language', 'Language');
  String get selectLanguage => get('profile.selectLanguage', 'Select Language');
  String get english => get('profile.english', 'English');
  String get german => get('profile.german', 'Deutsch');
  String get appVersion => get('profile.appVersion', 'App Version');
  String get personalInfo =>
      get('profile.personalInfo', 'Personal Information');
  String get email => get('profile.email', 'Email');
  String get profilePhone => get('profile.phone', 'Phone');
  String get address => get('profile.address', 'Address');
  String get saveChanges => get('profile.saveChanges', 'Save Changes');
  String get profileUpdatedSuccess =>
      get('profile.profileUpdatedSuccess', 'Profile updated successfully');
  String get overview => get('profile.overview', 'Overview');
  String get totalHoursLogged =>
      get('profile.totalHoursLogged', 'Total Hours Logged');
  String get assignedProjects =>
      get('profile.assignedProjects', 'Assigned Projects');
  String get completedTasksCount =>
      get('profile.completedTasks', 'Completed Tasks');

  // ============================================================
  // EMPLOYEE
  // ============================================================
  String greeting(String name) =>
      get('employee.greeting', 'Hello, {name}', {'name': name});
  String get employeeRole => get('employee.employeeRole', 'Field Employee');
  String get currentTask => get('employee.currentTask', 'Current Task');
  String get activeTimer => get('employee.activeTimer', 'Active Timer');
  String startedAt(String time) =>
      get('employee.startedAt', 'Started at {time}', {'time': time});
  String get timerRunning =>
      get('employee.timerRunning', 'Timer is currently running');
  String get startNewTimer => get('employee.startNewTimer', 'Start New Timer');
  String get stopTimer => get('employee.stopTimer', 'Stop Timer');
  String get pauseBreak => get('employee.pauseBreak', 'Pause Break');
  String get resumeWork => get('employee.resumeWork', 'Resume Work');
  String get finishWork => get('employee.finishWork', 'Finish Work');
  String get addTimeEntry => get('employee.addTimeEntry', 'Add Time Entry');
  String get saveEntry => get('employee.saveEntry', 'Save Entry');
  String get recentLogs => get('employee.recentLogs', 'Recent Logs');
  String get mySchedule => get('employee.mySchedule', 'My Schedule');
  String get noScheduleToday =>
      get('employee.noScheduleToday', 'No schedule for today');
  String get upcomingTasks => get('employee.upcomingTasks', 'Upcoming Tasks');
  String get scaffoldErection =>
      get('employee.scaffoldErection', 'Scaffold Erection');
  String get scaffoldDismantling =>
      get('employee.scaffoldDismantling', 'Scaffold Dismantling');
  String get standingScaffold =>
      get('employee.standingScaffold', 'Standing Scaffold');
  String get otherActivity => get('employee.otherActivity', 'Other Activity');
  String get breakTime => get('employee.breakTime', 'Break Time');
  String get startTime => get('employee.startTime', 'Start Time');
  String get endTime => get('employee.endTime', 'End Time');
  String get totalHours => get('employee.totalHours', 'Total Hours');
  String get totalWorkTime => get('employee.totalWorkTime', 'Total Work Time');
  String timerStarted(String activity) => get(
    'employee.timerStarted',
    'Timer started for {activity}',
    {'activity': activity},
  );
  String get timerStopped => get('employee.timerStopped', 'Timer stopped');
  String get entrySaved =>
      get('employee.entrySaved', 'Time entry saved successfully');
  String get workFinished =>
      get('employee.workFinished', 'Work finished and submitted');
  String get assignmentDetail =>
      get('employee.assignmentDetail', 'Assignment Detail');
  String get siteAddress => get('employee.siteAddress', 'Site Address');
  String get siteLead => get('employee.siteLead', 'Site Lead');
  String get client => get('employee.client', 'Client');
  String get plannedDate => get('employee.plannedDate', 'Planned Date');
  String get estimatedDuration =>
      get('employee.estimatedDuration', 'Estimated Duration');
  String get safetyNotes => get('employee.safetyNotes', 'Safety Notes');
  String get checklist => get('employee.checklist', 'Daily Checklist');
  String get completeTask => get('employee.completeTask', 'Complete Task');
  String get timerNotice =>
      get('employee.timerNotice', 'Timer will start from now.');
  String get autoDeductNotice => get(
    'employee.autoDeductNotice',
    'Working time is calculated automatically after deducting the break.',
  );
  String get assignedProject =>
      get('employee.assignedProject', 'Assigned Project');
  String get selectProject => get('employee.selectProject', 'Select project');
  String get activityType => get('employee.activityType', 'Activity Type');
  String get selectActivity =>
      get('employee.selectActivity', 'Select activity');
  String todayTimeLogged(String hours) =>
      get('employee.todayTimeLogged', '{hours} logged today', {'hours': hours});
  String weekProgress(String logged, String total) => get(
    'employee.weekProgress',
    '{logged} of {total} logged this week',
    {'logged': logged, 'total': total},
  );
  String get hoursThisWeek => get('employee.hoursThisWeek', 'Hours this Week');
  String get myPlan => get('employee.myPlan', 'My Plan');
  String get noAssignments =>
      get('employee.noAssignments', 'No assignments found for this date');

  // ============================================================
  // SITE MANAGER
  // ============================================================
  String get siteManagerRole =>
      get('siteManager.siteManagerRole', 'Site Manager');
  String get smOverview => get('siteManager.overview', 'Overview');
  String get smTasks => get('siteManager.tasks', 'Tasks');
  String get tasks => get('siteManager.tasks', 'Tasks');
  String get smPhotos => get('siteManager.photos', 'Photos');
  String get photos => get('siteManager.photos', 'Photos');
  String get smMeasurement => get('siteManager.measurement', 'Measurement');
  String get measurement => get('siteManager.measurement', 'Measurement');
  String get smDates => get('siteManager.dates', 'Dates');
  String get dates => get('siteManager.dates', 'Dates');
  String get smNotes => get('siteManager.notes', 'Notes');
  String get notes => get('siteManager.notes', 'Notes');
  String get smHistory => get('siteManager.history', 'History');
  String get history => get('siteManager.history', 'History');
  String get phaseBoard => get('siteManager.phaseBoard', 'Phase Board');
  String get moveTo => get('siteManager.moveTo', 'Move to...');
  String get moveProject => get('siteManager.moveProject', 'Move Project');
  String get projects => get('siteManager.projects', 'Projects');
  String get createProject =>
      get('siteManager.createProject', 'Create Project');
  String get newProject => get('siteManager.newProject', 'New Project');
  String stepOf(int current, int total) => get(
    'siteManager.stepOf',
    'Step {current} of {total}',
    {'current': '$current', 'total': '$total'},
  );
  String get generalAndCustomerInfo =>
      get('siteManager.generalAndCustomerInfo', 'General & Customer Info');
  String get projectName => get('siteManager.projectName', 'Project Name');
  String get enterProjectName =>
      get('siteManager.enterProjectName', 'e.g. Goldstein Complex');
  String get customer => get('siteManager.customer', 'Customer');
  String get existingClient =>
      get('siteManager.existingClient', 'Existing Client');
  String get newClient => get('siteManager.newClient', 'New Client');
  String get selectClient => get('siteManager.selectClient', 'Select client');
  String get priority => get('siteManager.priority', 'Priority');
  String get contactPerson =>
      get('siteManager.contactPerson', 'Contact Person');
  String get siteLocationAndStatus =>
      get('siteManager.siteLocationAndStatus', 'Site Location & Status');
  String get smSiteAddress => get('siteManager.siteAddress', 'Site Address');
  String get streetAndNo => get('siteManager.streetAndNo', 'Street & No');
  String get postalCode => get('siteManager.postalCode', 'Postal Code');
  String get city => get('siteManager.city', 'City');
  String get manager => get('siteManager.manager', 'Site Manager');
  String get selectManager =>
      get('siteManager.selectManager', 'Select site manager');
  String get operationalStatus =>
      get('siteManager.operationalStatus', 'Operational Status');
  String get workflowStatus =>
      get('siteManager.workflowStatus', 'Workflow Status');
  String get projectPhase => get('siteManager.projectPhase', 'Project Phase');
  String get scaffoldSpecsAndSchedule =>
      get('siteManager.scaffoldSpecsAndSchedule', 'Scaffold Specs & Schedule');
  String get estimatedArea =>
      get('siteManager.estimatedArea', 'Estimated Area (m²)');
  String get erectionSchedule =>
      get('siteManager.erectionSchedule', 'Erection Schedule');
  String get dismantlingSchedule =>
      get('siteManager.dismantlingSchedule', 'Dismantling Schedule');
  String get startDate => get('siteManager.startDate', 'Start date');
  String get teardownDate => get('siteManager.teardownDate', 'Teardown Date');
  String get planned => get('siteManager.planned', 'Planned');
  String get running => get('siteManager.running', 'Running');
  String get plannedDateLabel => get('siteManager.plannedDate', 'Planned date');
  String get endDate => get('siteManager.endDate', 'End date');
  String get safetyInspection =>
      get('siteManager.safetyInspection', 'Safety Inspection');
  String get nextDueDate => get('siteManager.nextDueDate', 'Next Due Date');
  String nextSafetyInspection(String date) => get(
    'siteManager.nextSafetyInspection',
    'Next Safety Inspection: {date}',
    {
      'date': date,
      'duration': date,
    },
  );
  String get siteAccessAndPhotos =>
      get('siteManager.siteAccessAndPhotos', 'Site Access & Photos');
  String get noteCategory => get('siteManager.noteCategory', 'Note Category');
  String get siteAccess => get('siteManager.siteAccess', 'Site Access');
  String get customerRequest =>
      get('siteManager.customerRequest', 'Customer Request');
  String get openPoints => get('siteManager.openPoints', 'Open Points');
  String get agreements => get('siteManager.agreements', 'Agreements');
  String get specialRequirements =>
      get('siteManager.specialRequirements', 'Special Requirements');
  String get localContact => get('siteManager.localContact', 'Local Contact');
  String get general => get('siteManager.general', 'General');
  String get notesDetails => get('siteManager.notesDetails', 'Notes Details');
  String get noteDetails => get('siteManager.notesDetails', 'Notes Details');
  String get uploadPhotos => get('siteManager.uploadPhotos', 'Upload Photos');
  String get uploadFrontSide =>
      get('siteManager.uploadFrontSide', 'Upload Front Side');
  String get uploadFiles => get('siteManager.uploadFiles', 'Upload Files');
  String get takePhoto => get('siteManager.takePhoto', 'Take Photo');
  String get gallery => get('siteManager.gallery', 'Gallery');
  String get files => get('siteManager.files', 'Files');
  String get cover => get('siteManager.cover', 'Cover');
  String get setAsCoverPhoto =>
      get('siteManager.setAsCoverPhoto', 'Set as Cover Photo');
  String get coverPhotoUpdated =>
      get('siteManager.coverPhotoUpdated', 'Cover photo updated');
  String get downloadStarted =>
      get('siteManager.downloadStarted', 'Download started');
  String get pdfPlans => get('siteManager.pdfPlans', 'PDF Plans');
  String get photoViewer => get('siteManager.photoViewer', 'Photo');
  String get projectNotes => get('siteManager.projectNotes', 'Project Notes');
  String get addNote => get('siteManager.addNote', 'Add Note');
  String get editNote => get('siteManager.editNote', 'Edit Project Note');
  String get deleteNote => get('siteManager.deleteNote', 'Delete Note?');
  String get deleteNoteConfirmation => get(
    'siteManager.deleteNoteConfirmation',
    'This note will be permanently removed.',
  );
  String get noProjectNotes =>
      get('siteManager.noProjectNotes', 'No project notes');
  String get noProjectNotesDesc => get(
    'siteManager.noProjectNotesDesc',
    'Add a note to keep important project information.',
  );
  String get saveNotes => get('siteManager.saveNotes', 'Save Notes');
  String get totalCalculatedArea =>
      get('siteManager.totalCalculatedArea', 'Total Calculated Area');
  String get addLine => get('siteManager.addLine', 'Add Line');
  String get position => get('siteManager.position', 'Position');
  String get length => get('siteManager.length', 'Length');
  String get height => get('siteManager.height', 'Height');
  String get quantity => get('siteManager.quantity', 'Quantity');
  String get unit => get('siteManager.unit', 'Unit');
  String get remark => get('siteManager.remark', 'Remark');
  String calculatedArea(String area, String calc) => get(
    'siteManager.calculatedArea',
    'Calculated Area: {area} m² ({calc})',
    {'area': area, 'calc': calc},
  );
  String get saveLineItem => get('siteManager.saveLineItem', 'Save Line Item');
  String get addMeasurementItem =>
      get('siteManager.addMeasurementItem', 'Add Measurement Item');
  String get editMeasurementItem =>
      get('siteManager.editMeasurementItem', 'Edit Measurement Item');
  String lineItem(int index, String position) => get(
    'siteManager.lineItem',
    'Line {index}. {position}',
    {'index': '$index', 'position': position},
  );
  String openTasks(int count) =>
      get('siteManager.openTasks', 'Open ({count})', {'count': '$count'});
  String completedTasks(int count) => get(
    'siteManager.completedTasks',
    'Completed ({count})',
    {'count': '$count'},
  );
  String get addNew => get('siteManager.addNew', 'Add New');
  String get newTask => get('siteManager.newTask', 'New Task');
  String get taskDescription =>
      get('siteManager.taskDescription', 'Task Description');
  String get responsibleEmployee =>
      get('siteManager.responsibleEmployee', 'Responsible Employee');
  String get selectEmployee =>
      get('siteManager.selectEmployee', 'Select Employee');
  String get dueDate => get('siteManager.dueDate', 'Due Date');
  String get createNewTask =>
      get('siteManager.createNewTask', 'Create New Task');
  String get taskDeleted => get('siteManager.taskDeleted', 'Task deleted');
  String get noOpenTasks => get('siteManager.noOpenTasks', 'No open tasks');
  String get noCompletedTasks =>
      get('siteManager.noCompletedTasks', 'No completed tasks');
  String get allTasksCompleted =>
      get('siteManager.allTasksCompleted', 'All tasks have been completed.');
  String get completedTasksAppearHere => get(
    'siteManager.completedTasksAppearHere',
    'Completed tasks will appear here.',
  );
  String dueOn(String date) =>
      get('siteManager.dueOn', 'Due {date}', {'date': date});
  String get myTime => get('siteManager.myTime', 'My Time');
  String get siteCrewTime => get('siteManager.siteCrewTime', 'Site Crew Time');
  String get crewBreakdown =>
      get('siteManager.crewBreakdown', 'Crew Breakdown');
  String get totalProjectHours =>
      get('siteManager.totalProjectHours', 'Total Project Hours');
  String get projectHoursLabor =>
      get('siteManager.projectHoursLabor', 'Project Hours & Labor');
  String get hoursLoggedByCrew => get(
    'siteManager.hoursLoggedByCrew',
    'Total hours logged across all assigned employees',
  );
  String get targetBudget =>
      get('siteManager.targetBudget', 'Target Budget');
  String get budgetStatus =>
      get('siteManager.budgetStatus', 'Budget Status');
  String get profitable =>
      get('siteManager.profitable', 'Profitable');
  String profitableUnderBudget(String hours) => get(
    'siteManager.profitableUnderBudget',
    'Profitable ({hours}h under budget)',
    {'hours': hours},
  );
  String get lossRisk =>
      get('siteManager.lossRisk', 'Loss Risk');
  String lossRiskOverBudget(String hours) => get(
    'siteManager.lossRiskOverBudget',
    'Over Budget (+{hours}h)',
    {'hours': hours},
  );
  String budgetConsumedPercent(String percent) => get(
    'siteManager.budgetConsumedPercent',
    '{percent}% of labor budget consumed',
    {'percent': percent},
  );
  String get loggedByAssignedCrew =>
      get('siteManager.loggedByAssignedCrew', 'Logged by Assigned Crew');
  String get hoursByActivity =>
      get('siteManager.hoursByActivity', 'Hours by Activity');
  String get viewTimeLogs =>
      get('siteManager.viewTimeLogs', 'View Detailed Time Logs');
  String get hoursLogged =>
      get('siteManager.hoursLogged', 'Hours Logged');
  String get consumedHours =>
      get('siteManager.consumedHours', 'Consumed Hours');
  String loggedAcrossEmployees(String hours, int count) => get(
    'siteManager.loggedAcrossEmployees',
    '{hours} logged across {count} employees',
    {'hours': hours, 'count': '$count'},
  );
  String get profitabilityHealthy => get(
    'siteManager.profitabilityHealthy',
    'Project Profitability: Healthy',
  );
  String get profitabilityAtRisk => get(
    'siteManager.profitabilityAtRisk',
    'Project Profitability: At Risk',
  );
  String remainingUnderLaborBudget(String hours, String budget) => get(
    'siteManager.remainingUnderLaborBudget',
    '{hours}h remaining under the {budget} labor budget.',
    {'hours': hours, 'budget': budget},
  );
  String exceedingBudgetLimit(String hours, String budget) => get(
    'siteManager.exceedingBudgetLimit',
    '{hours}h exceeding the allocated {budget} target.',
    {'hours': hours, 'budget': budget},
  );
  String get itemizedTimeLogsByCrew => get(
    'siteManager.itemizedTimeLogsByCrew',
    'Itemized Time Logs by Crew',
  );
  String primaryTask(String task) => get(
    'siteManager.primaryTask',
    'Primary task: {task}',
    {'task': task},
  );
  String get scaffolder => get('siteManager.scaffolder', 'Scaffolder');
  String get leadScaffolder =>
      get('siteManager.leadScaffolder', 'Lead Scaffolder');
  String get erectionAndAnchoring =>
      get('siteManager.erectionAndAnchoring', 'Erection & Anchoring');
  String get materialHandling =>
      get('siteManager.materialHandling', 'Material Handling');
  String get underBudget => get('siteManager.underBudget', 'Under Budget');
  String get overBudget => get('siteManager.overBudget', 'Over Budget');

  String get smTimeTracking => get('siteManager.timeTracking', 'Time Tracking');
  String get timeTracking => get('siteManager.timeTracking', 'Time Tracking');
  String get addTime => get('siteManager.addTime', 'Add Time');
  String get timeEntry => get('siteManager.timeEntry', 'Time Entry');
  String get workingTime => get('siteManager.workingTime', 'Working time');
  String get employee => get('siteManager.employee', 'Employee');
  String get filterProjects =>
      get('siteManager.filterProjects', 'Filter projects');
  String get customerCategory =>
      get('siteManager.customerCategory', 'Customer Category');
  String get sortBy => get('siteManager.sortBy', 'Sort by');
  String get newest => get('siteManager.newest', 'Newest');
  String get nextInspectionDate =>
      get('siteManager.nextInspectionDate', 'Next inspection date');
  String get projectNameAz =>
      get('siteManager.projectNameAz', 'Project name (a-z)');
  String get callClient => get('siteManager.callClient', 'Call Client');
  String get mailClient => get('siteManager.mailClient', 'Mail Client');
  String get navigation => get('siteManager.navigation', 'Navigation');
  String get scaffoldSpecification =>
      get('siteManager.scaffoldSpecification', 'Scaffold Specification');
  String get scaffoldArea => get('siteManager.scaffoldArea', 'Scaffold area');
  String get scaffoldType => get('siteManager.scaffoldType', 'Scaffold Type');
  String get buildingHeight =>
      get('siteManager.buildingHeight', 'Building height');
  String get scheduleAndDuration =>
      get('siteManager.scheduleAndDuration', 'Schedule & Duration');
  String get changesNotice => get(
    'siteManager.changesNotice',
    'Changes here automatically update Calendar and Daily Planning.',
  );
  String get inspectionCompleted =>
      get('siteManager.inspectionCompleted', '✓ Inspection Completed');
  String get markAsComplete =>
      get('siteManager.markAsComplete', 'Mark as Complete');
  String get scheduleChangesSaved =>
      get('siteManager.scheduleChangesSaved', 'Schedule changes saved');
  String get route => get('siteManager.route', 'Route');
  String get openAction => get('siteManager.open', 'Open');
  String get callingContact =>
      get('siteManager.callingContact', 'Calling project contact...');
  String get openingEmail =>
      get('siteManager.openingEmail', 'Opening project email...');
  String get projectOpened =>
      get('siteManager.projectOpened', 'Project opened');
  String get editProjectDetails =>
      get('siteManager.editProjectDetails', 'Edit Project Details');
  String get contactName => get('siteManager.contactName', 'Contact Name');
  String get phoneNumber => get('siteManager.phoneNumber', 'Phone Number');
  String get smEmail => get('siteManager.email', 'Email');
  String get pleaseEnterProjectName =>
      get('siteManager.pleaseEnterProjectName', 'Please enter a project name.');
  String get pleaseEnterSiteAddress => get(
    'siteManager.pleaseEnterSiteAddress',
    'Please enter the site address.',
  );
  String get pleaseEnterCity =>
      get('siteManager.pleaseEnterCity', 'Please enter the city.');
  String get pleaseEnterContactName =>
      get('siteManager.pleaseEnterContactName', 'Please enter contact name.');
  String get pleaseEnterPhone =>
      get('siteManager.pleaseEnterPhone', 'Please enter phone number.');
  String get pleaseEnterEmail =>
      get('siteManager.pleaseEnterEmail', 'Please enter email.');
  String get pleaseEnterNoteDetails =>
      get('siteManager.pleaseEnterNoteDetails', 'Please enter note details.');
  String get pleaseEnterPosition =>
      get('siteManager.pleaseEnterPosition', 'Please enter a position.');
  String get lengthHeightGreaterThanZero => get(
    'siteManager.lengthHeightGreaterThanZero',
    'Length and height must be greater than 0.',
  );
  String get pleaseEnterTaskDescription => get(
    'siteManager.pleaseEnterTaskDescription',
    'Please enter a task description.',
  );
  String get pleaseSelectEmployee =>
      get('siteManager.pleaseSelectEmployee', 'Please select an employee.');
  String get inspections => get('siteManager.inspections', 'Inspections');
  String get siteInspection =>
      get('siteManager.inspections', 'Site Inspection');
  String get calendar => get('siteManager.calendar', 'Calendar');
  String get survey => get('siteManager.survey', 'Survey');
  String get startSurvey => get('siteManager.startSurvey', 'Start Survey');
  String get completedInspections =>
      get('siteManager.completedInspections', 'Completed Inspections');
  String get scheduleInspection =>
      get('siteManager.scheduleInspection', 'Schedule Inspection');
  String get performInspection =>
      get('siteManager.performInspection', 'Perform Inspection');
  String get inspectionDetails =>
      get('siteManager.inspectionDetails', 'Inspection Details');
  String get inspectionPassed =>
      get('siteManager.inspectionPassed', 'Inspection Passed');
  String get inspectionFailed =>
      get('siteManager.inspectionFailed', 'Inspection Failed');
  String get more => get('siteManager.more', 'More');
  String get totalProjects =>
      get('siteManager.totalProjects', 'Total Projects');
  String get activeSites => get('siteManager.activeSites', 'Active Sites');
  String get teamMembers => get('siteManager.teamMembers', 'Team Members');
  String get smSettings => get('siteManager.settings', 'Settings');
  String get notifications => get('siteManager.notifications', 'Notifications');
  String get helpAndSupport =>
      get('siteManager.helpAndSupport', 'Help & Support');
  String get openProject => get('siteManager.openProject', 'Open Project');
  String get locationPermissionRequired => get(
    'siteManager.locationPermissionRequired',
    'Location Permission Required',
  );
  String get locationPermissionMessage => get(
    'siteManager.locationPermissionMessage',
    'Location access is required to start navigation.',
  );
  String get cameraPermissionRequired =>
      get('siteManager.cameraPermissionRequired', 'Camera Permission Required');
  String get cameraPermissionMessage => get(
    'siteManager.cameraPermissionMessage',
    'Please allow camera access to take a photo.',
  );
  String get photoPermissionRequired =>
      get('siteManager.photoPermissionRequired', 'Photo Permission Required');
  String get photoPermissionMessage => get(
    'siteManager.photoPermissionMessage',
    'Photo library access is required to upload project photos.',
  );
  String filesSelected(int count) => get(
    'siteManager.filesSelected',
    '{count} file(s) selected',
    {'count': '$count'},
  );
  String get projectFilterAll => get('siteManager.projectFilterAll', 'All');
  String get projectFilterActive =>
      get('siteManager.projectFilterActive', 'Active');
  String get projectFilterMyProjects =>
      get('siteManager.projectFilterMyProjects', 'My Projects');
  String get projectFilterThisWeek =>
      get('siteManager.projectFilterThisWeek', 'This Week');
  String get projectFilterInspection =>
      get('siteManager.projectFilterInspection', 'Inspection');
  String get smStandingScaffold =>
      get('siteManager.standingScaffold', 'Standing Scaffold');
  String get frontScaffold =>
      get('siteManager.frontScaffold', 'Front Scaffold');
  String get preconstruction =>
      get('siteManager.preconstruction', 'Preconstruction');
  String get construction => get('siteManager.construction', 'Construction');
  String get completion => get('siteManager.completion', 'Completion');
  String get handover => get('siteManager.handover', 'Handover');
  String get erectionPhase => get('siteManager.erectionPhase', 'Erection');
  String get dismantlingPhase =>
      get('siteManager.dismantlingPhase', 'Dismantling');
  String get prefilledFromEnquiry =>
      get('siteManager.prefilledFromEnquiry', 'Pre-filled from enquiry');
  String get smAppointment => get('siteManager.appointment', 'Appointment');
  String get technicalFieldSurvey =>
      get('siteManager.technicalFieldSurvey', 'Technical Field Survey');
  String get sideScaffold => get('siteManager.sideScaffold', 'Side Scaffold');
  String get fullScaffold => get('siteManager.fullScaffold', 'Full Scaffold');
  String get estAreaM2 => get('siteManager.estAreaM2', 'Est. area m²');
  String get heightM => get('siteManager.heightM', 'Height m²');
  String get accessAndRequirements =>
      get('siteManager.accessAndRequirements', 'Access & Requirements');
  String get siteAccessInstruction =>
      get('siteManager.siteAccessInstruction', 'Site access instruction');
  String get specialRequirementsNotes => get(
    'siteManager.specialRequirementsNotes',
    'Special requirements & notes',
  );
  String get sitePhoto => get('siteManager.sitePhoto', 'Site Photo');
  String get completeAndConvertToProject => get(
    'siteManager.completeAndConvertToProject',
    'Complete & Convert To Project',
  );
  String get halfDay => get('siteManager.halfDay', 'Half-day');
  String scheduleForDate(String date) =>
      get('siteManager.scheduleForDate', 'SCHEDULE FOR {date}', {'date': date});
  String eventCount(int count) =>
      get('siteManager.eventCount', '({count} EVENTS)', {'count': '$count'});
  String get phase => get('siteManager.phase', 'Phase');
  String get cityOrLocation =>
      get('siteManager.cityOrLocation', 'City / Location');
  String get timeEntryAdded =>
      get('siteManager.timeEntryAdded', 'Time entry added');
  String get timerWillStartFromNow =>
      get('siteManager.timerWillStartFromNow', 'Timer will start from now.');
  String get selectAssignedProject => get(
    'siteManager.selectAssignedProject',
    'Select an assigned project to begin tracking your work',
  );
  String get workingTimeDeductBreak => get(
    'siteManager.workingTimeDeductBreak',
    'Working time is calculated automatically after deducting the break.',
  );
  String loggedThisWeek(String logged, String total) => get(
    'siteManager.loggedThisWeek',
    '{logged} of {total} logged this week',
    {'logged': logged, 'total': total},
  );
  String weekRange(String week, String range) => get(
    'siteManager.weekRange',
    'Week {week} • {range}',
    {'week': week, 'range': range},
  );
  String get orderConfirmed =>
      get('siteManager.orderConfirmed', 'Order confirmed');
  String durationUpdated(String from, String to) => get(
    'siteManager.durationUpdated',
    'Duration Updated: {from} → {to}',
    {'from': from, 'to': to},
  );
  String phaseChanged(String from, String to) => get(
    'siteManager.phaseChanged',
    'Phase changed: {from} → {to}',
    {'from': from, 'to': to},
  );
  String get photo => get('siteManager.photo', 'Photo');
  String get callingClient =>
      get('siteManager.callingClient', 'Calling client...');
  String get startingNavigation =>
      get('siteManager.startingNavigation', 'Starting navigation...');
  String openingFile(String name) =>
      get('siteManager.openingFile', 'Opening {name}', {'name': name});
  String pdfPlan(int count) =>
      get('siteManager.pdfPlan', 'PDF Plan ({count})', {'count': '$count'});
  String contactLabel(String text) =>
      get('siteManager.contactLabel', 'Contact: {text}', {'text': text});
  String get projectLead => get('siteManager.projectLead', 'Project lead');
  String get selectSiteManager =>
      get('siteManager.selectSiteManager', 'Select site manager');
  String get estimatedAreaM2 =>
      get('siteManager.estimatedAreaM2', 'Estimated Area (m²)');
  String get pleaseEnterPhoneNumber =>
      get('siteManager.pleaseEnterPhone', 'Please enter phone number.');
  String get standing => get('siteManager.standing', 'Standing');
  String get enquiry => get('siteManager.enquiry', 'Enquiry');
  String get siteManager => get('siteManager.siteManager', 'Site Manager');
  String timerStartedFor(String activity) => get(
    'siteManager.timerStartedFor',
    'Timer started for {activity}',
    {'activity': activity},
  );
  String get total => get('siteManager.total', 'Total');

  // ============================================================
  // NOTIFICATIONS
  // ============================================================
  String get notificationsTitle => get('notifications.title', 'Notifications');
  String get notificationsAll => get('notifications.all', 'All');
  String get notificationsUnread => get('notifications.unread', 'Unread');
  String get markAllAsRead =>
      get('notifications.markAllAsRead', 'Mark all as read');
  String get clearAll => get('notifications.clearAll', 'Clear all');
  String get noNotifications =>
      get('notifications.noNotifications', 'No notifications');
  String get noNotificationsSubtitle => get(
    'notifications.noNotificationsSubtitle',
    "You're all caught up! New updates and alerts will appear here.",
  );
  String get notifToday => get('notifications.today', 'Today');
  String get notifYesterday => get('notifications.yesterday', 'Yesterday');
  String get notifEarlier => get('notifications.earlier', 'Earlier');
  String get markedAsRead =>
      get('notifications.markedAsRead', 'All notifications marked as read');
  String get allCleared =>
      get('notifications.allCleared', 'All notifications cleared');
}
