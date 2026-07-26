import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final List<Map<String, String>>? existingMessages;
  final String? sessionId;

  const ChatScreen({super.key, this.existingMessages, this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, String>> _messages;
  late String _currentSessionId;
final Map<String, String> _aiReplies = {
    'hello': 'Hi there! How can I assist you with our project demo?',
    'hi': 'Hello! Welcome to our application prototype.',
    'how are you': 'I am running perfectly as a static mock AI! How are you?',
    'help': 'Sure! Try typing "story", "jomi help", or "code" to see my mock responses.',
    'about': 'This is a static demo created to present our app workflow design.',
    'story': 'Legal GPS holo Bangladesh er Sonbidhan onujayi ekti ayni pothprodorshok app. Amader desh er shadharon manush jeno shohoje ayni odhikar o dharagulo shomporke jante pare, shei uddeshei eta banano hoyeche.',
    'jomi help': 'Ji obosshoi. Bangladesh er bhumi ain o sonbidhan onujayi ami apnake shohayota korte pari. Apnar jomi niye thik ki dhoroner shomossa hoyeche amake thora khule bolun?',
    'amar jomi related help lagbe': 'Ji obosshoi. Bangladesh er bhumi ain o sonbidhan onujayi ami apnake shohayota korte pari. Apnar jomi niye thik ki dhoroner shomossa hoyeche amake thora khule bolun?',
    'ekjoner jomi arekjon mere niche': 'Acha, jor-purbok jomi dokhol ba mere neyar ghotona khub-i gurutto-purno. Apnar kache ki jomir boidho Dolil, Namjari (Mutation), o hal-nagad Khatian mathae ache?',
    'amar jomi niye niche': 'Acha, jor-purbok jomi dokhol ba mere neyar ghotona khub-i gurutto-purno. Apnar kache ki jomir boidho Dolil, Namjari (Mutation), o hal-nagad Khatian mathae ache?',
    'ha sob dolil ache': 'Tahole ayni bhabe apni khub shokto obosthane achen! Shofol bhabe dokhol uddharer jonno apni Fauzdari Karjobidhi (CrPC) er 145 dhara onujayi Executive Magistrate adolote ba Specific Relief Act onujayi Deowani adolote mamla korte parben.',
    'ache': 'Tahole ayni bhabe apni khub shokto obosthane achen! Shofol bhabe dokhol uddharer jonno apni Fauzdari Karjobidhi (CrPC) er 145 dhara onujayi Executive Magistrate adolote ba Specific Relief Act onujayi Deowani adolote mamla korte parben.',
    'code': '--- LEGAL GPS MASTER COMMAND LIST ---\n\n• "story" - App er mulo uddesho o Bangladesh er sonbidhan niye jante.\n• Dialogue Workflow:\n  1. "amar jomi related help lagbe"\n  2. "ekjoner jomi arekjon mere niche"\n  3. "ha sob dolil ache"',
  };

  @override
  void initState() {
    super.initState();
    _messages = widget.existingMessages ?? [
      {'sender': 'ai', 'text': 'Hello! I am your AI assistant. How can I help you today?'}
    ];
    
    
    _currentSessionId = widget.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _saveChatToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyData = prefs.getString('chat_history_sessions');
    List<dynamic> sessions = historyData != null ? jsonDecode(historyData) : [];

    
    int existingIndex = sessions.indexWhere((s) => s['id'] == _currentSessionId);

    Map<String, dynamic> sessionData = {
      'id': _currentSessionId,
      'title': widget.sessionId != null 
          ? sessions[existingIndex]['title'] 
          : 'Chat at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      'messages': _messages,
    };

    if (existingIndex != -1) {
      sessions[existingIndex] = sessionData; 
    } else {
      sessions.insert(0, sessionData);
    }
    
    await prefs.setString('chat_history_sessions', jsonEncode(sessions));
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messageController.clear();
    });
    _scrollToBottom();
    _saveChatToPreferences();

    Future.delayed(const Duration(milliseconds: 400), () {
      final String normalizedText = text.toLowerCase();
      String response = "I'm sorry, I don't recognize that command. Try typing 'help' to see available demo triggers.";

      if (_aiReplies.containsKey(normalizedText)) {
        response = _aiReplies[normalizedText]!;
      }

      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': response});
        });
        _scrollToBottom();
        _saveChatToPreferences(); 
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff161224),
      appBar: AppBar(
        backgroundColor: const Color(0xff161224),
        elevation: 0,
        title: const Text('AI Assistant', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xff63567D) : const Color(0xff221C34),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(isUser ? 14 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 14),
                      ),
                    ),
                    child: Text(message['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xff1A152B),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "Type 'hello', 'features', or 'help'...",
                        hintStyle: TextStyle(color: Color(0xff63567D), fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white), 
                    onPressed: _sendMessage
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
