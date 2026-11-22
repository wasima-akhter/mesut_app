import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/phone_helper.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/pending_refetch_controller.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/fields/app_phone_field.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../../media/presentation/providers/media_providers.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import 'widgets/profile_avatar_picker.dart';
import 'widgets/profile_edit_header.dart';
import 'widgets/profile_language_selector.dart';
import 'widgets/profile_readonly_card.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late Country _selectedCountry;
  File? _selectedLocalImage;
  String? _avatarUrl;
  String _selectedLanguage = 'DE';
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initFromProfile();
      _isInitialized = true;
    }
  }

  void _initFromProfile() {
    final profile = ref.read(mobileProfileProvider).asData?.value;
    final initialRawPhone = profile?.phone ?? '';
    final parsed = PhoneHelper.parseInitialPhone(initialRawPhone);

    _selectedCountry = parsed.country;
    _firstNameController.text = profile?.firstName ?? '';
    _lastNameController.text = profile?.lastName ?? '';
    _phoneController.text = parsed.nationalNumber;
    _avatarUrl = profile?.avatarUrl;
    _selectedLanguage = (profile?.language ?? 'DE').toUpperCase();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(mobileProfileProvider).asData?.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileEditHeader(),
            Expanded(
              child: PendingPollEffect(
                hasPending: profile?.localization?.isPending == true,
                onPoll: () =>
                    ref.read(mobileProfileProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAvatarPicker(
                        currentAvatarUrl: _avatarUrl,
                        selectedLocalImage: _selectedLocalImage,
                        onImagePicked: (f) =>
                            setState(() => _selectedLocalImage = f),
                      ),
                      SizedBox(height: 22.h),
                      _buildTextField(
                        context,
                        label: context.loc.firstName,
                        hint: context.loc.enterFirstName,
                        controller: _firstNameController,
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        context,
                        label: context.loc.lastName,
                        hint: context.loc.enterLastName,
                        controller: _lastNameController,
                      ),
                      SizedBox(height: 14.h),
                      _buildPhoneField(context),
                      SizedBox(height: 16.h),
                      ProfileLanguageSelector(
                        selectedCode: _selectedLanguage,
                        onLanguageChanged: (c) =>
                            setState(() => _selectedLanguage = c),
                      ),
                      SizedBox(height: 18.h),
                      ProfileReadonlyCard(
                        email: profile?.email ?? '',
                        role: profile?.role ?? '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 14.h),
              child: AppButton.danger(
                text: context.loc.saveChanges,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveChanges,
                borderRadius: 7.r,
                textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary.withValues(alpha: .65),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.profilePhone,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 6.h),
        AppPhoneField(
          controller: _phoneController,
          initialCountryCode: _selectedCountry.code,
          hint: context.loc.enterPhone,
          borderRadius: 7.r,
          borderColor: AppColors.border,
          focusedBorderColor: AppColors.textPrimary,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 13.h),
          onCountryChanged: (c) => setState(() => _selectedCountry = c),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(7.r),
      borderSide: BorderSide(color: color ?? AppColors.border),
    );
  }

  Future<void> _saveChanges() async {
    final loc = context.loc;
    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      AppSnackBar.showError(context, loc.firstNameRequired);
      return;
    }

    final lastName = _lastNameController.text.trim();
    if (lastName.isEmpty) {
      AppSnackBar.showError(context, loc.lastNameRequired);
      return;
    }

    final phoneError = PhoneHelper.validate(
      nationalNumber: _phoneController.text,
      country: _selectedCountry,
      languageCode: loc.localeCode,
    );
    if (phoneError != null) {
      AppSnackBar.showError(context, phoneError);
      return;
    }

    final formattedPhone = PhoneHelper.formatCompleteNumber(
      _selectedCountry,
      _phoneController.text,
    );

    setState(() => _isSaving = true);

    try {
      String? uploadedAvatarUrl = _avatarUrl;
      if (_selectedLocalImage != null) {
        final mediaRepo = ref.read(mediaRepositoryProvider);
        final urls = await mediaRepo.uploadMedia(files: [_selectedLocalImage!]);
        if (urls.isNotEmpty) {
          uploadedAvatarUrl = urls.first;
        }
      }

      await ref.read(mobileProfileProvider.notifier).updateProfile(
            firstName: firstName,
            lastName: lastName,
            phone: formattedPhone,
            avatarUrl: uploadedAvatarUrl,
            language: _selectedLanguage,
          );

      final newLocale = AppLanguage.fromCode(_selectedLanguage);
      await ref.read(appLanguageProvider.notifier).setLanguage(newLocale);

      if (mounted) {
        AppSnackBar.showSuccess(context, loc.profileUpdatedSuccess);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
