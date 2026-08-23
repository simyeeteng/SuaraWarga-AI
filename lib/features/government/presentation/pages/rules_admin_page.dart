import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';

class RulesAdminPage extends StatefulWidget {
  const RulesAdminPage({super.key});

  @override
  State<RulesAdminPage> createState() => _RulesAdminPageState();
}

class _RulesAdminPageState extends State<RulesAdminPage> {
  String? _selectedKey;
  
  final _agencyController = TextEditingController();
  final _feeController = TextEditingController();
  final _portalController = TextEditingController();
  final _lastVerifiedController = TextEditingController();
  final _requiredItemsController = TextEditingController(); // Comma separated items

  @override
  void dispose() {
    _agencyController.dispose();
    _feeController.dispose();
    _portalController.dispose();
    _lastVerifiedController.dispose();
    _requiredItemsController.dispose();
    super.dispose();
  }

  void _loadRule(String key, Map<String, dynamic> rule) {
    setState(() {
      _selectedKey = key;
      _agencyController.text = rule['agency'] as String? ?? '';
      _feeController.text = rule['fee'] as String? ?? '';
      _portalController.text = rule['official_portal'] as String? ?? '';
      _lastVerifiedController.text = rule['last_verified'] as String? ?? '';
      final List<dynamic> items = rule['required_items'] as List<dynamic>? ?? [];
      _requiredItemsController.text = items.join(', ');
    });
  }

  Future<void> _saveRule(AppState appState) async {
    if (_selectedKey == null) return;

    final List<String> items = _requiredItemsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final Map<String, dynamic> updatedRule = {
      'agency': _agencyController.text.trim(),
      'fee': _feeController.text.trim().isEmpty ? null : _feeController.text.trim(),
      'official_portal': _portalController.text.trim(),
      'last_verified': _lastVerifiedController.text.trim(),
      'required_items': items,
      'requires_police_report': _selectedKey!.contains('lost'),
    };

    await appState.updateDocumentRule(_selectedKey!, updatedRule);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rule updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _selectedKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final rules = appState.documentRules;

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('adminSettings'),
            subtitle: 'Configure verified Malaysian rules',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: _selectedKey != null
                ? _buildEditForm(appState)
                : _buildRulesList(appState, rules),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList(AppState appState, Map<String, dynamic> rules) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select a document rule to edit:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Rules?'),
                    content: const Text('This will overwrite all rules with the original factory defaults.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await appState.resetRulesToDefault();
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(appState.translate('adminReset')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF475569),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...rules.keys.map((key) {
          final Map<String, dynamic> rule = Map<String, dynamic>.from(rules[key] as Map);
          final String agency = rule['agency'] as String? ?? 'N/A';
          final String lastVerified = rule['last_verified'] as String? ?? 'N/A';
          final String? fee = rule['fee'] as String?;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text(
                key.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Agency: $agency', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('Fee: ${fee ?? "Varies / Null"}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  Text('Last Verified: $lastVerified', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
              trailing: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 28),
              onTap: () => _loadRule(key, rule),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEditForm(AppState appState) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_document, color: Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Editing Scenario: ${_selectedKey!.replaceAll('_', ' ').toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(label: 'Agency Name', controller: _agencyController),
        _buildTextField(label: 'Standard Fee (e.g. RM10 or empty if varies)', controller: _feeController),
        _buildTextField(label: 'Official Portal URL', controller: _portalController),
        _buildTextField(label: 'Last Verified Date (YYYY-MM-DD)', controller: _lastVerifiedController),
        _buildTextField(
          label: 'Required Items (comma-separated)',
          controller: _requiredItemsController,
          maxLines: 3,
          helperText: 'e.g. Police report, Current MyKad, Photo',
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _selectedKey = null),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
                ),
                child: Text(appState.translate('cancel')),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _saveRule(appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(appState.translate('adminSave')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              helperText: helperText,
              helperStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
