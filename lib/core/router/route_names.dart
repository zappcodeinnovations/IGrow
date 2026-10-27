/// Centralized route path constants for IGrow.
///
/// Using constants prevents typos and makes refactoring straightforward.
class RouteNames {
  RouteNames._();

  // ─── Auth ────────────────────────────────────────────────────────
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const languageSelection = '/language-selection';
  static const chooseRole = '/choose-role';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';
  static const createPassword = '/create-password';
  static const authSuccess = '/auth-success';

  // ─── Farmer Shell ────────────────────────────────────────────────
  static const farmerHome = '/farmer/home';
  static const farmerLearning = '/farmer/learning';
  static const explore = '/farmer/explore';
  static const farmerCommunity = '/farmer/community';
  static const farmerProfile = '/farmer/profile';

  // Farmer sub-routes
  static const courseDetails = '/farmer/course/:id';
  static const cart = '/farmer/cart';
  static const checkout = '/farmer/checkout';
  static const paymentSuccess = '/farmer/payment-success';
  static const videoPlayer = '/farmer/video/:id';
  static const certificates = '/farmer/certificates';
  static const liveClass = '/farmer/live-class';
  static const wishlist = '/farmer/wishlist';

  // ─── Instructor Shell ────────────────────────────────────────────
  static const instructorHome = '/instructor/home';
  static const instructorCommunity = '/instructor/community';
  static const uploadCourse = '/instructor/upload';
  static const uploadEbook = '/instructor/upload-ebook';
  static const uploadGuide = '/instructor/upload-guide';
  static const instructorAnalytics = '/instructor/analytics';
  static const instructorProfile = '/instructor/profile';

  // Instructor sub-routes
  static const creatorDashboard = '/instructor/creator-dashboard';
  static const instructorUploads = '/instructor/uploads';
  static const instructorKyc = '/instructor/kyc';
  static const instructorReviews = '/instructor/reviews';

  // ─── Shared ──────────────────────────────────────────────────────
  static const wallet = '/wallet';
  static const chat = '/chat';
  static const chatThread = '/chat/:id';
  static const notifications = '/notifications';
  static const marketplace = '/marketplace';
  static const productDetails = '/marketplace/product/:id';
  static const settings = '/settings';
  static const createPost = '/community/create-post';
  static const hubDetails = '/community/hub/:id';
  static const createHub = '/community/create-hub';
  static const downloads = '/downloads';
  static const news = '/news';

  // ─── Admin ───────────────────────────────────────────────────────
  static const adminPanel = '/admin';

  // ─── Error ───────────────────────────────────────────────────────
  static const forbidden = '/forbidden';
  static const notFound = '/not-found';
}
