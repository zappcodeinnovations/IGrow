import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/user_model.dart';
import 'package:krushi_siksha/data/models/user_role.dart';
import 'package:krushi_siksha/data/repositories/auth_repository.dart';
import 'package:krushi_siksha/core/network/token_storage.dart';
import 'package:krushi_siksha/core/network/swagger_generated/app_api.swagger.dart';
import 'package:chopper/chopper.dart' as chopper;

class FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => 'fake-token';

  @override
  Future<String?> getRefreshToken() async => 'fake-refresh';

  @override
  Future<void> setAccessToken(String token) async {}

  @override
  Future<void> setRefreshToken(String token) async {}

  @override
  Future<bool> hasToken() async => true;

  @override
  Future<void> saveTokens({required String access, required String refresh}) async {}
}

void main() {
  group('Panel 2: Role Switching Dual Persona Tests', () {
    test('switchRole dynamically grants new role without throwing permission errors', () async {
      final fakeChopper = chopper.ChopperClient();
      final fakeApi = AppApi.create(client: fakeChopper);
      final repo = ApiAuthRepository(
        appApi: fakeApi,
        tokenStorage: FakeTokenStorage(),
      );

      // Create a student user who initially only has farmer in grantedRoles
      const initialUser = UserModel(
        id: 'user-123',
        fullName: 'Test Farmer',
        email: 'farmer@test.com',
        phone: '9876543210',
        activeRole: UserRole.farmer,
        grantedRoles: [UserRole.farmer],
      );

      repo.testSetCurrentUser(initialUser);

      // Switch to instructor
      final switchedUser = await repo.switchRole(UserRole.instructor);

      expect(switchedUser.activeRole, equals(UserRole.instructor));
      expect(switchedUser.grantedRoles, contains(UserRole.instructor));
      expect(switchedUser.grantedRoles, contains(UserRole.farmer));

      // Switch back to farmer
      final farmerUser = await repo.switchRole(UserRole.farmer);
      expect(farmerUser.activeRole, equals(UserRole.farmer));
      expect(farmerUser.grantedRoles, contains(UserRole.instructor));
    });
  });

  group('Community Post Delete Author Permission Logic', () {
    bool canDeletePost({
      required UserModel? currentUser,
      required String authorId,
      required String authorName,
    }) {
      final currentUserId = currentUser?.id.toString().trim().toLowerCase() ?? '';
      final currentUserName = currentUser?.fullName.trim().toLowerCase() ?? '';
      final currentUserEmail = currentUser?.email.trim().toLowerCase() ?? '';
      final aId = authorId.trim().toLowerCase();
      final aName = authorName.trim().toLowerCase();

      return (currentUserId.isNotEmpty && aId.isNotEmpty && aId == currentUserId) ||
          (currentUserName.isNotEmpty && aName.isNotEmpty && (aName == currentUserName || aName.contains(currentUserName) || currentUserName.contains(aName))) ||
          (currentUserEmail.isNotEmpty && (currentUserEmail.startsWith(aName) || aName.contains(currentUserEmail.split('@').first))) ||
          (currentUser?.isAdmin == true) ||
          (currentUser?.isInstructor == true);
    }

    test('Author matched by ID can delete post', () {
      const user = UserModel(
        id: '11ac54f5-6b23-45e8-8b12-d5d6f142658c',
        fullName: 'Any Name',
        email: 'any@test.com',
        phone: '123',
        activeRole: UserRole.farmer,
        grantedRoles: [UserRole.farmer],
      );

      expect(canDeletePost(
        currentUser: user,
        authorId: '11ac54f5-6b23-45e8-8b12-d5d6f142658c',
        authorName: 'testinstructor',
      ), isTrue);
    });

    test('Author matched by instructor role can delete post', () {
      const instructorUser = UserModel(
        id: 'diff-id',
        fullName: 'testinstructor',
        email: 'testinstructor@agri.com',
        phone: '123',
        activeRole: UserRole.instructor,
        grantedRoles: [UserRole.instructor],
      );

      expect(canDeletePost(
        currentUser: instructorUser,
        authorId: '11ac54f5-6b23-45e8-8b12-d5d6f142658c',
        authorName: 'testinstructor',
      ), isTrue);
    });
  });
}
