import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/widgets/app_text_field.dart';
import 'package:krushi_siksha/features/auth/screens/register_screen.dart';

void main() {
  group('Create Account Password Minimum Length Validation Tests', () {
    testWidgets('Password field on RegisterScreen validates minimum 4 characters', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the password AppTextField
      final passwordAppTextFieldFinder = find.byWidgetPredicate(
        (widget) => widget is AppTextField && widget.label == 'Password',
      );
      expect(passwordAppTextFieldFinder, findsOneWidget);

      final appTextField = tester.widget<AppTextField>(passwordAppTextFieldFinder);
      expect(appTextField.validator, isNotNull);

      // Null or empty
      expect(appTextField.validator!(null), 'Min 4 characters');
      expect(appTextField.validator!(''), 'Min 4 characters');

      // Less than 4 characters
      expect(appTextField.validator!('1'), 'Min 4 characters');
      expect(appTextField.validator!('12'), 'Min 4 characters');
      expect(appTextField.validator!('123'), 'Min 4 characters');

      // 4 characters or more (valid)
      expect(appTextField.validator!('1234'), isNull);
      // 6 characters (as reported by tester)
      expect(appTextField.validator!('123456'), isNull);
      // 8 characters
      expect(appTextField.validator!('12345678'), isNull);
    });
  });
}
