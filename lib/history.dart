import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _historySessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyData = prefs.getString('chat_history_sessions');
    
    if (historyData != null) {
      final List<dynamic> decoded = jsonDecode(historyData);
      setState(() {
        _historySessions = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSession(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _historySessions.removeAt(index);
    });
    await prefs.setString('chat_history_sessions', jsonEncode(_historySessions));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14),
      appBar: AppBar(
        backgroundColor: const Color(0xff161224),
        elevation: 0,
        title: const Text('Chat History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff663399)))
          : _historySessions.isEmpty
              ? const Center(child: Text('No previous chats found.', style: TextStyle(color: Color(0xff63567D))))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historySessions.length,
                  itemBuilder: (context, index) {
                    final session = _historySessions[index];
                    final List<dynamic> messages = session['messages'] ?? [];
                    final String lastMessage = messages.isNotEmpty ? messages.last['text'] : 'Empty Chat';
                    final String timestamp = session['title'] ?? 'Saved Chat';
                    final String sessionId = session['id'] ?? '';

                    return Dismissible(
                      key: Key(sessionId + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) => _deleteSession(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xff161224),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xff3b2d54)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xff2A2141),
                            child: Icon(Icons.chat_bubble_outline, color: Colors.white),
                          ),
                          title: Text(
                            timestamp,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xff63567D)),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xff63567D), size: 16),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim, secAnim) => ChatScreen(
                                  sessionId: sessionId,
                                  existingMessages: messages.map((m) => Map<String, String>.from(m)).toList(),
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                            _loadHistory();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
