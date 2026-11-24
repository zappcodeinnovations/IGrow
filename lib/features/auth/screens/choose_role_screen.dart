import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import 'language_selection_screen.dart';

/// ChooseRoleScreen redirects to LanguageSelectionScreen which now unifies both.
/// Kept for backwards compatibility with any direct route calls.
class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageSelectionScreen();
  }
}
