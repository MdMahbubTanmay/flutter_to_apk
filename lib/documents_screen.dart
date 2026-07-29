import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _isAuthenticated = false;
  final TextEditingController _pinController = TextEditingController();
  List<String> _docTitles = [];

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    if (_pinController.text == "1234") {
      setState(() {
        _isAuthenticated = true;
      });
      _loadDocs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PIN! Try 1234 for Demo.')),
      );
    }
  }

  Future<void> _loadDocs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _docTitles = prefs.getStringList('saved_docs') ?? [];
    });
  }

  Future<void> _pickAndSaveDocument() async {
    
    FilePickerResult? result = await FilePicker.platform.pickFiles();


    if (result != null && result.files.isNotEmpty) {
      String fileName = result.files.single.name;
      _showTitleDialog(fileName);
    }
  }

  void _showTitleDialog(String fileName) {
    final TextEditingController titleController = TextEditingController(text: fileName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Document Title'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'e.g., Jomir Dolil, Khatian'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String trimmedText = titleController.text.trim();
              if (trimmedText.isNotEmpty) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                List<String> updatedList = List.from(_docTitles)..add(trimmedText);
                await prefs.setStringList('saved_docs', updatedList);

                if (!mounted) return;

                setState(() {
                  _docTitles = updatedList;
                });
                
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _deleteDocument(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _docTitles.removeAt(index);
    });
    await prefs.setStringList('saved_docs', _docTitles);
  }

  Future<void> _clearAllDocuments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_docs');
    setState(() {
      _docTitles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Protected Documents')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Color(0xFF0F5257)),
              const SizedBox(height: 16),
              const Text('Enter Security PIN to Access Vault', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'PIN (Use 1234)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5257)),
                onPressed: _verifyPin,
                child: const Text('Unlock Vault', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents Vault'),
        actions: [
          if (_docTitles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Clear All Documents?'),
                    content: const Text('Are you sure you want to delete all uploaded document records?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          _clearAllDocuments();
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Delete All', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: _docTitles.isEmpty
          ? const Center(child: Text('No Documents Uploaded Yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _docTitles.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Color(0xFF0F5257)),
                    title: Text(_docTitles[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Status: Verified in Vault'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteDocument(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F5257),
        onPressed: _pickAndSaveDocument,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Upload Doc', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
