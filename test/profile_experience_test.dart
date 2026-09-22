import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/features/profile/screens/edit_profile_screen.dart';

void main() {
  group('Farming Experience Mapping Tests', () {
    test('entering "10" maps to EXPERT string choice', () {
      expect(formatFarmingExperienceForApi('10'), 'EXPERT');
    });

    test('entering "10 years" maps to EXPERT string choice', () {
      expect(formatFarmingExperienceForApi('10 years'), 'EXPERT');
    });

    test('entering "5" maps to INTERMEDIATE string choice', () {
      expect(formatFarmingExperienceForApi('5'), 'INTERMEDIATE');
    });

    test('entering "1" or "2" maps to BEGINNER string choice', () {
      expect(formatFarmingExperienceForApi('1'), 'BEGINNER');
      expect(formatFarmingExperienceForApi('2'), 'BEGINNER');
    });

    test('entering textual choices directly maps correctly', () {
      expect(formatFarmingExperienceForApi('Beginner'), 'BEGINNER');
      expect(formatFarmingExperienceForApi('Intermediate'), 'INTERMEDIATE');
      expect(formatFarmingExperienceForApi('Expert'), 'EXPERT');
    });

    test('empty or null returns null', () {
      expect(formatFarmingExperienceForApi(''), isNull);
      expect(formatFarmingExperienceForApi('   '), isNull);
      expect(formatFarmingExperienceForApi(null), isNull);
    });
  });
}
