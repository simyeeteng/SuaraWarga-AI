import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _checklists = [];

  @override
  void initState() {
    super.initState();
    _fetchChecklists();
  }

  Future<void> _fetchChecklists() async {
    try {
      final response = await _supabase
          .from('checklists')
          .select('*, checklist_items(*)')
          .order('created_at', ascending: false);
          
      if (mounted) {
        setState(() {
          _checklists = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching checklists: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleItem(String itemId, bool currentStatus) async {
    try {
      await _supabase
          .from('checklist_items')
          .update({'is_completed': !currentStatus})
          .eq('id', itemId);
      
      _fetchChecklists();
    } catch (e) {
      debugPrint('Error toggling item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checklists.isEmpty
              ? const Center(child: Text('No checklists found. Scan a document to generate one!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _checklists.length,
                  itemBuilder: (context, index) {
                    final checklist = _checklists[index];
                    final items = checklist['checklist_items'] as List<dynamic>? ?? [];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: const Color(0xFFF0FDF4),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              checklist['title'] ?? 'Generated Checklist',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46),
                              ),
                            ),
                            if (checklist['document_type'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 8),
                                child: Text(
                                  'From: ${checklist['document_type']}',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF10B981)),
                                ),
                              ),
                            const Divider(color: Color(0xFFA7F3D0)),
                            ...items.map((item) {
                              final isCompleted = item['is_completed'] == true;
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text(
                                  item['task'] ?? '',
                                  style: TextStyle(
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    color: isCompleted ? Colors.grey : Colors.black87,
                                    fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
                                  ),
                                ),
                                value: isCompleted,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (value) {
                                  if (item['id'] != null) {
                                    _toggleItem(item['id'].toString(), isCompleted);
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
