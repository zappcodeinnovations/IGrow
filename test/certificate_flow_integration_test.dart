import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/api_models/certificate_model.dart';
import 'package:krushi_siksha/features/certificates/screens/certificates_screen.dart';
import 'package:krushi_siksha/features/certificates/widgets/certificate_viewer_dialog.dart';
import 'package:krushi_siksha/features/certificates/providers/certificates_provider.dart';
import 'package:krushi_siksha/features/upload_course/screens/upload_course_screen.dart';
import 'package:krushi_siksha/features/home_instructor/providers/instructor_home_provider.dart';

void main() {
  group('Certificate Model & Contract Tests', () {
    test('CertificateModel correctly deserializes backend JSON contract', () {
      final json = {
        'id': 'cert-101',
        'certificate_code': 'IAG-2026-D1F502',
        'course_id': 'course-abc',
        'course_slug': 'sandalwood-farming',
        'student_name': 'Ramesh Kumar',
        'course_title': 'Sandalwood Farming 🌱',
        'instructor_name': 'Dr. Sharma',
        'instructor_title': 'Lead Agricultural Specialist',
        'template_style': 'modern',
        'signature_image': '/media/signatures/sig1.png',
        'issued_at': '2026-10-26T12:00:00Z',
        'verification_url': 'https://iagrow.zappcode.in/verify/IAG-2026-D1F502',
      };

      final model = CertificateModel.fromJson(json);
      expect(model.id, equals('cert-101'));
      expect(model.certificateCode, equals('IAG-2026-D1F502'));
      expect(model.studentName, equals('Ramesh Kumar'));
      expect(model.courseTitle, equals('Sandalwood Farming 🌱'));
      expect(model.instructorName, equals('Dr. Sharma'));
      expect(model.instructorTitle, equals('Lead Agricultural Specialist'));
      expect(model.templateStyle, equals('modern'));
      expect(model.signatureImage, startsWith('https://iagrow.zappcode.in'));
      expect(model.issuedAt, isNotNull);
      expect(model.verificationUrl, equals('https://iagrow.zappcode.in/verify/IAG-2026-D1F502'));
    });

    test('CertificateVerificationResult deserializes valid certificate response', () {
      final json = {
        'valid': true,
        'certificate_code': 'IAG-2026-D1F502',
        'student_name': 'Ramesh Kumar',
        'course_title': 'Sandalwood Farming 🌱',
        'instructor_name': 'Dr. Sharma',
        'issued_at': '2026-10-26T12:00:00Z',
        'message': 'Certificate is valid and active',
      };

      final res = CertificateVerificationResult.fromJson(json);
      expect(res.isValid, isTrue);
      expect(res.studentName, equals('Ramesh Kumar'));
      expect(res.courseTitle, equals('Sandalwood Farming 🌱'));
      expect(res.message, equals('Certificate is valid and active'));
    });
  });

  group('Certificate Viewer Dialog Responsive & Layout Tests', () {
    testWidgets('CertificateViewerDialog renders certificate without overflow on narrow device (360x780)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const cert = CertificateModel(
        id: 'cert-1',
        certificateCode: 'IAG-2026-D1F502-TEST-EXTENDED',
        studentName: 'Ramesh Kumar',
        courseTitle: 'Advanced Hydroponics & Vertical Farming',
        instructorName: 'Dr. Agricultural Specialist',
        instructorTitle: 'Lead Agronomist & Course Director',
        templateStyle: 'classic',
        issuedAt: null,
        verificationUrl: 'https://iagrow.zappcode.in/verify/IAG-2026-D1F502',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CertificateViewerDialog(certificate: cert),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify certificate elements render properly
      expect(find.text('IAGROW ACADEMY'), findsOneWidget);
      expect(find.text('CERTIFICATE OF COMPLETION'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.text('Advanced Hydroponics & Vertical Farming'), findsOneWidget);
      expect(find.text('Dr. Agricultural Specialist'), findsWidgets);

      // Verify action buttons exist in responsive single row
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Share Link'), findsOneWidget);
      expect(find.text('Download PDF'), findsOneWidget);

      // Verify no overflow error was triggered
      expect(tester.takeException(), isNull);
    });

    testWidgets('CertificateViewerDialog renders on compact device (320x640) with zero overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const cert = CertificateModel(
        id: 'cert-compact',
        certificateCode: 'IAG-2026-VERY-LONG-CERT-CODE-XYZ-999',
        studentName: 'Very Long Student Full Name Here',
        courseTitle: 'Complete Modern Organic Farming Comprehensive Certification Course',
        instructorName: 'Lead Professor Instructor Name',
        instructorTitle: 'Senior Agronomist',
      );

      FlutterErrorDetails? errorDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorDetails = details;
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CertificateViewerDialog(certificate: cert),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      if (errorDetails != null) {
        debugPrint('💥 FULL ERROR DETAILS:\n${errorDetails.toString()}');
      }
      expect(errorDetails, isNull);
      expect(find.text('Download PDF'), findsOneWidget);
    });
  });

  group('Certificates Screen UI Tests', () {
    testWidgets('CertificatesScreen displays 2 tabs: Earned Certificates & In Progress', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCertificatesProvider.overrideWith((ref) => Future.value([])),
            inProgressEnrollmentsProvider.overrideWithValue([]),
          ],
          child: const MaterialApp(
            home: CertificatesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check App Bar and Tabs
      expect(find.text('My Certificates'), findsOneWidget);
      expect(find.text('Earned (0)'), findsOneWidget);
      expect(find.text('In Progress (0)'), findsOneWidget);

      // Check verification icon in AppBar
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

      // Empty state text
      expect(find.text('No Certificates Earned Yet'), findsOneWidget);
      expect(find.text('Complete 100% of lectures in your enrolled courses to automatically unlock official verified certificates.'), findsOneWidget);

      // Switch to In Progress tab
      await tester.tap(find.text('In Progress (0)'));
      await tester.pumpAndSettle();

      expect(find.text('No Courses in Progress'), findsOneWidget);
    });
  });

  group('Upload Course Step 3 Certificate Preview Tests', () {
    testWidgets('UploadCourseScreen renders Step 3 with Designation, Template Style, and Live Preview',
        (tester) async {
      tester.view.physicalSize = const Size(500, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            instructorEbooksProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: UploadCourseScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill Step 1 to move forward
      final titleField = find.widgetWithText(TextField, 'e.g., Advanced Hydroponics for Urban Farmers');
      if (titleField.evaluate().isNotEmpty) {
        await tester.enterText(titleField, 'Test Hydroponics Course');
        await tester.pump();
      }

      final shortDescField = find.widgetWithText(TextField, 'A brief 1-2 sentence overview of the course...');
      if (shortDescField.evaluate().isNotEmpty) {
        await tester.enterText(shortDescField, 'A short summary for testing');
        await tester.pump();
      }

      final fullDescField = find.widgetWithText(TextField, 'Provide a detailed description of what students will learn...');
      if (fullDescField.evaluate().isNotEmpty) {
        await tester.enterText(fullDescField, 'A detailed description for hydroponics testing');
        await tester.pump();
      }

      // Unfocus keyboard/cursor so pump doesn't keep running forever
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Save & Continue to Step 2
      final nextBtnFinder1 = find.widgetWithText(FilledButton, 'Save & Continue');
      if (nextBtnFinder1.evaluate().isNotEmpty) {
        await tester.ensureVisible(nextBtnFinder1.first);
        await tester.tap(nextBtnFinder1.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      // In Step 2, tap Save & Continue to Step 3
      final nextBtnFinder2 = find.widgetWithText(FilledButton, 'Save & Continue');
      if (nextBtnFinder2.evaluate().isNotEmpty) {
        await tester.ensureVisible(nextBtnFinder2.first);
        await tester.tap(nextBtnFinder2.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      // Verify Step 3 Elements are displayed
      expect(find.text('Issue Certificate of Completion for this Course'), findsOneWidget);
      expect(find.text('Your Digital Signature'), findsOneWidget);
      expect(find.text('Certificate Template Style'), findsOneWidget);
      expect(find.text('Modern Professional'), findsOneWidget);
      expect(find.text('Classic Academic'), findsOneWidget);

      // Verify Instructor Title / Designation field
      expect(find.text('Instructor Title / Designation'), findsOneWidget);
      expect(find.text('Lead Instructor & Agricultural Specialist'), findsWidgets);

      // Verify Live Certificate Demo Preview section
      expect(find.text('Live Certificate Demo Preview'), findsOneWidget);
      expect(find.text('Interactive Demo'), findsOneWidget);
      expect(find.text('CERTIFICATE OF COMPLETION'), findsOneWidget);
      expect(find.text('[Student Full Name]'), findsOneWidget);

      // Verify zero overflow in Step 3
      expect(tester.takeException(), isNull);
    });
  });
}
