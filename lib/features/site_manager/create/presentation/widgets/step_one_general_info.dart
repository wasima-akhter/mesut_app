import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/countries.dart';

import '../../../../../core/helpers/phone_helper.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/fields/app_phone_field.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../../customers/presentation/widgets/customer_dropdown_field.dart';
import '../providers/create_project_provider.dart';
import 'create_project_form_helpers.dart';

class StepOneGeneralInfo extends ConsumerStatefulWidget {
  const StepOneGeneralInfo({super.key});

  @override
  ConsumerState<StepOneGeneralInfo> createState() => _StepOneGeneralInfoState();
}

class _StepOneGeneralInfoState extends ConsumerState<StepOneGeneralInfo> {
  late final TextEditingController _nameController;
  late final TextEditingController _clientNameController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;

  Country _selectedCountry =
      PhoneHelper.findCountryByIso(PhoneHelper.defaultCountryCode);

  @override
  void initState() {
    super.initState();
    final state = ref.read(createProjectProvider);
    _nameController = TextEditingController(text: state.projectName);
    _clientNameController = TextEditingController(text: state.clientName);
    _contactNameController = TextEditingController(text: state.contactName);
    _phoneController = TextEditingController(text: state.contactPhone);
    _emailController = TextEditingController(text: state.contactEmail);
    _roleController = TextEditingController(text: state.contactRole);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientNameController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _onNext() {
    final state = ref.read(createProjectProvider);

    if (_nameController.text.trim().isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseEnterProjectName);
      return;
    }

    if (state.isExistingClient && state.selectedClientId.isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseSelectExistingCustomer);
      return;
    }

    if (!state.isExistingClient && _clientNameController.text.trim().isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseEnterCustomerName);
      return;
    }

    if (_contactNameController.text.trim().isEmpty) {
      AppSnackBar.showError(context, context.loc.pleaseEnterContactPersonName);
      return;
    }

    final formattedPhone = _phoneController.text.trim().isNotEmpty
        ? PhoneHelper.formatCompleteNumber(
            _selectedCountry,
            _phoneController.text.trim(),
          )
        : '';

    ref.read(createProjectProvider.notifier).updateStepOne(
          projectName: _nameController.text.trim(),
          clientName: state.isExistingClient ? state.clientName : _clientNameController.text.trim(),
          contactName: _contactNameController.text.trim(),
          contactPhone: formattedPhone,
          contactEmail: _emailController.text.trim(),
          contactRole: _roleController.text.trim(),
        );

    ref.read(createProjectProvider.notifier).setStep(1);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProjectProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      children: [
        FormSectionTitle(title: context.loc.generalAndCustomerInfo),
        SizedBox(height: 14.h),
        FormFieldLabel(label: context.loc.projectName),
        SizedBox(height: 6.h),
        FormTextField(
          controller: _nameController,
          hint: 'e.g. Goltstein Complex',
        ),
        SizedBox(height: 14.h),
        FormFieldLabel(label: context.loc.customer),
        SizedBox(height: 6.h),
        Container(
          height: 42.h,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(createProjectProvider.notifier)
                      .updateStepOne(isExistingClient: true),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: state.isExistingClient
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      context.loc.existingClient,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: state.isExistingClient
                            ? Colors.white
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(createProjectProvider.notifier)
                      .updateStepOne(isExistingClient: false),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !state.isExistingClient
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      context.loc.newClient,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: !state.isExistingClient
                            ? Colors.white
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        if (state.isExistingClient)
          CustomerDropdownField(
            selectedCustomerId: state.selectedClientId.isNotEmpty
                ? state.selectedClientId
                : null,
            selectedCustomerName:
                state.clientName.isNotEmpty ? state.clientName : null,
            onCustomerSelected: (customer) {
              ref.read(createProjectProvider.notifier).updateStepOne(
                    selectedClientId: customer.id,
                    clientName: customer.name,
                    clientCategory: customer.category,
                  );
              if (customer.primaryContact != null) {
                final contact = customer.primaryContact!;
                if (_contactNameController.text.trim().isEmpty) {
                  _contactNameController.text = contact.name;
                }
                if (_phoneController.text.trim().isEmpty &&
                    contact.phone.isNotEmpty) {
                  _phoneController.text = contact.phone;
                }
                if (_emailController.text.trim().isEmpty &&
                    contact.email.isNotEmpty) {
                  _emailController.text = contact.email;
                }
                if (_roleController.text.trim().isEmpty &&
                    contact.role.isNotEmpty) {
                  _roleController.text = contact.role;
                }
              }
            },
          )
        else ...[
          FormTextField(
            controller: _clientNameController,
            hint: context.loc.customerOrCompanyName,
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: ['COMMERCIAL', 'PRIVATE', 'MUNICIPALITY'].map((cat) {
              return ChoiceChip(
                label: Text(cat),
                selected: state.clientCategory == cat,
                onSelected: (_) => ref.read(createProjectProvider.notifier).updateStepOne(clientCategory: cat),
              );
            }).toList(),
          ),
        ],
        SizedBox(height: 14.h),
        FormFieldLabel(label: context.loc.priority),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 8.w,
          children: ['HIGH', 'MEDIUM', 'LOW'].map((p) {
            final sel = state.priority == p;
            final color = MobilePhaseLocalizer.priorityColor(p);
            return GestureDetector(
              onTap: () => ref.read(createProjectProvider.notifier).updateStepOne(priority: p),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: sel ? color : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  MobilePhaseLocalizer.priority(context, p),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : const Color(0xFF4B5563),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 14.h),
        FormFieldLabel(label: context.loc.contactPerson),
        SizedBox(height: 6.h),
        FormTextField(
          controller: _contactNameController,
          hint: 'e.g. Tim Müller (Project Lead)',
        ),
        SizedBox(height: 12.h),
        FormFieldLabel(label: context.loc.phoneNumber),
        SizedBox(height: 6.h),
        AppPhoneField(
          controller: _phoneController,
          initialCountryCode: _selectedCountry.code,
          hint: context.loc.enterPhone,
          borderRadius: 6.r,
          borderColor: const Color(0xFFDCDCDC),
          focusedBorderColor: const Color(0xFF444444),
          onCountryChanged: (c) => setState(() => _selectedCountry = c),
        ),
        SizedBox(height: 12.h),
        FormFieldLabel(label: context.loc.email),
        SizedBox(height: 6.h),
        FormTextField(
          controller: _emailController,
          hint: 'e.g. lead@hochtief.de',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 22.h),
        StepActionButtons(
          previousText: context.loc.cancel,
          nextText: context.loc.next,
          onPrevious: () => Navigator.pop(context),
          onNext: _onNext,
        ),
      ],
    );
  }
}
