import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';

class ImageUpload extends StatelessWidget {
  final VoidCallback onTap;

  const ImageUpload({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 192,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5), // bg-emerald-50/green-50
          border: Border.all(
            color: const Color(0xFFA7F3D0), // border-emerald-200/green-200
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5), // green-100
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_a_photo_rounded, color: Color(0xFF059669), size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              appState.translate('uploadWalkwayPhoto'),
              style: const TextStyle(
                color: Color(0xFF047857), // text-green-700
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              appState.translate('aiDetectFeatures'),
              style: const TextStyle(
                color: Color(0xFF10B981), // text-green-500
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
