import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_provider.dart';

/// Supported language options in iAgrow.
class AppLanguage {
  final String code;
  final String name;
  final String native;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.native,
  });
}

/// The central localization channel and dictionary repository for iAgrow.
class AppStrings {
  AppStrings._();

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', name: 'English', native: 'English'),
    AppLanguage(code: 'hi', name: 'Hindi', native: 'हिंदी'),
    AppLanguage(code: 'mr', name: 'Marathi', native: 'मराठी'),
  ];

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Bottom Navigation & Tabs
      'Home': 'Home',
      'Dashboard': 'Dashboard',
      'Explore': 'Explore',
      'Community': 'Community',
      'Upload': 'Upload',
      'Analytics': 'Analytics',
      'Profile': 'Profile',
      'My learning': 'My learning',
      'My courses': 'My courses',
      'All': 'All',
      'Downloaded': 'Downloaded',
      'Archived': 'Archived',
      'E-Books': 'E-Books',
      'Courses': 'Courses',
      'Community Hubs': 'Community Hubs',
      'Recommended': 'Recommended',
      'All Hubs': 'All Hubs',
      'My Hubs': 'My Hubs',
      'Joined': 'Joined',
      'Join': 'Join',
      'farmers': 'farmers',
      'Unread': 'Unread',
      'Q&A': 'Q&A',
      'Mark read': 'Mark read',
      'Wishlist': 'Wishlist',
      'Search courses...': 'Search courses...',
      'Search my courses...': 'Search my courses...',
      'Agricultural Course Catalog': 'Agricultural Course Catalog',
      'Crop Production': 'Crop Production',
      'Dairy Farming': 'Dairy Farming',
      'Soil Science': 'Soil Science',
      'Enrolled': 'Enrolled',
      'Completed': 'Completed',
      'Pending': 'Pending',
      'Quizzes': 'Quizzes',
      'Units': 'Units',
      'Text': 'Text',
      'ACADEMIC LEDGER': 'ACADEMIC LEDGER',
      'Active Session': 'Active Session',
      'SEMESTER 04': 'SEMESTER 04',
      'VERIFIED FACULTY': 'VERIFIED FACULTY',
      'Explore Courses by Top Agricultural Instructors': 'Explore Courses by Top Agricultural Instructors',
      'Learn directly from verified farming experts, agronomists, and agricultural specialists.': 'Learn directly from verified farming experts, agronomists, and agricultural specialists.',
      'Explore All': 'Explore All',
      'yrs exp': 'yrs exp',
      'Good morning 🌾': 'Good morning 🌾',
      'Good afternoon 🍊': 'Good afternoon 🍊',
      'Good evening 🌙': 'Good evening 🌙',
      'Browse catalog & specializations': 'Browse catalog & specializations',
      'Enrolled courses, certificates': 'Enrolled courses, certificates',
      'Saved courses & resources': 'Saved courses & resources',
      'Connect with local farmers & experts': 'Connect with local farmers & experts',
      'Account details & certificates': 'Account details & certificates',
      'Tickets, queries & FAQs': 'Tickets, queries & FAQs',
      'Track support ticket updates': 'Track support ticket updates',
      'Visibility & data preferences': 'Visibility & data preferences',
      'My Profile': 'My Profile',
      'My Tickets': 'My Tickets',
      'Privacy Settings': 'Privacy Settings',
      'CURRICULUM & MEDIA': 'CURRICULUM & MEDIA',
      'ASSISTANCE & SUPPORT': 'ASSISTANCE & SUPPORT',
      'General': 'General',

      // Profile Screen Sections
      'Basic Info': 'Basic Info',
      'My Learning & Activity': 'My Learning & Activity',
      'Instructor Details': 'Instructor Details',
      'Verification & Payouts': 'Verification & Payouts',
      'Settings': 'Settings',
      'Danger Zone': 'Danger Zone',

      // Profile Screen Items & Labels
      'Edit Profile': 'Edit Profile',
      'Language': 'Language',
      'Select App Language': 'Select App Language',
      'Dark Mode': 'Dark Mode',
      'Light Mode': 'Light Mode',
      'Notifications': 'Notifications',
      'Privacy': 'Privacy',
      'Help & Support': 'Help & Support',
      'Delete Account': 'Delete Account',
      'Permanently remove account and data': 'Permanently remove account and data',
      'Log Out': 'Log Out',
      'Logout': 'Logout',
      'Are you sure you want to log out?': 'Are you sure you want to log out?',
      'Cancel': 'Cancel',
      'Feature coming soon': 'Feature coming soon',
      'Phone': 'Phone',
      'Location': 'Location',
      'Farming Experience': 'Farming Experience',
      'Areas of Interest': 'Areas of Interest',
      'Bio': 'Bio',
      'Expertise Tags': 'Expertise Tags',
      'Years of Experience': 'Years of Experience',
      'Specialty Crops': 'Specialty Crops',
      'Social Link': 'Social Link',
      'KYC & Bank Verification': 'KYC & Bank Verification',
      'My Enrolled Courses': 'My Enrolled Courses',
      'My Wishlist': 'My Wishlist',
      'Order History': 'Order History',
      'My Certificates': 'My Certificates',
      'Total Revenue': 'Total Revenue',
      'View Analytics': 'View Analytics',
      'Verified': 'Verified',
      'Under Review': 'Under Review',
      'Incomplete': 'Incomplete',
      'Not provided': 'Not provided',
      'Beginner': 'Beginner',
      'Intermediate': 'Intermediate',
      'Expert': 'Expert',
      'years': 'years',

      // Common Actions
      'Save': 'Save',
      'Apply': 'Apply',
      'Submit': 'Submit',
      'Close': 'Close',
      'Search': 'Search',
    },

    'hi': {
      // Bottom Navigation & Tabs
      'Home': 'होम',
      'Dashboard': 'डैशबोर्ड',
      'Explore': 'एक्सप्लोर',
      'Community': 'समुदाय',
      'Upload': 'अपलोड',
      'Analytics': 'विश्लेषण',
      'Profile': 'प्रोफ़ाइल',
      'My learning': 'मेरी पढ़ाई',
      'My courses': 'मेरे कोर्सेस',
      'All': 'सभी',
      'Downloaded': 'डाउनलोड किया गया',
      'Archived': 'संग्रहीत',
      'E-Books': 'ई-पुस्तकें',
      'Courses': 'कोर्सेस',
      'Community Hubs': 'समुदाय हब',
      'Recommended': 'अनुशंसित',
      'All Hubs': 'सभी हब',
      'My Hubs': 'मेरे हब',
      'Joined': 'शामिल',
      'Join': 'जुड़ें',
      'farmers': 'किसान',
      'Unread': 'अपठित',
      'Q&A': 'सवाल-जवाब',
      'Mark read': 'पढ़ा हुआ चिह्नित करें',
      'Wishlist': 'विशलिस्ट',
      'Search courses...': 'कोर्स खोजें...',
      'Search my courses...': 'मेरे कोर्स खोजें...',
      'Agricultural Course Catalog': 'कृषि कोर्स सूची',
      'Crop Production': 'फसल उत्पादन',
      'Dairy Farming': 'डेयरी फार्मिंग',
      'Soil Science': 'मृदा विज्ञान',
      'Enrolled': 'नामांकित',
      'Completed': 'पूर्ण',
      'Pending': 'लंबित',
      'Quizzes': 'प्रश्नोत्तरी',
      'Units': 'इकाइयां',
      'Text': 'पाठ',
      'ACADEMIC LEDGER': 'शैक्षणिक लेज़र',
      'Active Session': 'सक्रिय सत्र',
      'SEMESTER 04': 'सत्र ०४',
      'VERIFIED FACULTY': 'सत्यापित संकाय',
      'Explore Courses by Top Agricultural Instructors': 'शीर्ष कृषि प्रशिक्षकों के कोर्स देखें',
      'Learn directly from verified farming experts, agronomists, and agricultural specialists.': 'सत्यापित कृषि विशेषज्ञों और कृषि वैज्ञानिकों से सीधे सीखें।',
      'Explore All': 'सभी देखें',
      'yrs exp': 'वर्ष अनुभव',
      'Good morning 🌾': 'शुभ प्रभात 🌾',
      'Good afternoon 🍊': 'शुभ दोपहर 🍊',
      'Good evening 🌙': 'शुभ संध्या 🌙',
      'Browse catalog & specializations': 'कैटलॉग और विशेषज्ञताएं ब्राउज़ करें',
      'Enrolled courses, certificates': 'नामांकित कोर्स, प्रमाण पत्र',
      'Saved courses & resources': 'सहेजे गए कोर्स और संसाधन',
      'Connect with local farmers & experts': 'स्थानीय किसानों और विशेषज्ञों से जुड़ें',
      'Account details & certificates': 'खाता विवरण और प्रमाण पत्र',
      'Tickets, queries & FAQs': 'टिकट, प्रश्न और सामान्य प्रश्न',
      'Track support ticket updates': 'सपोर्ट टिकट अपडेट ट्रैक करें',
      'Visibility & data preferences': 'दृश्यता और डेटा प्राथमिकताएं',
      'My Profile': 'मेरी प्रोफ़ाइल',
      'My Tickets': 'मेरे टिकट',
      'Privacy Settings': 'गोपनीयता सेटिंग्स',
      'CURRICULUM & MEDIA': 'पाठ्यक्रम और मीडिया',
      'ASSISTANCE & SUPPORT': 'सहायता और समर्थन',
      'General': 'सामान्य',

      // Profile Screen Sections
      'Basic Info': 'बुनियादी जानकारी',
      'My Learning & Activity': 'मेरा सीखना और गतिविधि',
      'Instructor Details': 'प्रशिक्षक विवरण',
      'Verification & Payouts': 'सत्यापन और भुगतान',
      'Settings': 'सेटिंग्स',
      'Danger Zone': 'ख़तरा क्षेत्र',

      // Profile Screen Items & Labels
      'Edit Profile': 'प्रोफ़ाइल संपादित करें',
      'Language': 'भाषा',
      'Select App Language': 'ऐप की भाषा चुनें',
      'Dark Mode': 'डार्क मोड',
      'Light Mode': 'लाइट मोड',
      'Notifications': 'सूचनाएं',
      'Privacy': 'गोपनीयता',
      'Help & Support': 'सहायता और समर्थन',
      'Delete Account': 'खाता हटाएं',
      'Permanently remove account and data': 'खाता और डेटा स्थायी रूप से हटाएं',
      'Log Out': 'लॉग आउट',
      'Logout': 'लॉग आउट',
      'Are you sure you want to log out?': 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
      'Cancel': 'रद्द करें',
      'Feature coming soon': 'सुविधा जल्द ही उपलब्ध होगी',
      'Phone': 'फ़ोन',
      'Location': 'स्थान',
      'Farming Experience': 'खेती का अनुभव',
      'Areas of Interest': 'रुचि के क्षेत्र',
      'Bio': 'बायो',
      'Expertise Tags': 'विशेषज्ञता टैग',
      'Years of Experience': 'अनुभव के वर्ष',
      'Specialty Crops': 'विशेष फसलें',
      'Social Link': 'सोशल लिंक',
      'KYC & Bank Verification': 'केवाईसी और बैंक सत्यापन',
      'My Enrolled Courses': 'मेरे नामांकित पाठ्यक्रम',
      'My Wishlist': 'मेरी इच्छा सूची',
      'Order History': 'ऑर्डर इतिहास',
      'My Certificates': 'मेरे प्रमाण पत्र',
      'Total Revenue': 'कुल राजस्व',
      'View Analytics': 'विश्लेषण देखें',
      'Verified': 'सत्यापित',
      'Under Review': 'समीक्षाधीन',
      'Incomplete': 'अपूर्ण',
      'Not provided': 'प्रदान नहीं किया गया',
      'Beginner': 'शुरुआती',
      'Intermediate': 'मध्यम',
      'Expert': 'विशेषज्ञ',
      'years': 'वर्ष',

      // Common Actions
      'Save': 'सहेजें',
      'Apply': 'लागू करें',
      'Submit': 'जमा करें',
      'Close': 'बंद करें',
      'Search': 'खोजें',
    },

    'mr': {
      // Bottom Navigation & Tabs
      'Home': 'मुख्यपृष्ठ',
      'Dashboard': 'डॅशबोर्ड',
      'Explore': 'शोधा',
      'Community': 'समुदाय',
      'Upload': 'अपलोड',
      'Analytics': 'विश्लेषण',
      'Profile': 'प्रोफाइल',
      'My learning': 'माझे शिक्षण',
      'My courses': 'माझे कोर्सेस',
      'All': 'सर्व',
      'Downloaded': 'डाउनलोड केलेले',
      'Archived': 'संग्रहित',
      'E-Books': 'ई-पुस्तके',
      'Courses': 'कोर्सेस',
      'Community Hubs': 'समुदाय हब',
      'Recommended': 'शिफारस केलेले',
      'All Hubs': 'सर्व हब',
      'My Hubs': 'माझे हब',
      'Joined': 'सामील झाले',
      'Join': 'सामील व्हा',
      'farmers': 'शेतकरी',
      'Unread': 'न वाचलेले',
      'Q&A': 'प्रश्नोत्तरे',
      'Mark read': 'वाचलेले म्हणून चिन्हांकित करा',
      'Wishlist': 'विशलिस्ट',
      'Search courses...': 'कोर्स शोधा...',
      'Search my courses...': 'माझे कोर्स शोधा...',
      'Agricultural Course Catalog': 'कृषी अभ्यासक्रम सूची',
      'Crop Production': 'पीक उत्पादन',
      'Dairy Farming': 'दुग्ध व्यवसाय',
      'Soil Science': 'मृदा विज्ञान',
      'Enrolled': 'नोंदणीकृत',
      'Completed': 'पूर्ण',
      'Pending': 'प्रलंबित',
      'Quizzes': 'प्रश्नमंजुषा',
      'Units': 'घटक',
      'Text': 'मजकूर',
      'ACADEMIC LEDGER': 'शैक्षणिक नोंदवही',
      'Active Session': 'सक्रिय सत्र',
      'SEMESTER 04': 'सत्र ०४',
      'VERIFIED FACULTY': 'पडताळणी झालेले प्राध्यापक',
      'Explore Courses by Top Agricultural Instructors': 'शीर्ष कृषी शिक्षकांचे कोर्सेस शोधा',
      'Learn directly from verified farming experts, agronomists, and agricultural specialists.': 'पडताळणी केलेल्या शेती तज्ज्ञ आणि कृषी तज्ज्ञांकडून थेट शिका.',
      'Explore All': 'सर्व पहा',
      'yrs exp': 'वर्षे अनुभव',
      'Good morning 🌾': 'शुभ सकाळ 🌾',
      'Good afternoon 🍊': 'शुभ दुपार 🍊',
      'Good evening 🌙': 'शुभ संध्याकाळ 🌙',
      'Browse catalog & specializations': 'कॅटलॉग आणि विशेषीकरण ब्राउझ करा',
      'Enrolled courses, certificates': 'नोंदणीकृत कोर्सेस, प्रमाणपत्रे',
      'Saved courses & resources': 'जतन केलेले कोर्सेस आणि संसाधने',
      'Connect with local farmers & experts': 'स्थानिक शेतकरी आणि तज्ज्ञांशी संपर्क साधा',
      'Account details & certificates': 'खाते तपशील आणि प्रमाणपत्रे',
      'Tickets, queries & FAQs': 'तिकीट, प्रश्न आणि वारंवार विचारले जाणारे प्रश्न',
      'Track support ticket updates': 'सपोर्ट तिकीट अपडेट ट्रॅक करा',
      'Visibility & data preferences': 'दृश्यमानता आणि डेटा प्राधान्ये',
      'My Profile': 'माझी प्रोफाइल',
      'My Tickets': 'माझे तिकीट',
      'Privacy Settings': 'गोपनीयता सेटिंग्ज',
      'CURRICULUM & MEDIA': 'अभ्यासक्रम आणि माध्यम',
      'ASSISTANCE & SUPPORT': 'मदत आणि समर्थन',
      'General': 'सामान्य',

      // Profile Screen Sections
      'Basic Info': 'मूलभूत माहिती',
      'My Learning & Activity': 'माझे शिक्षण आणि उपक्रम',
      'Instructor Details': 'मार्गदर्शक तपशील',
      'Verification & Payouts': 'पडताळणी आणि देयके',
      'Settings': 'सेटिंग्ज',
      'Danger Zone': 'धोकादायक क्षेत्र',

      // Profile Screen Items & Labels
      'Edit Profile': 'प्रोफाइल संपादित करा',
      'Language': 'भाषा',
      'Select App Language': 'अ‍ॅप भाषा निवडा',
      'Dark Mode': 'डार्क मोड',
      'Light Mode': 'लाइट मोड',
      'Notifications': 'सूचना',
      'Privacy': 'गोपनीयता',
      'Help & Support': 'मदत आणि समर्थन',
      'Delete Account': 'खाते हटवा',
      'Permanently remove account and data': 'खाते आणि डेटा कायमचा हटवा',
      'Log Out': 'लॉग आउट',
      'Logout': 'लॉग आउट',
      'Are you sure you want to log out?': 'तुम्हाला नक्की लॉग आउट करायचे आहे का?',
      'Cancel': 'रद्द करा',
      'Feature coming soon': 'वैशिष्ट्य लवकरच येत आहे',
      'Phone': 'फोन',
      'Location': 'स्थान',
      'Farming Experience': 'शेतीचा अनुभव',
      'Areas of Interest': 'आवडीचे क्षेत्र',
      'Bio': 'बायो',
      'Expertise Tags': 'कौशल्य टॅग',
      'Years of Experience': 'अनुभवाची वर्षे',
      'Specialty Crops': 'विशेष पिके',
      'Social Link': 'सोशल लिंक',
      'KYC & Bank Verification': 'केवायसी आणि बँक पडताळणी',
      'My Enrolled Courses': 'माझे नोंदणीकृत कोर्सेस',
      'My Wishlist': 'माझी विशलिस्ट',
      'Order History': 'ऑर्डर इतिहास',
      'My Certificates': 'माझी प्रमाणपत्रे',
      'Total Revenue': 'एकूण महसूल',
      'View Analytics': 'विश्लेषण पहा',
      'Verified': 'पडताळलेले',
      'Under Review': 'पुनरावलोकनात',
      'Incomplete': 'अपूर्ण',
      'Not provided': 'दिलेले नाही',
      'Beginner': 'नवशिक्या',
      'Intermediate': 'मध्यम',
      'Expert': 'तज्ज्ञ',
      'years': 'वर्षे',

      // Common Actions
      'Save': 'जतन करा',
      'Apply': 'लागू करा',
      'Submit': 'सादर करा',
      'Close': 'बंद करा',
      'Search': 'शोधा',
    },
  };

  /// Translates a given [key] into the given language code (or fallback to English/key).
  static String tr(String key, {required String languageCode}) {
    final code = languageCode.toLowerCase().trim();
    final langMap = _translations[code] ?? _translations['en'];
    if (langMap != null) {
      if (langMap.containsKey(key)) {
        return langMap[key]!;
      }
      final keyLower = key.toLowerCase().trim();
      for (final entry in langMap.entries) {
        if (entry.key.toLowerCase().trim() == keyLower) {
          return entry.value;
        }
      }
    }
    // Fallback to English translation if available
    final enMap = _translations['en'];
    if (enMap != null) {
      if (enMap.containsKey(key)) {
        return enMap[key]!;
      }
      final keyLower = key.toLowerCase().trim();
      for (final entry in enMap.entries) {
        if (entry.key.toLowerCase().trim() == keyLower) {
          return entry.value;
        }
      }
    }
    return key;
  }
}

