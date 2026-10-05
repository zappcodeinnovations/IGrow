import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_background.dart';
import '../../data/models/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isFarmer = user?.activeRole == UserRole.farmer;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine current index based on route
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    
    if (isFarmer) {
      if (location.startsWith('/farmer/home')) {
        currentIndex = 0;
      } else if (location.startsWith('/farmer/explore')) {
        currentIndex = 1;
      } else if (location.startsWith('/farmer/community')) {
        currentIndex = 2;
      } else if (location.startsWith('/farmer/profile')) {
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

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: (isDark ? AppColors.bgDark : Colors.white).withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.lineDark : const Color(0xFFE2EBE0),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.08 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => _onTap(context, index, isFarmer),
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primaryGreen,
            unselectedItemColor: isDark ? const Color(0xFF8B9E90) : AppColors.inkSoft,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          items: isFarmer
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore_rounded),
                    label: 'Explore',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline_rounded),
                    activeIcon: Icon(Icons.people_rounded),
                    label: 'Community',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline_rounded),
                    activeIcon: Icon(Icons.people_rounded),
                    label: 'Community',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    activeIcon: Icon(Icons.add_circle_rounded),
                    label: 'Upload',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
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
          context.go(RouteNames.explore);
          break;
        case 2:
          context.go(RouteNames.farmerCommunity);
          break;
        case 3:
          context.go(RouteNames.farmerProfile);
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
