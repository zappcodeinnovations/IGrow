import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/dummy_models/dummy_ebook.dart';

class EbookViewerScreen extends StatefulWidget {
  final String ebookId;
  const EbookViewerScreen({super.key, required this.ebookId});

  @override
  State<EbookViewerScreen> createState() => _EbookViewerScreenState();
}

class _EbookViewerScreenState extends State<EbookViewerScreen> {
  late DummyEbook _ebook;

  @override
  void initState() {
    super.initState();
    _ebook = dummyEbooks.firstWhere((e) => e.id == widget.ebookId, orElse: () => dummyEbooks.first);
    _initScreenProtector();
  }

  Future<void> _initScreenProtector() async {
    // Prevent screenshot and screen recording
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageOn();
  }

  @override
  void dispose() {
    _disposeScreenProtector();
    super.dispose();
  }

  Future<void> _disposeScreenProtector() async {
    // Re-enable screenshots when leaving
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageWithColorOff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_ebook.title, style: Theme.of(context).textTheme.titleMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primaryGreen),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(_ebook.title),
                  content: Text('Author: ${_ebook.author}\n\n${_ebook.description}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        _ebook.pdfUrl,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
