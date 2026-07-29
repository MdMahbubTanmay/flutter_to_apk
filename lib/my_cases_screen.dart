import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawHistory = prefs.getStringList('chat_history') ?? [];
    setState(() {
      _history = rawHistory.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
    });
  }

  Future<void> _deleteCase(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.removeAt(index);
    });
    List<String> updatedRaw = _history.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('chat_history', updatedRaw);
  }

  Future<void> _clearAllHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Case History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear All Case History?'),
                    content: const Text('Are you sure you want to remove all previous case logs?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          _clearAllHistory();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: _history.isEmpty
          ? const Center(child: Text('No Previous Case Queries Found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.history_toggle_off, color: Color(0xFF0F5257)),
                    title: Text(item['title'] ?? 'Legal Query', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Date: ${item['date']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteCase(index),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(initialQuery: item['title']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
