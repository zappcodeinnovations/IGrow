import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/auth_success_screen.dart';
import '../../features/auth/screens/choose_role_screen.dart';
import '../../features/auth/screens/create_password_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/language_selection_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/community/screens/create_post_screen.dart';
import '../../features/explore/screens/course_player_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/instructor_dashboard/screens/instructor_uploads_screen.dart';
import '../../features/instructor_dashboard/screens/instructor_analytics_screen.dart';
import '../../features/instructor_dashboard/screens/qa_management_screen.dart';
import '../../features/instructor_dashboard/screens/manage_course_screen.dart';
import '../../features/instructor_dashboard/screens/instructor_kyc_screen.dart';
import '../../features/instructor_dashboard/screens/instructor_reviews_screen.dart';
import '../../features/home_farmer/screens/farmer_home_screen.dart';
import '../../features/home_instructor/screens/instructor_home_screen.dart';
import '../../features/profile/screens/privacy_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/explore/screens/quiz_player_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/support_screen.dart';
import '../../features/explore/screens/course_details_screen.dart';
import '../../features/explore/screens/ebook_viewer_screen.dart';
import '../../features/upload_course/screens/upload_course_screen.dart';
import '../../features/upload_course/screens/upload_ebook_screen.dart';
import '../../features/home_instructor/screens/instructor_chatbot_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/cart/screens/checkout_screen.dart';
import '../../features/cart/screens/checkout_success_screen.dart';
import '../../features/cart/screens/orders_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/wishlist/screens/wishlist_screen.dart';
import '../../features/certificates/screens/certificates_screen.dart';
import '../../features/explore/screens/downloads_screen.dart';
import '../widgets/not_found_screen.dart';
import '../widgets/shell_scaffold.dart';
import 'route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    refreshListenable: GoRouterRefreshStream(ref.read(authProvider.notifier).stream),
    errorBuilder: (context, state) => NotFoundScreen(
      errorMessage: state.error?.message,
    ),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/otp') ||
          state.matchedLocation.startsWith('/forgot') ||
          state.matchedLocation.startsWith('/create') ||
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/language') ||
          state.matchedLocation.startsWith('/choose') ||
          state.matchedLocation.startsWith('/auth');
          
      final isSplash = state.matchedLocation == RouteNames.splash || state.matchedLocation == '/';
      
      if (authState.status == AuthStatus.initial) {
        return RouteNames.splash;
      }
      
      if (authState.status == AuthStatus.unauthenticated) {
        if (!isAuthRoute && !isSplash) {
          return RouteNames.login;
        }
        return null;
      }
      
      if (authState.status == AuthStatus.authenticated) {
        final role = authState.user?.activeRole;
        
        if (isAuthRoute || isSplash) {
          if (role == UserRole.instructor) {
            return RouteNames.instructorHome;
          } else {
            return RouteNames.farmerHome;
          }
        }
        
        // Guard against cross-role navigation
        if (role == UserRole.farmer && state.matchedLocation.startsWith('/instructor')) {
          return RouteNames.farmerHome;
        }
        
        if (role == UserRole.instructor &&
            state.matchedLocation.startsWith('/farmer') &&
            !state.matchedLocation.startsWith('/farmer/course') &&
            !state.matchedLocation.startsWith('/farmer/ebook')) {
          return RouteNames.instructorHome;
        }
      }
      
      return null;
    },
    routes: [
      // ─── Splash ────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        redirect: (context, state) => RouteNames.splash,
      ),
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // ─── Auth ────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.languageSelection,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.chooseRole,
        builder: (context, state) => const ChooseRoleScreen(),
      ),
      GoRoute(
        path: RouteNames.authSuccess,
        builder: (context, state) => const AuthSuccessScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final purpose = state.uri.queryParameters['purpose'] ?? '';
          return OtpScreen(email: email, purpose: purpose);
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.createPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return CreatePasswordScreen(token: token);
        },
      ),
      
      // ─── Player & Details ─────────────────────────────────────────────
      GoRoute(
        path: '/farmer/course/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CourseDetailsScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CourseDetailsScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/farmer/courses/:id',
        redirect: (context, state) => '/farmer/course/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/farmer/ebook/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EbookViewerScreen(ebookId: id);
        },
      ),
      GoRoute(
        path: '/farmer/ebooks/:id',
        redirect: (context, state) => '/farmer/ebook/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final fromCheckout = state.uri.queryParameters['fromCheckout'] == 'true';
          return CoursePlayerScreen(courseId: id, fromCheckout: fromCheckout);
        },
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return QuizPlayerScreen(sectionId: id);
        },
      ),
      
      // ─── Cart & Orders ──────────────────────────────────────────────
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: RouteNames.cart,
        builder: (context, state) => const CartScreen(),
      ),

      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          final ebookId = state.uri.queryParameters['ebookId'];
          return CheckoutScreen(
            directCourseId: courseId,
            directEbookId: ebookId,
          );
        },
      ),
      GoRoute(
        path: RouteNames.paymentSuccess,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final qp = state.uri.queryParameters;

          final originalTotal = (extra['originalTotal'] as num?)?.toDouble() ??
              double.tryParse(qp['originalTotal'] ?? '') ??
              0.0;
          final finalTotal = (extra['finalTotal'] as num?)?.toDouble() ??
              double.tryParse(qp['finalTotal'] ?? '') ??
              0.0;
          final discountAmount = (extra['discountAmount'] as num?)?.toDouble() ??
              double.tryParse(qp['discountAmount'] ?? '') ??
              0.0;
          final couponCode = extra['couponCode'] as String? ?? qp['couponCode'];
          final paymentMethod = extra['paymentMethod'] as String? ??
              qp['paymentMethod'] ??
              'DUMMY_CARD';
          final purchasedItems = extra['purchasedItems'] as List<dynamic>? ?? [];

          return CheckoutSuccessScreen(
            orderResult: (extra['orderResult'] as Map<String, dynamic>?) ?? {},
            originalTotal: originalTotal,
            finalTotal: finalTotal,
            discountAmount: discountAmount,
            couponCode: couponCode,
            paymentMethod: paymentMethod,
            purchasedItems: purchasedItems,
          );
        },
      ),
      GoRoute(
        path: '/payment-success',
        redirect: (context, state) => state.uri.toString().replaceFirst('/payment-success', RouteNames.paymentSuccess),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),

      // ─── Modal Routes ────────────────────────────────────────────────
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: RouteNames.chat,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: RouteNames.createPost,
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.wishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: RouteNames.certificates,
        builder: (context, state) => const CertificatesScreen(),
      ),
      GoRoute(
        path: '/certificates',
        builder: (context, state) => const CertificatesScreen(),
      ),
      GoRoute(
        path: RouteNames.downloads,
        builder: (context, state) => const DownloadsScreen(),
      ),
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
      
      // ─── Shell Router (Bottom Navigation) ────────────────────────────
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        routes: [
          // ─── Farmer Routes ───────────────────────────────────────────
          GoRoute(
            path: RouteNames.farmerHome,
            builder: (context, state) => const FarmerHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.explore,
            builder: (context, state) {
              final search = state.uri.queryParameters['search'];
              final tabParam = state.uri.queryParameters['tab'];
              final initialTab = (tabParam == 'ebooks' || tabParam == '1') ? 1 : 0;
              return ExploreScreen(initialSearch: search, initialTab: initialTab);
            },
          ),
          GoRoute(
            path: RouteNames.farmerCommunity,
            builder: (context, state) => const CommunityScreen(),
          ),
          GoRoute(
            path: RouteNames.farmerProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
          
          // ─── Instructor Routes ───────────────────────────────────────
          GoRoute(
            path: RouteNames.instructorHome,
            builder: (context, state) => const InstructorHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.instructorCommunity,
            builder: (context, state) => const CommunityScreen(),
          ),
          GoRoute(
            path: RouteNames.uploadCourse,
            builder: (context, state) => const UploadCourseScreen(),
          ),
          GoRoute(
            path: RouteNames.uploadEbook,
            builder: (context, state) => const UploadEbookScreen(),
          ),
          GoRoute(
            path: RouteNames.uploadGuide,
            builder: (context, state) => const InstructorChatbotScreen(),
          ),
          GoRoute(
            path: RouteNames.instructorProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.instructorUploads,
            builder: (context, state) => const InstructorUploadsScreen(),
          ),
          GoRoute(
            path: RouteNames.instructorKyc,
            builder: (context, state) => const InstructorKycScreen(),
          ),
          GoRoute(
            path: RouteNames.instructorAnalytics,
            builder: (context, state) => const InstructorAnalyticsScreen(),
          ),
          GoRoute(
            path: '/instructor/qa',
            builder: (context, state) => const QaManagementScreen(),
          ),
          GoRoute(
            path: RouteNames.instructorReviews,
            builder: (context, state) => const InstructorReviewsScreen(),
          ),
          GoRoute(
            path: '/instructor/manage-course/:id',
            builder: (context, state) => ManageCourseScreen(
              courseId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});

// Helper for Riverpod refresh listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
