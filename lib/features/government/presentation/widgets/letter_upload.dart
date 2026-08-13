import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/ai_tag.dart';

class LetterUpload extends StatelessWidget {
  final VoidCallback onTriggerResult;

  const LetterUpload({super.key, required this.onTriggerResult});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Camera upload cards
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onTriggerResult,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // bg-blue-50
                          border: Border.all(color: const Color(0xFFBFDBFE), style: BorderStyle.solid, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.camera_alt_rounded, size: 36, color: Color(0xFF2563EB)),
                            const SizedBox(height: 8),
                            Text(
                              appState.translate('takePhoto'),
                              style: const TextStyle(
                                color: Color(0xFF1D4ED8), // text-blue-700
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: onTriggerResult,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF), // bg-purple-50
                          border: Border.all(color: const Color(0xFFE9D5FF), style: BorderStyle.solid, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.upload_file_rounded, size: 36, color: Color(0xFF8B5CF6)),
                            const SizedBox(height: 8),
                            Text(
                              appState.translate('uploadFile'),
                              style: const TextStyle(
                                color: Color(0xFF6D28D9), // text-purple-700
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const AITag(label: 'OCR'),
                  const SizedBox(width: 6),
                  const AITag(label: 'LLM'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      appState.translate('supportedFormats'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Examples box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_rounded, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.translate('exampleLetters'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appState.translate('exampleLettersList'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
