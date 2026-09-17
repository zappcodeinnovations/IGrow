import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/router/route_names.dart';

void main() {
  group('Route Names Verification', () {
    test('All critical AgriLearn module routes are defined', () {
      expect(RouteNames.notifications, '/notifications');
      expect(RouteNames.wishlist, '/farmer/wishlist');
      expect(RouteNames.certificates, '/farmer/certificates');
      expect(RouteNames.instructorAnalytics, '/instructor/analytics');
      expect(RouteNames.farmerHome, '/farmer/home');
      expect(RouteNames.instructorHome, '/instructor/home');
    });
  });
}