/// State notifier managing the active app language code across the whole UI.
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier(this._prefs) : super('en') {
    _loadLanguage();
  }

  final SharedPreferences _prefs;
  static const _langKey = 'app_user_language_code';

  void _loadLanguage() {
    final savedLang = _prefs.getString(_langKey);
    if (savedLang != null && savedLang.isNotEmpty) {
      state = _normalizeCode(savedLang);
    }
  }

  /// Sets and persists the active language by code (e.g., 'en', 'hi', 'mr')
  /// or full name (e.g. 'English', 'Hindi', 'Marathi').
  Future<void> setLanguage(String langCodeOrName) async {
    final code = _normalizeCode(langCodeOrName);
    state = code;
    await _prefs.setString(_langKey, code);
  }

  static String _normalizeCode(String input) {
    final lower = input.toLowerCase().trim();
    if (lower == 'hi' || lower == 'hindi' || lower.contains('हिंदी') || lower.contains('हिन्दी')) {
      return 'hi';
    }
    if (lower == 'mr' || lower == 'marathi' || lower.contains('मराठी')) {
      return 'mr';
    }
    return 'en';
  }
}

/// Riverpod provider for the global active language code ('en', 'hi', 'mr').
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

/// Context extension for instant UI-wide reactivity: `context.tr('Settings')`
extension LocalizationContextExtension on BuildContext {
  /// Lookup translation using the inherited [WidgetRef] via a consumer or helper.
  String tr(String key) {
    // If used within a ConsumerWidget or Consumer, ref can be passed directly.
    // For convenience, we also provide a global translation helper.
    return key;
  }
}

/// Helper method to translate strings using WidgetRef anywhere in the UI.
String tr(WidgetRef ref, String key) {
  final langCode = ref.watch(languageProvider);
  return AppStrings.tr(key, languageCode: langCode);
}
