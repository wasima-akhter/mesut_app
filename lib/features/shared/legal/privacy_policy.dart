import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/context_extensions.dart';
import '../config/presentation/providers/mobile_config_provider.dart';
import '../legal_web_page.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteHtml = ref.watch(privacyPolicyHtmlProvider);
    const String privacyPolicyHtml = '''
<div style="font-family: Arial, sans-serif; line-height: 1.7; color: #333;">

  <h1 style="color: #1a73e8; font-size: 28px; margin-bottom: 10px;">
    Privacy Policy
  </h1>

  <p style="color: #666; font-size: 14px;">
    Last updated: October 6, 2026
  </p>

  <p>
    Your privacy is important to us. This Privacy Policy explains how we
    collect, use, store, and protect your information when you use our
    application and services. By using our application, you agree to the
    practices described in this policy.
  </p>

  <hr style="border: none; border-top: 1px solid #e5e5e5; margin: 25px 0;">

  <h2 style="color: #222;">1. Information We Collect</h2>

  <p>
    We may collect information that you provide directly to us when you create
    an account, use our services, contact us, or interact with different
    features of the application.
  </p>

  <ul>
    <li>Name and basic profile information</li>
    <li>Email address and contact information</li>
    <li>Account and authentication information</li>
    <li>Information you voluntarily submit through the application</li>
    <li>Device and technical information required to operate the service</li>
  </ul>

  <h2 style="color: #222;">2. How We Use Your Information</h2>

  <p>
    We use the information we collect to provide, maintain, improve, and
    personalize our services. Your information may also be used to:
  </p>

  <ul>
    <li>Provide and manage your account</li>
    <li>Process requests and transactions</li>
    <li>Improve application performance and user experience</li>
    <li>Communicate with you about important service updates</li>
    <li>Detect and prevent fraud, abuse, and unauthorized activity</li>
    <li>Maintain the security and reliability of our services</li>
  </ul>

  <h2 style="color: #222;">3. Information Protection</h2>

  <p>
    We take reasonable technical and organizational measures to protect your
    personal information against unauthorized access, disclosure, alteration,
    or destruction. However, no method of electronic storage or transmission
    over the internet can be guaranteed to be completely secure.
  </p>

  <div style="
    background-color: #f1f7ff;
    border-left: 4px solid #1a73e8;
    padding: 15px;
    margin: 20px 0;
    border-radius: 4px;
  ">
    <strong>Your privacy matters.</strong>
    We only use information when it is necessary to provide and improve our
    services or when required for legitimate operational purposes.
  </div>

  <h2 style="color: #222;">4. Sharing of Information</h2>

  <p>
    We do not sell your personal information. We may share limited information
    with trusted service providers when necessary to operate our application,
    provide requested services, maintain infrastructure, or comply with legal
    obligations.
  </p>

  <p>
    Any third-party service providers we work with are expected to handle
    information appropriately and only for the purposes for which it was
    provided.
  </p>

  <h2 style="color: #222;">5. Cookies and Similar Technologies</h2>

  <p>
    We may use cookies, local storage, analytics tools, or similar technologies
    to remember preferences, understand how users interact with our services,
    improve performance, and provide a better experience.
  </p>

  <h2 style="color: #222;">6. Data Retention</h2>

  <p>
    We retain personal information only for as long as reasonably necessary to
    provide our services, fulfill the purposes described in this policy,
    resolve disputes, maintain business records, or comply with applicable
    legal requirements.
  </p>

  <h2 style="color: #222;">7. Your Rights</h2>

  <p>
    Depending on your location and applicable laws, you may have rights
    regarding your personal information, including the right to request access,
    correction, deletion, or restriction of certain information.
  </p>

  <p>
    If you would like to exercise any applicable privacy rights, please contact
    us using the contact information provided below.
  </p>

  <h2 style="color: #222;">8. Children's Privacy</h2>

  <p>
    Our services are not intended to knowingly collect personal information
    from children without appropriate authorization. If you believe that a
    child has provided personal information to us, please contact us so that
    we can take appropriate action.
  </p>

  <h2 style="color: #222;">9. Changes to This Privacy Policy</h2>

  <p>
    We may update this Privacy Policy from time to time to reflect changes in
    our services, technology, or legal requirements. When we make significant
    changes, we may provide an appropriate notice through the application or
    other available communication channels.
  </p>

  <h2 style="color: #222;">10. Contact Us</h2>

  <p>
    If you have questions, concerns, or requests regarding this Privacy Policy
    or the handling of your personal information, please contact our support
    team.
  </p>

  <div style="
    background-color: #f8f9fa;
    padding: 18px;
    margin-top: 25px;
    border-radius: 8px;
  ">
    <p style="margin: 0;">
      <strong>Thank you for trusting us.</strong><br>
      We are committed to protecting your privacy and handling your
      information responsibly.
    </p>
  </div>

</div>
''';

    return LegalWebPage(
      title: context.loc.privacyPolicy,
      html: (remoteHtml != null && remoteHtml.trim().isNotEmpty)
          ? remoteHtml
          : privacyPolicyHtml,
      onRefresh: () => ref.read(mobileConfigProvider.notifier).refresh(),
    );
  }
}
