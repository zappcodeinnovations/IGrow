import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_colors.dart';

/// Reusable full-featured image editor providing 90° rotation,
/// free-form and fixed aspect ratio cropping, and high-fidelity PNG export.
class ImageCropRotateScreen extends StatefulWidget {
  final File imageFile;
  final String title;
  final double? initialAspectRatio;
  final bool allowFreeCrop;

  const ImageCropRotateScreen({
    super.key,
    required this.imageFile,
    this.title = 'Crop & Rotate',
    this.initialAspectRatio,
    this.allowFreeCrop = true,
  });

  /// Opens the Crop & Rotate screen and returns the edited [File],
  /// or null if the user cancelled without saving.
  static Future<File?> cropAndRotate(
    BuildContext context, {
    required File imageFile,
    String title = 'Crop & Rotate',
    double? initialAspectRatio,
    bool allowFreeCrop = true,
  }) async {
    return Navigator.of(context).push<File>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageCropRotateScreen(
          imageFile: imageFile,
          title: title,
          initialAspectRatio: initialAspectRatio,
          allowFreeCrop: allowFreeCrop,
        ),
      ),
    );
  }

  @override
  State<ImageCropRotateScreen> createState() => _ImageCropRotateScreenState();
}

class _ImageCropRotateScreenState extends State<ImageCropRotateScreen> {
  late final CropController _controller;
  double? _currentAspectRatio;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentAspectRatio = widget.initialAspectRatio;
    _controller = CropController(
      aspectRatio: _currentAspectRatio,
      defaultCrop: const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    try {
      _controller.rotation = CropRotation.up;
      _controller.aspectRatio = widget.initialAspectRatio;
      _controller.crop = const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95);
    } catch (_) {}
    setState(() {
      _currentAspectRatio = widget.initialAspectRatio;
    });
  }

  void _setAspectRatio(double? ratio) {
    setState(() {
      _currentAspectRatio = ratio;
    });
    try {
      _controller.aspectRatio = ratio;
      _controller.crop = const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95);
    } catch (_) {
      // If bitmap is not yet initialized by image renderer, ratio is safely preserved in state
    }
  }

  void _rotateLeft() {
    try {
      _controller.rotateLeft();
    } catch (_) {}
  }

  void _rotateRight() {
    try {
      _controller.rotateRight();
    } catch (_) {}
  }

  void _flip180() {
    try {
      _controller.rotateRight();
      _controller.rotateRight();
    } catch (_) {}
  }

  Future<void> _saveAndDone() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final ui.Image bitmap = await _controller.croppedBitmap(
        quality: FilterQuality.high,
      );
      final ByteData? byteData = await bitmap.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Could not encode cropped image to byte data.');
      }

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final outDir = Directory('${tempDir.path}/edited_images');
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }
      final outPath =
          '${outDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.png';
      final outFile = File(outPath);
      await outFile.writeAsBytes(bytes);

      if (mounted) {
        Navigator.of(context).pop(outFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop(null),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _saveAndDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(
                _isProcessing ? 'Saving...' : 'Done',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Center Cropper Canvas
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CropImage(
                    controller: _controller,
                    image: Image.file(widget.imageFile),
                    paddingSize: 20.0,
                    alwaysMove: true,
                    gridCornerColor: AppColors.primaryGreen,
                    gridColor: Colors.white54,
                    gridInnerColor: Colors.white30,
                  ),
                ),
              ),
            ),

            // Bottom Editing Toolbar
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141915) : const Color(0xFF1E2420),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Aspect Ratio Pills Scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.allowFreeCrop) ...[
                          _buildRatioPill(
                            label: 'Free',
                            ratio: null,
                            isSelected: _currentAspectRatio == null,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _buildRatioPill(
                          label: '1:1',
                          ratio: 1.0,
                          isSelected: _currentAspectRatio != null &&
                              (_currentAspectRatio! - 1.0).abs() < 0.01,
                        ),
                        const SizedBox(width: 8),
                        _buildRatioPill(
                          label: '4:3',
                          ratio: 4.0 / 3.0,
                          isSelected: _currentAspectRatio != null &&
                              (_currentAspectRatio! - (4.0 / 3.0)).abs() < 0.01,
                        ),
                        const SizedBox(width: 8),
                        _buildRatioPill(
                          label: '16:9',
                          ratio: 16.0 / 9.0,
                          isSelected: _currentAspectRatio != null &&
                              (_currentAspectRatio! - (16.0 / 9.0)).abs() < 0.01,
                        ),
                        const SizedBox(width: 8),
                        _buildRatioPill(
                          label: '3:2',
                          ratio: 3.0 / 2.0,
                          isSelected: _currentAspectRatio != null &&
                              (_currentAspectRatio! - (3.0 / 2.0)).abs() < 0.01,
                        ),
                        const SizedBox(width: 8),
                        _buildRatioPill(
                          label: '2:1',
                          ratio: 2.0,
                          isSelected: _currentAspectRatio != null &&
                              (_currentAspectRatio! - 2.0).abs() < 0.01,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Rotation and Quick Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.rotate_90_degrees_ccw_rounded,
                        label: 'Rotate Left',
                        onTap: _rotateLeft,
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      _buildActionButton(
                        icon: Icons.rotate_90_degrees_cw_rounded,
                        label: 'Rotate Right',
                        onTap: _rotateRight,
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      _buildActionButton(
                        icon: Icons.screen_rotation_rounded,
                        label: 'Flip 180°',
                        onTap: _flip180,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioPill({
    required String label,
    required double? ratio,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _setAspectRatio(ratio),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
