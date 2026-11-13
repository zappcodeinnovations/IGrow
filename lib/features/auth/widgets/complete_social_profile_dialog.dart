import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/app_gradient_button.dart';
import '../../../core/widgets/app_pill_text_field.dart';
import '../../../data/models/user_model.dart';
import '../providers/auth_provider.dart';

/// Provider caching the location mapping {state: [districts]}
final locationsMapProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  try {
    final response = await http.get(
      Uri.parse('https://iagrow.zappcode.in/api/v1/auth/locations/'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final result = <String, List<String>>{};
        decoded.forEach((key, val) {
          if (val is List) {
            result[key] = val.map((e) => e.toString()).toList()..sort();
          }
        });
        return result;
      }
    }
  } catch (e) {
    debugPrint('⚠️ [LocationsProvider] Error fetching locations: $e');
  }
  return const {
    'Maharashtra': [
      'Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Beed', 'Bhandara',
      'Buldhana', 'Chandrapur', 'Dhule', 'Gadchiroli', 'Gondia', 'Hingoli',
      'Jalgaon', 'Jalna', 'Kolhapur', 'Latur', 'Mumbai City', 'Mumbai Suburban',
      'Nagpur', 'Nanded', 'Nandurbar', 'Nashik', 'Osmanabad', 'Palghar',
      'Parbhani', 'Pune', 'Raigad', 'Ratnagiri', 'Sangli', 'Satara',
      'Sindhudurg', 'Solapur', 'Thane', 'Wardha', 'Washim', 'Yavatmal'
    ],
    'Gujarat': [
      'Ahmedabad', 'Amreli', 'Anand', 'Aravalli', 'Banaskantha', 'Bharuch',
      'Bhavnagar', 'Botad', 'Chhota Udaipur', 'Dahod', 'Dang', 'Devbhoomi Dwarka',
      'Gandhinagar', 'Gir Somnath', 'Jamnagar', 'Junagadh', 'Kheda', 'Kutch',
      'Mahisagar', 'Mehsana', 'Morbi', 'Narmada', 'Navsari', 'Panchmahal',
      'Patan', 'Porbandar', 'Rajkot', 'Sabarkantha', 'Surat', 'Surendranagar',
      'Tapi', 'Vadodara', 'Valsad'
    ],
    'Madhya Pradesh': [
      'Agar Malwa', 'Alirajpur', 'Anuppur', 'Ashoknagar', 'Balaghat', 'Barwani',
      'Betul', 'Bhind', 'Bhopal', 'Burhanpur', 'Chhatarpur', 'Chhindwara',
      'Damoh', 'Datia', 'Dewas', 'Dhar', 'Dindori', 'Guna', 'Gwalior',
      'Harda', 'Hoshangabad', 'Indore', 'Jabalpur', 'Jhabua', 'Katni',
      'Khandwa', 'Khargone', 'Mandla', 'Mandsaur', 'Morena', 'Narsinghpur',
      'Neemuch', 'Panna', 'Raisen', 'Rajgarh', 'Ratlam', 'Rewa', 'Sagar',
      'Satna', 'Sehore', 'Seoni', 'Shahdol', 'Shajapur', 'Sheopur', 'Shivpuri',
      'Sidhi', 'Singrauli', 'Tikamgarh', 'Ujjain', 'Umaria', 'Vidisha'
    ],
    'Karnataka': [
      'Bagalkot', 'Ballari', 'Belagavi', 'Bengaluru Rural', 'Bengaluru Urban',
      'Bidar', 'Chamarajanagar', 'Chikkaballapur', 'Chikkamagaluru', 'Chitradurga',
      'Dakshina Kannada', 'Davanagere', 'Dharwad', 'Gadag', 'Hassan', 'Haveri',
      'Kalaburagi', 'Kodagu', 'Kolar', 'Koppal', 'Mandya', 'Mysuru', 'Raichur',
      'Ramanagara', 'Shivamogga', 'Tumakuru', 'Udupi', 'Uttara Kannada',
      'Vijayapura', 'Yadgir'
    ],
    'Punjab': [
      'Amritsar', 'Barnala', 'Bathinda', 'Faridkot', 'Fatehgarh Sahib', 'Fazilka',
      'Ferozepur', 'Gurdaspur', 'Hoshiarpur', 'Jalandhar', 'Kapurthala',
      'Ludhiana', 'Mansa', 'Moga', 'Muktsar', 'Pathankot', 'Patiala', 'Rupnagar',
      'Sahibzada Ajit Singh Nagar', 'Sangrur', 'Shahid Bhagat Singh Nagar', 'Tarn Taran'
    ],
    'Rajasthan': [
      'Ajmer', 'Alwar', 'Banswara', 'Baran', 'Barmer', 'Bharatpur', 'Bhilwara',
      'Bikaner', 'Bundi', 'Chittorgarh', 'Churu', 'Dausa', 'Dholpur', 'Dungarpur',
      'Hanumangarh', 'Jaipur', 'Jaisalmer', 'Jalore', 'Jhalawar', 'Jhunjhunu',
      'Jodhpur', 'Karauli', 'Kota', 'Nagaur', 'Pali', 'Pratapgarh', 'Rajsamand',
      'Sawai Madhopur', 'Sikar', 'Sirohi', 'Sri Ganganagar', 'Tonk', 'Udaipur'
    ],
    'Uttar Pradesh': [
      'Agra', 'Aligarh', 'Prayagraj', 'Ambedkar Nagar', 'Amethi', 'Amroha',
      'Auraiya', 'Ayodhya', 'Azamgarh', 'Baghpat', 'Bahraich', 'Ballia',
      'Balrampur', 'Banda', 'Barabanki', 'Bareilly', 'Basti', 'Bhadohi',
      'Bijnor', 'Budaun', 'Bulandshahr', 'Chandauli', 'Chitrakoot', 'Deoria',
      'Etah', 'Etawah', 'Farrukhabad', 'Fatehpur', 'Firozabad',
      'Gautam Buddha Nagar', 'Ghaziabad', 'Ghazipur', 'Gonda', 'Gorakhpur',
      'Hamirpur', 'Hapur', 'Hardoi', 'Hathras', 'Jalaun', 'Jaunpur', 'Jhansi',
      'Kannauj', 'Kanpur Dehat', 'Kanpur Nagar', 'Kasganj', 'Kaushambi',
      'Kheri', 'Kushinagar', 'Lalitpur', 'Lucknow', 'Maharajganj', 'Mahoba',
      'Mainpuri', 'Mathura', 'Mau', 'Meerut', 'Mirzapur', 'Moradabad',
      'Muzaffarnagar', 'Pilibhit', 'Pratapgarh', 'Raebareli', 'Rampur',
      'Saharanpur', 'Sambhal', 'Sant Kabir Nagar', 'Shahjahanpur', 'Shamli',
      'Shravasti', 'Siddharthnagar', 'Sitapur', 'Sonbhadra', 'Sultanpur',
      'Unnao', 'Varanasi'
    ],
  };
});

