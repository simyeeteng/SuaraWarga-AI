import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../widgets/checklist_item.dart';

class DocumentCheckerPage extends StatefulWidget {
  const DocumentCheckerPage({super.key});

  @override
  State<DocumentCheckerPage> createState() => _DocumentCheckerPageState();
}

class _DocumentCheckerPageState extends State<DocumentCheckerPage> {
  final TtsService _ttsService = TtsService();
  bool _isPlayingTts = false;

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  // ─── TTS helpers ───────────────────────────────────────────────────────────

  void _readAloudChecklist(List<dynamic> items, AppState appState) async {
    if (_isPlayingTts) {
      await _ttsService.stop();
      setState(() => _isPlayingTts = false);
      return;
    }

    final List<String> pending = [];
    final List<String> ready = [];

    for (var it in items) {
      final name = it['item'] as String? ?? appState.translate(it['nameKey'] as String? ?? '');
      final isReady = it['ready'] as bool? ?? false;
      if (isReady) {
        ready.add(name);
      } else {
        pending.add(name);
      }
    }

    String speakText = '';
    if (pending.isEmpty) {
      speakText = 'Great news! All your documents are ready. You are good to go.';
    } else {
      speakText = 'Here is your checklist. You still need to prepare: ${pending.join(", ")}. ';
      if (ready.isNotEmpty) {
        speakText += 'You have already prepared: ${ready.join(", ")}.';
      }
    }

    setState(() => _isPlayingTts = true);
    final voiceLang = appState.voiceLanguage.isNotEmpty ? appState.voiceLanguage : appState.currentLanguage;
    await _ttsService.speak(speakText, langCode: voiceLang, speed: appState.voiceSpeed);

    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) setState(() => _isPlayingTts = false);
    });
  }

  void _readAloudScamWarning(List<dynamic> reasons, String? hotline, AppState appState) async {
    if (_isPlayingTts) {
      await _ttsService.stop();
      setState(() => _isPlayingTts = false);
      return;
    }

    final reasonsText = reasons.map((r) => r as String).join('. ');
    final hotlineText = hotline != null ? 'Verify by calling the official hotline: $hotline.' : '';
    final speakText =
        'Warning. This document has signs that do not match a typical official letter. '
        '$reasonsText. $hotlineText';

    setState(() => _isPlayingTts = true);
    final voiceLang = appState.voiceLanguage.isNotEmpty ? appState.voiceLanguage : appState.currentLanguage;
    await _ttsService.speak(speakText, langCode: voiceLang, speed: appState.voiceSpeed);

    Future.delayed(const Duration(seconds: 20), () {
      if (mounted) setState(() => _isPlayingTts = false);
    });
  }

  // ─── Delete dialog ─────────────────────────────────────────────────────────

  void _confirmDeleteActiveDoc(BuildContext context, AppState appState, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.translate('confirmDelete')),
        content: Text(appState.translate('confirmDeleteDoc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await appState.deleteScannedDocument(docId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scanned document deleted.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: Text(appState.translate('deleteBtn')),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final doc = appState.activeScannedDocument;
    final bool hasScannedDoc = doc != null;

    final List<dynamic> items = hasScannedDoc
        ? (doc['checklist'] as List<dynamic>? ?? [])
        : appState.checklistDocs;

    final int readyCount = items.where((it) => it['ready'] as bool? ?? false).length;
    final int missingCount = items.length - readyCount;
    final bool allReady = readyCount == items.length && items.isNotEmpty;

    // Formatted title from document type
    String docTitle = hasScannedDoc
        ? _formatDocType(doc['document_type'] as String)
        : appState.translate('docForMyKad');

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('docCheckerTitle'),
            subtitle: hasScannedDoc ? 'Checklist for: $docTitle' : docTitle,
            onBack: () => Navigator.pop(context),
          ),

          // Accessibility size controls
          _buildAccessibilityBar(appState),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [

                // 1. Scanned document history quick-switcher
                if (appState.scannedDocuments.isNotEmpty) ...[
                  _buildHistorySelector(appState),
                ],

                // 2. ─── Scam Warning Banner (aligned with letter interpreter) ───
                if (hasScannedDoc && (doc['is_scam_suspected'] as bool? ?? false)) ...[
                  _buildScamWarningBanner(doc, appState),
                  const SizedBox(height: 12),
                ],

                // 3. ─── Document Summary (scanned docs only) ──────────────────
                if (hasScannedDoc) ...[
                  _buildDocumentSummaryCard(doc, appState),
                  const SizedBox(height: 12),
                ],

                // 4. ─── Progress box ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: allReady ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                    border: Border.all(
                      color: allReady ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      width: appState.highContrast ? 2.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: allReady ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          allReady ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$readyCount / ${items.length} ${appState.translate('docReadyLabel')}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: allReady ? const Color(0xFF065F46) : const Color(0xFF92400E),
                              ),
                            ),
                            if (missingCount > 0)
                              Text(
                                '$missingCount ${appState.translate('docMissingLabel')}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            if (allReady)
                              const Text(
                                'You are ready to proceed.',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 5. ─── TTS read-aloud checklist ─────────────────────────────
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _readAloudChecklist(items, appState),
                        icon: Icon(_isPlayingTts ? Icons.stop_circle_rounded : Icons.volume_up_rounded),
                        label: Text('${appState.translate(_isPlayingTts ? 'ttsStop' : 'ttsReadAloud')} Checklist'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),

                // 6. ─── Checklist items ───────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: appState.highContrast ? Colors.black : const Color(0xFFEFF6FF),
                      width: appState.highContrast ? 2.0 : 1.5,
                    ),
                  ),
                  child: items.isEmpty
                      ? _buildEmptyState(appState)
                      : Column(
                          children: List.generate(items.length, (index) {
                            final it = items[index];
                            final bool isReady = it['ready'] as bool? ?? false;

                            if (hasScannedDoc) {
                              final String name = it['item'] as String;
                              return _buildInteractiveChecklistItem(
                                label: name,
                                ready: isReady,
                                onTap: () => appState.toggleScannedChecklistItem(doc['id'], index),
                                appState: appState,
                                isLast: index == items.length - 1,
                              );
                            } else {
                              final String nameKey = it['nameKey'] as String;
                              final IconData icon = it['icon'] as IconData? ?? Icons.description;
                              return ChecklistItem(
                                nameKey: nameKey,
                                ready: isReady,
                                icon: icon,
                                onTap: () => appState.toggleDocReady(index),
                              );
                            }
                          }),
                        ),
                ),
                const SizedBox(height: 12),

                // 7. ─── Next steps + verified contacts (scanned docs) ─────────
                if (hasScannedDoc) ...[
                  _buildNextStepsCard(doc, appState),
                  const SizedBox(height: 12),
                ],

                // 8. ─── Missing items helper (legacy JPN default checklist) ───
                if (missingCount > 0 && !hasScannedDoc) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.translate('missingDocsTitle'),
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...items.where((d) => !(d['ready'] as bool)).map((d) {
                          final nameKey = d['nameKey'] as String? ?? 'docMyKad';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_rounded, color: Color(0xFFF87171), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${appState.translate(nameKey)} — ${appState.translate('visitJpnOffice')}',
                                    style: const TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 9. ─── Delete scanned doc ────────────────────────────────────
                if (hasScannedDoc)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TextButton.icon(
                      onPressed: () => _confirmDeleteActiveDoc(context, appState, doc['id']),
                      icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Delete Scanned Letter',
                        style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sub-widgets ───────────────────────────────────────────────────────────

  /// Amber scam warning banner — mirrors letter_interpreter_page design
  Widget _buildScamWarningBanner(Map<String, dynamic> doc, AppState appState) {
    final List<dynamic> scamReasons = doc['scam_reasons'] as List? ?? [];
    final String? hotline = doc['verification_hotline'] as String?;
    final String? portal = doc['verification_portal'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFB923C), width: 2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 28, color: Color(0xFFEA580C)),
              SizedBox(width: 10),
              Expanded(
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF7C2D12), height: 1.45),
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
          if (hotline != null) ...[
            const Divider(height: 20, color: Color(0xFFFED7AA)),
            Row(
              children: [
                const Icon(Icons.phone_rounded, size: 20, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verify by calling the OFFICIAL hotline: $hotline',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
            if (portal != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, size: 20, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Official portal: $portal',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _readAloudScamWarning(scamReasons, hotline, appState),
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
    );
  }

  /// Plain-language AI summary + deadline — mirrors letter interpreter layout
  Widget _buildDocumentSummaryCard(Map<String, dynamic> doc, AppState appState) {
    final String summary = doc['summary_plain_language'] as String? ?? '';
    final String? deadline = doc['deadline_date'] as String?;
    final String? fee = doc['fee_amount'] as String?;

    return Column(
      children: [
        // Summary
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: appState.highContrast ? Colors.black : const Color(0xFFDBEAFE),
              width: appState.highContrast ? 2.5 : 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.smart_toy_rounded, size: 22, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text(
                    'What This Letter Means',
                    style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(width: 8),
                  AITag(label: 'LLM'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                summary,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Deadline + Fee row
        Row(
          children: [
            // Deadline
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: deadline != null ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: deadline != null ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEADLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: deadline != null ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deadline ?? 'Not stated',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: deadline != null ? const Color(0xFFB91C1C) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Fee
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fee != null ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: fee != null ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMOUNT / FEE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: fee != null ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fee ?? 'Not stated',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: fee != null ? const Color(0xFF047857) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Next steps + verified contacts — mirrors letter interpreter's sections 5 & 6
  Widget _buildNextStepsCard(Map<String, dynamic> doc, AppState appState) {
    final String agency = doc['issuing_agency'] as String? ?? 'the agency';
    final String portal = doc['official_portal'] as String? ?? 'https://www.malaysia.gov.my';
    final String lastVerified = doc['last_verified'] as String? ?? '';
    final bool isStale = doc['is_rules_verified_stale'] as bool? ?? false;
    final String? requiredAction = doc['required_action'] as String?;
    final String? verHotline = doc['verification_hotline'] as String?;
    final String? verPortal = doc['verification_portal'] as String?;

    return Column(
      children: [
        // Next steps card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'What To Do Next',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: appState.highContrast ? Colors.black : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                requiredAction ?? 'Please check details on the official portal of $agency.',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155), height: 1.45),
              ),
              const SizedBox(height: 12),
              // Official portal button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},  // Simulated — real launch via url_launcher
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text('${appState.translate('portalLabel')}: $agency'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF6FF),
                    foregroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Verified-on badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isStale ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5),
                  border: Border.all(color: isStale ? const Color(0xFFFCD34D) : const Color(0xFFA7F3D0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isStale ? Icons.warning_rounded : Icons.verified_user_rounded,
                      color: isStale ? const Color(0xFFD97706) : const Color(0xFF10B981),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isStale
                            ? appState.translate('infoNeedRecheck')
                            : '${appState.translate('lastVerifiedLabel')}: $lastVerified',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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

        // Verified contacts (green card — same as letter interpreter)
        if (verHotline != null || verPortal != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
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
                    Icon(Icons.shield_rounded, size: 20, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Text(
                      'Verify With the Official Agency',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Always confirm using these official channels — not any number printed on the document you received.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.bold, height: 1.4),
                ),
                const Divider(height: 14, color: Color(0xFFA7F3D0)),
                if (verHotline != null)
                  _buildDetailRow(label: '📞 Official Hotline', value: verHotline, valueColor: const Color(0xFF065F46)),
                if (verPortal != null) ...[
                  const SizedBox(height: 6),
                  _buildDetailRow(label: '🌐 Official Portal', value: verPortal, valueColor: const Color(0xFF065F46)),
                ],
              ],
            ),
          ),
        ],
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
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: valueColor)),
        ),
      ],
    );
  }

  Widget _buildAccessibilityBar(AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: appState.highContrast ? Colors.black.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
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
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 28, color: Color(0xFF2563EB)),
                onPressed: () => appState.adjustFontScale(0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySelector(AppState appState) {
    final docs = appState.scannedDocuments;
    final activeDoc = appState.activeScannedDocument;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.translate('scannedDocsTitle').toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Default JPN legacy checklist chip
                GestureDetector(
                  onTap: () => appState.setActiveScannedDocument(null),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: activeDoc == null ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'JPN Default',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: activeDoc == null ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                // Scanned documents chips
                ...docs.map((d) {
                  final isSel = activeDoc != null && activeDoc['id'] == d['id'];
                  final bool isScam = d['is_scam_suspected'] as bool? ?? false;
                  final String label = _formatDocType(d['document_type'] as String);
                  return GestureDetector(
                    onTap: () => appState.setActiveScannedDocument(d),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isScam
                            ? const Color(0xFFFFF7ED)
                            : (isSel ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: isScam
                            ? Border.all(color: const Color(0xFFFB923C), width: 1.5)
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isScam) ...[
                            const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFEA580C)),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isScam
                                  ? const Color(0xFF9A3412)
                                  : (isSel ? Colors.white : const Color(0xFF475569)),
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
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppState appState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.checklist_rounded, size: 48, color: Color(0xFFBFDBFE)),
          const SizedBox(height: 12),
          Text(
            appState.translate('noActiveDocTitle'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          Text(
            appState.translate('noActiveDocDesc'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveChecklistItem({
    required String label,
    required bool ready,
    required VoidCallback onTap,
    required AppState appState,
    required bool isLast,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: appState.highContrast ? Colors.black : const Color(0xFFEFF6FF),
                    width: appState.highContrast ? 2.0 : 1.0,
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ready ? const Color(0xFF10B981) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ready ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: ready
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ready
                      ? (appState.highContrast ? Colors.black54 : const Color(0xFF94A3B8))
                      : (appState.highContrast ? Colors.black : const Color(0xFF1E293B)),
                  decoration: ready ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Converts snake_case document type keys to human-readable labels
  String _formatDocType(String key) {
    const Map<String, String> labels = {
      'ic_renewal_damaged': 'MyKad (Damaged)',
      'ic_renewal_lost_first': 'MyKad (Lost 1st)',
      'ic_renewal_lost_second': 'MyKad (Lost 2nd)',
      'ic_renewal_lost_third_plus': 'MyKad (Lost 3rd+)',
      'ic_renewal_address_change': 'MyKad (Address)',
      'roadtax_driving_license': 'JPJ Road Tax',
      'lhdn_notice_of_assessment': 'LHDN Borang J',
      'lhdn_notice_of_additional_assessment': 'LHDN Borang JA',
      'lhdn_cp500': 'LHDN CP500',
      'lhdn_audit_notice': 'LHDN Audit',
      'court_notice': 'Court Notice',
      'traffic_summons': 'Traffic Summons',
      'epf_kwsp_letter': 'EPF / KWSP',
      'socso_perkeso_letter': 'PERKESO / SOCSO',
      'electricity_tnb': 'TNB Electricity',
      'unknown': 'Unknown Document',
    };
    return labels[key] ?? key.replaceAll('_', ' ').toUpperCase();
  }
}
