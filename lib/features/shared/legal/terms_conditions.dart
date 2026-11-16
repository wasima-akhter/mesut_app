import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/context_extensions.dart';
import '../config/presentation/providers/mobile_config_provider.dart';
import '../legal_web_page.dart';

class TermsAndConditionsPage extends ConsumerWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteHtml = ref.watch(termsConditionsHtmlProvider);
    const String termsAndConditionsHtml = '''
<div style="font-family: Arial, sans-serif; line-height: 1.7; color: #333;">

  <h1 style="color: #1a73e8; font-size: 28px; margin-bottom: 10px;">
    Terms & Conditions
  </h1>

  <p style="color: #666; font-size: 14px;">
    Last updated: October 6, 2026
  </p>

  <p>
    Welcome to our application. These Terms & Conditions govern your access
    to and use of our application, website, features, and services. By
    accessing or using our services, you acknowledge that you have read,
    understood, and agree to be bound by these terms.
  </p>

  <hr style="border: none; border-top: 1px solid #e5e5e5; margin: 25px 0;">

  <h2 style="color: #222;">1. Acceptance of Terms</h2>

  <p>
    By creating an account, accessing, or using our services, you agree to
    comply with these Terms & Conditions and all applicable laws and
    regulations. If you do not agree with any part of these terms, you should
    discontinue use of the application.
  </p>

  <h2 style="color: #222;">2. Eligibility</h2>

  <p>
    You must be legally capable of entering into a binding agreement to use
    our services. By using the application, you represent that the information
    you provide is accurate and that you have the authority to accept these
    terms on your own behalf.
  </p>

  <h2 style="color: #222;">3. Your Account</h2>

  <p>
    Some features may require you to create an account. You are responsible
    for maintaining the confidentiality of your account credentials and for
    all activity performed through your account.
  </p>

  <ul>
    <li>Provide accurate and up-to-date information.</li>
    <li>Keep your login credentials secure.</li>
    <li>Do not share your account with unauthorized individuals.</li>
    <li>Notify us promptly if you suspect unauthorized account activity.</li>
  </ul>

  <div style="
    background-color: #fff8e6;
    border-left: 4px solid #f5a623;
    padding: 15px;
    margin: 20px 0;
    border-radius: 4px;
  ">
    <strong>Important:</strong>
    You are responsible for activity performed using your account unless the
    activity resulted from circumstances outside your reasonable control.
  </div>

  <h2 style="color: #222;">4. Acceptable Use</h2>

  <p>
    You agree to use the application responsibly and only for lawful purposes.
    You must not use the service in a way that could damage, disable,
    overburden, or interfere with the operation or security of the service.
  </p>

  <p>You must not:</p>

  <ul>
    <li>Use the service for unlawful or fraudulent activities.</li>
    <li>Attempt to gain unauthorized access to systems or accounts.</li>
    <li>Upload malicious software, viruses, or harmful content.</li>
    <li>Reverse engineer or attempt to extract protected source code.</li>
    <li>Interfere with the normal operation of the application.</li>
    <li>Abuse, harass, threaten, or harm other users.</li>
    <li>Use automated systems to excessively access or disrupt the service.</li>
  </ul>

  <h2 style="color: #222;">5. User Content</h2>

  <p>
    You may have the ability to submit, upload, publish, or otherwise provide
    content through the application. You remain responsible for the content
    you submit and must ensure that you have the necessary rights and
    permissions to use it.
  </p>

  <p>
    By submitting content, you grant us the rights necessary to store,
    process, display, and use that content solely as required to provide and
    operate the services.
  </p>

  <h2 style="color: #222;">6. Intellectual Property</h2>

  <p>
    Unless otherwise stated, the application and its contents, including
    designs, logos, graphics, text, software, interfaces, and other materials,
    are owned by or licensed to us and are protected by applicable
    intellectual-property laws.
  </p>

  <p>
    You may not copy, reproduce, modify, distribute, sell, or create derivative
    works from our protected materials without prior written permission,
    except where such use is permitted by applicable law.
  </p>

  <h2 style="color: #222;">7. Third-Party Services</h2>

  <p>
    Our application may integrate with or contain links to third-party
    services. These services may operate under their own terms and privacy
    policies. We are not responsible for the content, availability, policies,
    or practices of third-party services.
  </p>

  <h2 style="color: #222;">8. Payments and Subscriptions</h2>

  <p>
    If the application offers paid products, subscriptions, or other
    transactions, additional payment terms may apply. You agree to provide
    accurate billing information and authorize applicable charges associated
    with your selected plan or purchase.
  </p>

  <p>
    Prices, features, subscription plans, and availability may change from
    time to time. Where required, we will provide appropriate notice of
    material changes.
  </p>

  <h2 style="color: #222;">9. Service Availability</h2>

  <p>
    We aim to keep our services available and reliable, but we do not
    guarantee that the application will always be available, uninterrupted,
    secure, or error-free.
  </p>

  <p>
    We may temporarily suspend or modify parts of the service for maintenance,
    security updates, technical improvements, or other operational reasons.
  </p>

  <h2 style="color: #222;">10. Disclaimer</h2>

  <p>
    The application and its services are provided on an "as available" and
    "as is" basis to the extent permitted by applicable law. We do not
    guarantee that the service will meet every individual requirement or that
    all information provided through the application will always be complete,
    accurate, or current.
  </p>

  <h2 style="color: #222;">11. Limitation of Liability</h2>

  <p>
    To the maximum extent permitted by applicable law, we will not be liable
    for indirect, incidental, special, consequential, or punitive damages
    arising from or related to your use of the application.
  </p>

  <p>
    This limitation applies to the extent permitted by applicable law and does
    not exclude liability that cannot legally be excluded or limited.
  </p>

  <h2 style="color: #222;">12. Account Suspension or Termination</h2>

  <p>
    We may suspend, restrict, or terminate access to an account if we
    reasonably believe that the user has violated these terms, engaged in
    fraudulent or harmful activity, or created a security or legal risk.
  </p>

  <p>
    You may stop using the service and, where applicable, request deletion of
    your account at any time.
  </p>

  <h2 style="color: #222;">13. Changes to These Terms</h2>

  <p>
    We may update these Terms & Conditions from time to time. Updated terms
    will become effective when they are posted or otherwise communicated,
    unless a different effective date is specified.
  </p>

  <p>
    Your continued use of the application after the updated terms become
    effective constitutes your acceptance of the revised terms.
  </p>

  <h2 style="color: #222;">14. Governing Law</h2>

  <p>
    These Terms & Conditions will be governed by and interpreted in accordance
    with the applicable laws of the jurisdiction in which our services are
    operated, unless otherwise required by applicable law.
  </p>

  <h2 style="color: #222;">15. Contact Us</h2>

  <p>
    If you have questions, concerns, or requests regarding these Terms &
    Conditions, please contact our support team through the contact
    information provided within the application.
  </p>

  <div style="
    background-color: #f1f7ff;
    border-left: 4px solid #1a73e8;
    padding: 18px;
    margin-top: 25px;
    border-radius: 6px;
  ">
    <p style="margin: 0;">
      <strong>Thank you for using our service.</strong><br>
      We appreciate your trust and ask that you use our application
      responsibly and respectfully.
    </p>
  </div>

</div>
''';

    return LegalWebPage(
      title: context.loc.termsAndConditions,
      html: (remoteHtml != null && remoteHtml.trim().isNotEmpty)
          ? remoteHtml
          : termsAndConditionsHtml,
      onRefresh: () => ref.read(mobileConfigProvider.notifier).refresh(),
    );
  }
}
