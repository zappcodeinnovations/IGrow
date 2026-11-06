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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
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
    return Container(
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
          // Dropdown
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: isDark ? Colors.grey.shade400 : AppColors.organicIconLight,
                    size: 26,
                  ),
                ),
                hint: Text(
                  hintText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.organicHintDark : AppColors.organicHintLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1B331F),
                ),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1B331F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: isEnabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
