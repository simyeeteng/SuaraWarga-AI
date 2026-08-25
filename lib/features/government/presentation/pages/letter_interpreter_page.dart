import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';

class LetterInterpreterPage extends StatefulWidget {
  const LetterInterpreterPage({super.key});

  @override
  State<LetterInterpreterPage> createState() => _LetterInterpreterPageState();
}

class _LetterInterpreterPageState extends State<LetterInterpreterPage> {
  final TtsService _ttsService = TtsService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _pasteController = TextEditingController();
  bool _isPlayingTts = false;
  bool _showPasteInput = false;

  /// Opens camera or gallery and passes the real file path to processDocument.
  Future<void> _pickImage(AppState appState, ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,   // Good quality for OCR readability
        maxWidth: 2048,     // Cap size to keep ML Kit fast
        maxHeight: 2048,
      );
      if (picked != null && mounted) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          await appState.processDocument(
            picked.path,
            fileBytes: bytes,
            mimeType: 'image/jpeg',
          );
        } else {
          await appState.processDocument(picked.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open ${source == ImageSource.camera ? "camera" : "gallery"}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFile(AppState appState) async {
    try {
      List<PlatformFile>? files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (files != null && files.isNotEmpty && mounted) {
        final platformFile = files.first;
        final bytes = await platformFile.readAsBytes();
        final extension = platformFile.name.contains('.') 
            ? platformFile.name.split('.').last.toLowerCase() 
            : 'unknown';
        
        String mimeType = 'application/octet-stream';
        if (extension == 'pdf') mimeType = 'application/pdf';
        else if (extension == 'png') mimeType = 'image/png';
        else if (extension == 'jpg' || extension == 'jpeg') mimeType = 'image/jpeg';
        
        await appState.processDocument(
          platformFile.path ?? platformFile.name,
          fileBytes: bytes,
          mimeType: mimeType,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _pasteController.dispose();
    super.dispose();
  }

  void _toggleTts(String text, String langCode, double speed) async {
    if (_isPlayingTts) {
      await _ttsService.stop();
      setState(() {
        _isPlayingTts = false;
      });
    } else {
      setState(() {
        _isPlayingTts = true;
      });
      await _ttsService.speak(text, langCode: langCode, speed: speed);
      // Automatically reset playing state when done
      Future.delayed(const Duration(seconds: 12), () {
        if (mounted) {
          setState(() {
            _isPlayingTts = false;
          });
        }
      });
    }
  }

  void _shareDocument(Map<String, dynamic> doc, AppState appState) {
    final String summary = doc['summary_plain_language'] as String;
    final String deadline = doc['deadline_date'] as String? ?? 'Not stated';
    final String agency = doc['issuing_agency'] as String;
    final String portal = doc['official_portal'] as String;

    final String shareText = 
        "Hi! SuaraWarga AI helped me read an official letter from $agency.\n\n"
        "Summary:\n$summary\n\n"
        "Deadline: $deadline\n\n"
        "You can check details on the official portal: $portal\n"
        "Sent from SuaraWarga AI.";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.share_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Text(appState.translate('shareWithFamily')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulated WhatsApp / Msg Share Text:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                shareText,
                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document info copied to clipboard / shared!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            child: const Text('Share Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String viewState = appState.letterInterpreterState;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Future.microtask(() {
          appState.resetLetterInterpreter();
        });
      },
      child: Scaffold(
        body: Column(
          children: [
            CustomHeader(
              title: appState.translate('letterTitle'),
              subtitle: appState.translate('letterSubtitle'),
              onBack: () {
                Navigator.pop(context);
              },
            ),
          
          // Accessibility Top Bar (Text +/- size scaling)
          _buildAccessibilityBar(appState),
          
          Expanded(
            child: appState.isProcessingDocument
                ? _buildProcessingView(appState)
                : appState.documentProcessingError != null
                    ? _buildErrorView(appState)
                    : viewState == 'upload'
                        ? _buildUploadView(appState)
                        : _buildResultView(appState),
          )
        ],
      ),
    ),
  );
}

  Widget _buildAccessibilityBar(AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: appState.highContrast ? Colors.black.withOpacity(0.05) : const Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0), width: appState.highContrast ? 2 : 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields_rounded, size: 20, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                '${appState.translate('textSizeLabel')}: ${appState.fontScaleLabel}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF475569)),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 28, color: Color(0xFF2563EB)),
                onPressed: () => appState.adjustFontScale(-0.1),
                tooltip: appState.translate('decreaseTextSize'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 28, color: Color(0xFF2563EB)),
                onPressed: () => appState.adjustFontScale(0.1),
                tooltip: appState.translate('increaseTextSize'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(AppState appState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              appState.translate('processingWithAI'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Text('1. Scanning document...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB))),
                      ),
                      SizedBox(width: 12),
                      Text('2. Identifying dates and details (AI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 18),
                      SizedBox(width: 8),
                      Text('3. Verifying standard rules database', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF94A3B8))),
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

  Widget _buildErrorView(AppState appState) {
    final String error = appState.documentProcessingError ?? 'Unknown processing error';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                const SizedBox(height: 12),
                Text(
                  appState.translate('uploadErrorTitle'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF991B1B)),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Good vs Bad photo visual example
          const Text(
            'Document Guidelines for Best AI Results:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                      const SizedBox(height: 4),
                      Text(appState.translate('goodPhotoTitle'), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF065F46))),
                      const SizedBox(height: 4),
                      Text(
                        appState.translate('goodPhotoDesc'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444)),
                      const SizedBox(height: 4),
                      Text(appState.translate('badPhotoTitle'), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF991B1B))),
                      const SizedBox(height: 4),
                      Text(
                        appState.translate('badPhotoDesc'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C), height: 1.3),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: () => appState.processDocument('roadtax_clear.jpg'), // Default simulation path
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(appState.translate('retakePhoto')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUploadView(AppState appState) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // ── Camera / Gallery card ──────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: appState.highContrast ? Colors.black : const Color(0xFFEFF6FF),
              width: appState.highContrast ? 2.5 : 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.translate('uploadPhotoPrompt'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickImage(appState, ImageSource.camera),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.camera_alt_rounded, size: 36, color: Color(0xFF2563EB)),
                            const SizedBox(height: 8),
                            Text(
                              appState.translate('takePhoto'),
                              style: const TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickFile(appState),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          border: Border.all(color: const Color(0xFFE9D5FF), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.upload_file_rounded, size: 36, color: Color(0xFF8B5CF6)),
                            const SizedBox(height: 8),
                            Text(
                              appState.translate('uploadFile'),
                              style: const TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  AITag(label: 'Vision AI'),
                  SizedBox(width: 6),
                  AITag(label: 'LLM'),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Supports JPG, PNG, PDF',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Paste/Forward email text ───────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0FDF4), width: 1.5),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.email_rounded, color: Color(0xFF10B981), size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Got an email? Paste the text here',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                  ),
                  Switch(
                    value: _showPasteInput,
                    onChanged: (v) => setState(() => _showPasteInput = v),
                    activeColor: const Color(0xFF10B981),
                  ),
                ],
              ),
              if (_showPasteInput) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _pasteController,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Paste the email or letter text here...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = _pasteController.text.trim();
                      if (text.isNotEmpty) {
                        appState.processDocumentText(text);
                      }
                    },
                    icon: const Icon(Icons.smart_toy_rounded),
                    label: const Text('Interpret This Email / Letter',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Simulation presets ────────────────────────────────────────────
        const Text(
          'SIMULATION PRESETS (Testers):',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildPresetTile(
                title: 'Roadtax Renewal Notice (JPJ)',
                subtitle: 'Classifies correctly, extracts deadline/fee.',
                icon: Icons.directions_car_rounded,
                color: Colors.green,
                onTap: () => appState.processDocument('roadtax_clear.jpg'),
              ),
              _buildPresetTile(
                title: 'Damaged MyKad (JPN)',
                subtitle: 'Classifies JPN damaged card renewal.',
                icon: Icons.badge_rounded,
                color: Colors.blue,
                onTap: () => appState.processDocument('mykad_damaged.jpg'),
              ),
              _buildPresetTile(
                title: 'LHDN Notice of Assessment (Borang J)',
                subtitle: 'Classifies LHDN tax notice, extracts RM450 deadline.',
                icon: Icons.receipt_long_rounded,
                color: Colors.deepOrange,
                onTap: () => appState.processDocument('lhdn_notice.jpg'),
              ),
              _buildPresetTile(
                title: 'LHDN Audit Notice',
                subtitle: 'Audit document, generates full audit checklist.',
                icon: Icons.manage_search_rounded,
                color: Colors.purple,
                onTap: () => appState.processDocument('lhdn_audit.jpg'),
              ),
              _buildPresetTile(
                title: 'Court Notice (Writ Saman)',
                subtitle: 'Legal hearing notice for civil claim.',
                icon: Icons.gavel_rounded,
                color: Colors.brown,
                onTap: () => appState.processDocument('court_notice.jpg'),
              ),
              _buildPresetTile(
                title: '⚠️ SCAM Simulation (LHDN Impersonation)',
                subtitle: 'Tests scam detection — arrest threat + CIMB account.',
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
                onTap: () => appState.processDocument('scam_email.jpg'),
              ),
              _buildPresetTile(
                title: 'Blurry / Unreadable Photo',
                subtitle: 'Simulates camera jitter error. Prompts retake.',
                icon: Icons.blur_on_rounded,
                color: Colors.grey,
                showDivider: false,
                onTap: () => appState.processDocument('blurry_paper.jpg'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          trailing: const Icon(Icons.play_arrow_rounded, color: Color(0xFF94A3B8)),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFE2E8F0)),
      ],
    );
  }

  Widget _buildResultView(AppState appState) {
    final doc = appState.activeScannedDocument;
    if (doc == null) return const Center(child: Text('No active document processed.'));

    final String summary = doc['summary_plain_language'] as String;
    final String? deadline = doc['deadline_date'] as String?;
    final String? fee = doc['fee_amount'] as String?;
    final String agency = doc['issuing_agency'] as String;
    final String portal = doc['official_portal'] as String;
    final String lastVerified = doc['last_verified'] as String;
    final bool isStale = doc['is_rules_verified_stale'] as bool? ?? false;
    final bool isScam = doc['is_scam_suspected'] as bool? ?? false;
    final List<dynamic> scamReasons = doc['scam_reasons'] as List? ?? [];
    final String? verHotline = doc['verification_hotline'] as String?;
    final String? verPortal = doc['verification_portal'] as String?;
    final List<dynamic> checklist = doc['checklist'] as List? ?? [];
    final String docId = doc['id'] as String;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [

        // ── 1. Scam Warning (shows first when flagged) ───────────────────
        if (isScam) ...[
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFB923C), width: 2),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 28, color: Color(0xFFEA580C)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Please Check Carefully Before Acting',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF9A3412)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'This document has some signs that don\'t match a typical official letter. Before doing anything it asks — such as paying money or sharing personal details — please verify it is real by calling the agency\'s official number directly (not the number printed on the letter).',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF7C2D12), height: 1.45),
                ),
                const SizedBox(height: 12),
                ...scamReasons.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFEA580C)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r as String,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7C2D12), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )),
                if (verHotline != null) ...[
                  const Divider(height: 20, color: Color(0xFFFED7AA)),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded, size: 20, color: Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verify by calling the OFFICIAL hotline: $verHotline',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                        ),
                      ),
                    ],
                  ),
                  if (verPortal != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.language_rounded, size: 20, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Official portal: $verPortal',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final warnText = 'Warning: This document has signs that don\'t match a typical official letter. '
                        'Scam signals detected: ${scamReasons.join('. ')} '
                        'Verify by calling the official hotline: $verHotline';
                    _toggleTts(warnText, appState.currentLanguage, appState.voiceSpeed);
                  },
                  icon: Icon(_isPlayingTts ? Icons.stop_circle_rounded : Icons.volume_up_rounded),
                  label: const Text('Read Aloud Warning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── 2. Plain Language Summary ─────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: appState.highContrast ? Colors.black : const Color(0xFFDBEAFE), width: appState.highContrast ? 2.5 : 1.5),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.smart_toy_rounded, size: 24, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text(
                    appState.translate('aiExplanationLabel'),
                    style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  const AITag(label: 'LLM'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                summary,
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w800, height: 1.45),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final vLang = appState.voiceLanguage.isNotEmpty ? appState.voiceLanguage : appState.currentLanguage;
                  _toggleTts(summary, vLang, appState.voiceSpeed);
                },
                icon: Icon(_isPlayingTts ? Icons.stop_circle_rounded : Icons.volume_up_rounded),
                label: Text(appState.translate(_isPlayingTts ? 'ttsStop' : 'ttsReadAloud')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 3. Deadline ──────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: deadline != null ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: deadline != null ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
              width: appState.highContrast ? 2.5 : 1.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: deadline != null ? const Color(0xFFFEE2E2) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.event_busy_rounded, color: deadline != null ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.translate('deadlineLabel').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900,
                        color: deadline != null ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deadline ?? 'Not stated in document — check with agency.',
                      style: TextStyle(
                        color: deadline != null ? const Color(0xFFB91C1C) : const Color(0xFF334155),
                        fontWeight: FontWeight.w900, fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 4. Inline Action Checklist ────────────────────────────────────
        if (checklist.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDCFCE7), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.checklist_rtl_rounded, size: 22, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Text(
                      'Your Action Checklist',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap each item to mark it as done. Your progress is saved.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                ...List.generate(checklist.length, (i) {
                  final item = checklist[i] as Map;
                  final bool done = item['ready'] as bool? ?? false;
                  return InkWell(
                    onTap: () => appState.toggleScannedChecklistItem(docId, i),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: done ? const Color(0xFF10B981) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: done ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                                width: 2,
                              ),
                            ),
                            child: done
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item['item'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: done ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                                decoration: done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── 5. Document Details ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.translate('docDetailsLabel'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
              ),
              const Divider(height: 20, color: Color(0xFFE2E8F0)),
              _buildDetailRow(label: 'Issuing Agency', value: agency),
              const SizedBox(height: 12),
              _buildDetailRow(
                label: 'Payment / Fee',
                value: fee ?? 'Not stated in document',
                valueColor: fee != null ? const Color(0xFF047857) : const Color(0xFF475569),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isStale ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5),
                  border: Border.all(color: isStale ? const Color(0xFFFCD34D) : const Color(0xFFA7F3D0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(isStale ? Icons.warning_rounded : Icons.verified_user_rounded,
                      color: isStale ? const Color(0xFFD97706) : const Color(0xFF10B981), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isStale
                            ? appState.translate('infoNeedRecheck')
                            : '${appState.translate('lastVerifiedLabel')}: $lastVerified',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold,
                          color: isStale ? const Color(0xFF92400E) : const Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 6. Verify Yourself (Official Contacts) ──────────────────────
        if (verHotline != null || verPortal != null) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 22, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Text(
                      'Verify With the Official Agency',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Always confirm using these official channels — not any number printed on the document you received.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF047857), fontWeight: FontWeight.bold, height: 1.4),
                ),
                const Divider(height: 16, color: Color(0xFFA7F3D0)),
                if (verHotline != null)
                  _buildDetailRow(label: '📞 Official Hotline', value: verHotline, valueColor: const Color(0xFF065F46)),
                if (verPortal != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(label: '🌐 Official Portal', value: verPortal, valueColor: const Color(0xFF065F46)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── 7. Primary actions ──────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _shareDocument(doc, appState),
                  icon: const Icon(Icons.share_rounded),
                  label: Text(appState.translate('shareWithFamily')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFBFDBFE), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await appState.saveChecklistToCloud(doc);
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to Checklist!', style: TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Redirect to Checklist Page
                        Navigator.pushNamed(context, '/checklist');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save', style: TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('Add to Checklist'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 62,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => appState.setLetterInterpreterState('upload'),
            icon: const Icon(Icons.document_scanner_rounded, size: 24),
            label: Text(appState.translate('scanAnotherLetter'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color valueColor = const Color(0xFF1E293B),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: valueColor),
          ),
        ),
      ],
    );
  }
}
