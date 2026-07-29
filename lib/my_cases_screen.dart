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
  List<Map<String, dynamic>> _savedSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCasesHistory();
  }

  Future<void> _loadCasesHistory() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawSessions = prefs.getStringList('chat_sessions') ?? [];

    List<Map<String, dynamic>> loaded = [];
    for (String s in rawSessions) {
      try {
        loaded.add(jsonDecode(s));
      } catch (e) {
        debugPrint("Error decoding session: $e");
      }
    }

    setState(() {
      _savedSessions = loaded;
      _isLoading = false;
    });
  }

  Future<void> _deleteCase(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawSessions = prefs.getStringList('chat_sessions') ?? [];

    if (index < rawSessions.length) {
      rawSessions.removeAt(index);
      await prefs.setStringList('chat_sessions', rawSessions);
      _loadCasesHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases History'),
        backgroundColor: const Color(0xFF0F5257),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Cases',
            onPressed: _loadCasesHistory, // REFRESH BUTTON ADDED
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCasesHistory, // SWIPE DOWN TO REFRESH ADDED
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedSessions.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_off_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'No cases recorded yet.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _savedSessions.length,
                    itemBuilder: (context, index) {
                      final session = _savedSessions[index];
                      String title = session['title'] ?? 'Legal Case';
                      String date = session['date'] ?? 'Recent';
                      String sessionId = session['id'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF0F5257),
                            child: Icon(Icons.gavel, color: Colors.white, size: 20),
                          ),
                          title: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Date: $date'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteCase(index),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  existingSessionId: sessionId,
                                ),
                              ),
                            ).then((_) => _loadCasesHistory());
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
