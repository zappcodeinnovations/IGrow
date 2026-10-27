import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/services.dart';

import 'app_background.dart';
import 'app_navigation_drawer.dart';
import 'custom_bottom_nav_bar.dart';
import '../../data/models/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../localization/app_strings.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';

final GlobalKey<ScaffoldState> shellScaffoldKey = GlobalKey<ScaffoldState>();

class ShellScaffold extends ConsumerStatefulWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isInstructor = user?.activeRole == UserRole.instructor || user?.activeRole == UserRole.admin;
    final isFarmer = !isInstructor;
    
    // Determine current index based on route
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    
    if (isFarmer) {
      if (location.startsWith('/farmer/home')) {
        currentIndex = 0;
      } else if (location.startsWith('/farmer/learning')) {
        currentIndex = 1;
      } else if (location.startsWith('/farmer/explore')) {
        currentIndex = 2;
      } else if (location.startsWith('/farmer/community')) {
        currentIndex = 3;
      }
    } else {
      if (location.startsWith('/instructor/home')) {
        currentIndex = 0;
      } else if (location.startsWith('/instructor/community')) {
        currentIndex = 1;
      } else if (location.startsWith('/instructor/upload')) {
        currentIndex = 2; // placeholder
      } else if (location.startsWith('/instructor/profile')) {
        currentIndex = 3;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If drawer is open, close drawer first
        if (shellScaffoldKey.currentState?.isDrawerOpen == true) {
          shellScaffoldKey.currentState?.closeDrawer();
          return;
        }

        // If not on Home tab, navigate back to Home tab before considering exit
        if (currentIndex != 0) {
          if (isFarmer) {
            context.go(RouteNames.farmerHome);
          } else {
            context.go(RouteNames.instructorHome);
          }
          return;
        }

        // Double tap back confirmation
        final now = DateTime.now();
        if (_lastBackPressed == null || now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          AppToast.show(
            context,
            tr(ref, 'Press back again to exit'),
            duration: const Duration(seconds: 2),
          );
          return;
        }

        // Exit application cleanly
        SystemNavigator.pop();
      },
      child: AppBackground(
        child: Scaffold(
          key: shellScaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: const AppNavigationDrawer(),
          body: widget.child,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => _onTap(context, index, isFarmer),
            items: isFarmer
                ? [
                    BottomNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: tr(ref, 'Home'),
                    ),
                    BottomNavItem(
                      icon: Icons.play_circle_outline_rounded,
                      activeIcon: Icons.play_circle_fill_rounded,
                      label: tr(ref, 'My learning'),
                    ),
                    BottomNavItem(
                      icon: Icons.explore_outlined,
                      activeIcon: Icons.explore_rounded,
                      label: tr(ref, 'Explore'),
                    ),
                    BottomNavItem(
                      icon: Icons.groups_outlined,
                      activeIcon: Icons.groups_rounded,
                      label: tr(ref, 'Community'),
                    ),
                  ]
                : [
                    BottomNavItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: tr(ref, 'Dashboard'),
                    ),
                    BottomNavItem(
                      icon: Icons.groups_outlined,
                      activeIcon: Icons.groups_rounded,
                      label: tr(ref, 'Community'),
                    ),
                    BottomNavItem(
                      icon: Icons.add_circle_outline_rounded,
                      activeIcon: Icons.add_circle_rounded,
                      label: tr(ref, 'Upload'),
                    ),
                    BottomNavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: tr(ref, 'Profile'),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index, bool isFarmer) {
    if (isFarmer) {
      switch (index) {
        case 0:
          context.go(RouteNames.farmerHome);
          break;
        case 1:
          context.go(RouteNames.farmerLearning);
          break;
        case 2:
          context.go(RouteNames.explore);
          break;
        case 3:
          context.go(RouteNames.farmerCommunity);
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go(RouteNames.instructorHome);
          break;
        case 1:
          context.go(RouteNames.instructorCommunity);
          break;
        case 2:
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.video_library, color: AppColors.primaryGreen),
                        title: const Text('Upload Course'),
                        subtitle: const Text('Upload video lectures and create a new course.'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/instructor/upload');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.menu_book, color: AppColors.primaryGreen),
                        title: const Text('Upload Ebook'),
                        subtitle: const Text('Upload a PDF or Word document.'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/instructor/upload-ebook');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          break;
        case 3:
          context.go(RouteNames.instructorProfile);
          break;
      }
    }
  }
}
