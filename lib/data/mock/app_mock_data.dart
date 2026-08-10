import '../../core/network/api_client.dart';

/// Centralized repository for high-quality mock data used across the app
/// when an API fails or returns an empty state.
class AppMockData {
  
  /// Mock Featured Courses for Farmer Home Screen
  static List<CourseList> getFeaturedCourses() {
    return [
      CourseList(
        id: 'mock-1',
        title: 'Modern Organic Farming Techniques',
        shortDescription: 'Learn step-by-step methods for sustainable and chemical-free farming.',
        thumbnail: 'https://images.unsplash.com/photo-1592982537447-6f2a6a0a0d95?q=80&w=600&auto=format&fit=crop',
        price: '1499.00',
      ),
      CourseList(
        id: 'mock-2',
        title: 'Smart Irrigation Masterclass',
        shortDescription: 'Maximize yield with minimum water. A guide to drip and sprinkler systems.',
        thumbnail: 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?q=80&w=600&auto=format&fit=crop',
        price: '899.00',
      ),
      CourseList(
        id: 'mock-3',
        title: 'Soil Health & Crop Rotation',
        shortDescription: 'Understand soil biomes to significantly boost your harvest quality.',
        thumbnail: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?q=80&w=600&auto=format&fit=crop',
        price: '1200.00',
      ),
      CourseList(
        id: 'mock-4',
        title: 'Livestock Management Basics',
        shortDescription: 'Essential guide for dairy and poultry farming for beginners.',
        thumbnail: 'https://images.unsplash.com/photo-1516467508483-a7212febe31a?q=80&w=600&auto=format&fit=crop',
        price: '0.00',
      ),
    ];
  }

  /// Mock Enrollments for Farmer Home Screen
  static List<Enrollment> getEnrollments() {
    return [
      Enrollment(
        id: 'enr-1',
        course: 'mock-1',
        courseTitle: 'Modern Organic Farming Techniques',
        completionPercentage: 65.0,
      ),
      Enrollment(
        id: 'enr-2',
        course: 'mock-2',
        courseTitle: 'Smart Irrigation Masterclass',
        completionPercentage: 12.0,
      ),
    ];
  }

  /// Mock Revenue Stats for Instructor Home Screen
  static Map<String, dynamic> getInstructorStats() {
    return {
      'total_earnings': '45,280',
      'total_students': 1247,
      'total_courses': 8,
      'average_rating': 4.7,
    };
  }

  /// Mock Courses for Instructor Course Performance
  static List<CourseList> getInstructorCourses() {
    return [
      CourseList(
        id: 'inst-1',
        title: 'Advanced Hydroponics System setup',
        price: '2499.00',
        enrollmentCount: '412',
      ),
      CourseList(
        id: 'inst-2',
        title: 'Commercial Dairy Farming',
        price: '3999.00',
        enrollmentCount: '280',
      ),
      CourseList(
        id: 'inst-3',
        title: 'Pest Control Essentials',
        price: '0.00',
        enrollmentCount: '890',
      ),
    ];
  }
}