/// Modal dialog shown after social login when the user has incomplete profile details.
///
/// Prompts for Phone Number, State, and District.
/// Features a "Skip" button and redirects directly to the appropriate profile page.
class CompleteSocialProfileDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const CompleteSocialProfileDialog({
    super.key,
    required this.user,
  });

  /// Static helper to display the dialog
  static Future<void> show(BuildContext context, UserModel user) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompleteSocialProfileDialog(user: user),
    );
  }

  @override
  ConsumerState<CompleteSocialProfileDialog> createState() =>
      _CompleteSocialProfileDialogState();
}

class _CompleteSocialProfileDialogState
    extends ConsumerState<CompleteSocialProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  String? _selectedState;
  String? _selectedDistrict;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedState = widget.user.locationState?.trim();
    if (_selectedState != null && _selectedState!.isEmpty) {
      _selectedState = null;
    }
    _selectedDistrict = widget.user.locationDistrict?.trim();
    if (_selectedDistrict != null && _selectedDistrict!.isEmpty) {
      _selectedDistrict = null;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _navigateToProfile() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    final destination = widget.user.isFarmer
        ? RouteNames.farmerProfile
        : RouteNames.instructorProfile;
    context.push(destination);
  }

  void _dismissDialog() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _phoneController.text.trim();
    final state = _selectedState?.trim() ?? '';
    final district = _selectedDistrict?.trim() ?? '';

    setState(() => _isSaving = true);

    try {
      final request = PatchedUserProfileRequest(
        phoneNumber: phone.isNotEmpty ? phone : null,
        locationState: state.isNotEmpty ? state : null,
        locationDistrict: district.isNotEmpty ? district : null,
      );

      await ref.read(authProvider.notifier).updateProfile(request);

      if (mounted) {
        AppToast.show(context, tr(ref, 'Profile updated successfully!'));
        _navigateToProfile();
      }
    } catch (e) {
      if (mounted) {
        String msg = tr(ref, 'Failed to update details. You can update them in your profile.');
        if (e is ApiException) {
          if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
            final firstEntry = e.fieldErrors!.entries.first;
            final fieldName = firstEntry.key == 'phone_number' ? tr(ref, 'Phone number') : firstEntry.key;
            final errText = firstEntry.value.isNotEmpty ? firstEntry.value.first : 'Invalid';
            msg = '$fieldName: $errText';
          } else if (e.message.isNotEmpty) {
            msg = e.message;
          }
        }
        AppToast.show(
          context,
          msg,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: keyboardOpen ? 12 : 24,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom -
                  (keyboardOpen ? 32 : 64),
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2822) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? AppColors.lineDark : AppColors.organicBorderLight,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top organic icon badge
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.primaryGreen.withOpacity(0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_pin_circle_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  tr(ref, 'Complete Your Profile'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.greenDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  tr(
                    ref,
                    'Please share your phone number and location so instructors and peers can connect with you.',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.organicSubtitleDark
                        : AppColors.organicSubtitleGreen,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                // Phone Field
                AppPillTextField(
                  controller: _phoneController,
                  hintText: tr(ref, 'Phone Number (10 digits)'),
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    final digitsOnly = (value ?? '').trim().replaceAll(RegExp(r'\D'), '');
                    if (digitsOnly.isNotEmpty) {
                      if (digitsOnly.length != 10) {
                        return tr(ref, 'Phone number must be exactly 10 digits');
                      }
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digitsOnly)) {
                        return tr(ref, 'Enter a valid 10-digit mobile number');
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Dependent State & District Dropdowns
                Consumer(
                  builder: (context, ref, _) {
                    final locationsAsync = ref.watch(locationsMapProvider);

                    return locationsAsync.when(
                      data: (locationsMap) {
                        final statesList = locationsMap.keys.toList()..sort();
                        final availableDistricts = (_selectedState != null && locationsMap.containsKey(_selectedState))
                            ? locationsMap[_selectedState]!
                            : <String>[];

                        // Ensure selected state exists in options
                        final currentStateValue = (_selectedState != null && statesList.contains(_selectedState))
                            ? _selectedState
                            : null;

                        // Ensure selected district exists in available districts
                        final currentDistrictValue = (_selectedDistrict != null && availableDistricts.contains(_selectedDistrict))
                            ? _selectedDistrict
                            : null;

                        return Column(
                          children: [
                            // State Dropdown
                            _buildPillDropdown(
                              context: context,
                              isDark: isDark,
                              hintText: tr(ref, 'Select State'),
                              icon: Icons.map_rounded,
                              value: currentStateValue,
                              items: statesList,
                              onChanged: (val) {
                                setState(() {
                                  _selectedState = val;
                                  _selectedDistrict = null; // Reset dependent district
                                });
                              },
                            ),
                            const SizedBox(height: 14),

                            // District Dropdown
                            _buildPillDropdown(
                              context: context,
                              isDark: isDark,
                              hintText: _selectedState == null
                                  ? tr(ref, 'Select State first')
                                  : tr(ref, 'Select District / City'),
                              icon: Icons.location_city_rounded,
                              value: currentDistrictValue,
                              items: availableDistricts,
                              isEnabled: _selectedState != null && availableDistricts.isNotEmpty,
                              onChanged: (val) {
                                setState(() {
                                  _selectedDistrict = val;
                                });
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => Column(
                        children: [
                          _buildPillDropdown(
                            context: context,
                            isDark: isDark,
                            hintText: tr(ref, 'Loading states...'),
                            icon: Icons.map_rounded,
                            items: const [],
                            isEnabled: false,
                          ),
                          const SizedBox(height: 14),
                          _buildPillDropdown(
                            context: context,
                            isDark: isDark,
                            hintText: tr(ref, 'Select District / City'),
                            icon: Icons.location_city_rounded,
                            items: const [],
                            isEnabled: false,
                          ),
                        ],
                      ),
                      error: (_, __) => Column(
                        children: [
                          _buildPillDropdown(
                            context: context,
                            isDark: isDark,
                            hintText: tr(ref, 'Select State'),
                            icon: Icons.map_rounded,
                            value: _selectedState,
                            items: const ['Maharashtra', 'Gujarat', 'Madhya Pradesh', 'Punjab', 'Rajasthan', 'Uttar Pradesh'],
                            onChanged: (val) => setState(() => _selectedState = val),
                          ),
                          const SizedBox(height: 14),
                          _buildPillDropdown(
                            context: context,
                            isDark: isDark,
                            hintText: tr(ref, 'Select District / City'),
                            icon: Icons.location_city_rounded,
                            value: _selectedDistrict,
                            items: const ['Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Ahmednagar'],
                            onChanged: (val) => setState(() => _selectedDistrict = val),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Primary Action Button: Save & Continue
                AppGradientButton(
                  label: tr(ref, 'Save & Continue'),
                  isLoading: _isSaving,
                  onPressed: _isSaving ? () {} : () => _saveAndContinue(),
                ),
                const SizedBox(height: 12),

                // Secondary Action: Skip for now
                TextButton(
                  onPressed: _isSaving ? null : _dismissDialog,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    tr(ref, 'Skip for Now'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.organicSubtitleDark
                          : AppColors.organicSubtitleGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
  );
  }

  Widget _buildPillDropdown({
    required BuildContext context,
    required bool isDark,
    required String hintText,
    required IconData icon,
    required List<String> items,
    String? value,
    ValueChanged<String?>? onChanged,
    bool isEnabled = true,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled && items.isNotEmpty
            ? () => _showLocationSelectionSheet(
                  context: context,
                  isDark: isDark,
                  title: hintText,
                  icon: icon,
                  items: items,
                  selectedValue: value,
                  onSelected: (val) {
                    if (onChanged != null) onChanged(val);
                  },
                )
            : null,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? AppColors.organicCardDark : AppColors.organicCardLight,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppColors.organicBorderDark : AppColors.organicBorderLight,
              width: 1.2,
            ),
            boxShadow: AppColors.organicCardShadow(isDark: isDark),
          ),
          child: Row(
            children: [
              const SizedBox(width: 9),
              // Circular Badge for Leading Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.organicBadgeDark : AppColors.organicBadgeLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 19,
                    color: isEnabled
                        ? (isDark ? AppColors.organicIconDark : AppColors.organicIconLight)
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Label / Selected Text
              Expanded(
                child: Text(
                  hasValue ? tr(ref, value) : hintText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    color: hasValue
                        ? (isDark ? Colors.white : const Color(0xFF1B331F))
                        : (isDark ? AppColors.organicHintDark : AppColors.organicHintLight),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Trailing chevron indicator
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isEnabled
                      ? (isDark ? Colors.grey.shade400 : AppColors.organicIconLight)
                      : Colors.grey.shade400,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationSelectionSheet({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _LocationPickerBottomSheet(
          isDark: isDark,
          title: title,
          icon: icon,
          items: items,
          selectedValue: selectedValue,
          onSelected: onSelected,
        );
      },
    );
  }
}

class _LocationPickerBottomSheet extends StatefulWidget {
  const _LocationPickerBottomSheet({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  final bool isDark;
  final String title;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  State<_LocationPickerBottomSheet> createState() => _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState extends State<_LocationPickerBottomSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((it) {
      final translated = AppStrings.tr(it, languageCode: 'en'); // Check fallback or key
      return it.toLowerCase().contains(_query.toLowerCase().trim()) ||
          AppStrings.tr(it, languageCode: 'hi').toLowerCase().contains(_query.toLowerCase().trim()) ||
          AppStrings.tr(it, languageCode: 'mr').toLowerCase().contains(_query.toLowerCase().trim());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E2822) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.5 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pull Handle Indicator
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Sheet Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.isDark ? AppColors.organicBadgeDark : AppColors.organicBadgeLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isDark ? AppColors.organicIconDark : AppColors.organicIconLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: widget.isDark ? Colors.white70 : AppColors.inkSoft,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Single Clean Search Input Field (No nested cards/boxes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Consumer(
                builder: (context, searchRef, _) => TextField(
                  controller: _searchController,
                  autofocus: false,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark ? Colors.white : AppColors.inkDark,
                  ),
                  decoration: InputDecoration(
                    hintText: tr(searchRef, 'Search...'),
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: widget.isDark ? Colors.white38 : AppColors.inkSoft,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: widget.isDark ? Colors.grey.shade400 : AppColors.organicIconLight,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: widget.isDark ? Colors.white60 : Colors.grey.shade600,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF3F7F3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: widget.isDark ? AppColors.lineDark : const Color(0xFFE2EBE0),
                        width: 1.2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: widget.isDark ? AppColors.lineDark : const Color(0xFFE2EBE0),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGreen,
                        width: 1.6,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _query = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 1,
              color: widget.isDark ? AppColors.lineDark : const Color(0xFFF0F4F0),
            ),

            // Scrollable List of Options
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 38,
                            color: widget.isDark ? Colors.white24 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, emptyRef, _) => Text(
                              tr(emptyRef, 'No matches found'),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: widget.isDark ? Colors.white38 : AppColors.inkSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: filtered.length,
                      itemBuilder: (itemCtx, index) {
                        final item = filtered[index];
                        final isSelected = item == widget.selectedValue;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSelected(item);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (widget.isDark
                                        ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                        : const Color(0xFFE8F5E9))
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Consumer(
                                      builder: (context, itemRef, _) => Text(
                                        tr(itemRef, item),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: isSelected
                                              ? (widget.isDark ? const Color(0xFF4ADE80) : AppColors.primaryGreen)
                                              : (widget.isDark ? Colors.white : AppColors.inkDark),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 19,
                                      color: widget.isDark ? const Color(0xFF4ADE80) : AppColors.primaryGreen,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
