import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows a custom, polished 12-hour AM/PM time picker modal sheet or themed dialog
/// that enforces 12-hour format across all devices (ignoring system 24-hour preference).
Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
}) async {
  final now = initialTime ?? const TimeOfDay(hour: 10, minute: 0);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return await showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) => _AppTimePickerSheet(
      initialTime: now,
      isDark: isDark,
    ),
  );
}

class _AppTimePickerSheet extends StatefulWidget {
  const _AppTimePickerSheet({
    required this.initialTime,
    required this.isDark,
  });

  final TimeOfDay initialTime;
  final bool isDark;

  @override
  State<_AppTimePickerSheet> createState() => _AppTimePickerSheetState();
}

class _AppTimePickerSheetState extends State<_AppTimePickerSheet> {
  late int _hour12;
  late int _minute;
  late bool _isAm;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _isAm = hour < 12;
    _hour12 = hour % 12;
    if (_hour12 == 0) _hour12 = 12;

    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay _buildSelectedTime() {
    int hour24;
    if (_isAm) {
      hour24 = _hour12 == 12 ? 0 : _hour12;
    } else {
      hour24 = _hour12 == 12 ? 12 : _hour12 + 12;
    }
    return TimeOfDay(hour: hour24, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? AppColors.cardDark : Colors.white;
    final primaryColor = AppColors.primaryGreen;
    final textColor = widget.isDark ? Colors.white : AppColors.inkDark;
    final softTextColor = widget.isDark ? Colors.white60 : AppColors.inkSoft;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.access_time_rounded, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                // AM / PM Pill Selector
                Container(
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAmPmTab('AM', _isAm),
                      _buildAmPmTab('PM', !_isAm),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Time Pickers (Wheel / Scroll selectors)
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center selection highlight band
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: widget.isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours Wheel (1 - 12)
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _hourController,
                          itemExtent: 44,
                          perspective: 0.003,
                          diameterRatio: 1.3,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _hour12 = index + 1;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 12,
                            builder: (context, index) {
                              final h = index + 1;
                              final isSelected = h == _hour12;
                              return Center(
                                child: Text(
                                  h.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? primaryColor : softTextColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Colon separator
                      Text(
                        ':',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),

                      // Minutes Wheel (00 - 59)
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _minuteController,
                          itemExtent: 44,
                          perspective: 0.003,
                          diameterRatio: 1.3,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _minute = index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 60,
                            builder: (context, index) {
                              final isSelected = index == _minute;
                              return Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? primaryColor : softTextColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm / Cancel Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: softTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, _buildSelectedTime());
                    },
                    child: const Text(
                      'Confirm Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAmPmTab(String text, bool active) {
    return GestureDetector(
      onTap: () {
        if (!active) {
          setState(() {
            _isAm = text == 'AM';
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: active
                ? Colors.white
                : (widget.isDark ? Colors.white60 : AppColors.inkSoft),
          ),
        ),
      ),
    );
  }
}

