import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MessageType { text, documentChecklist, roadmap }

class ChatMessage {
  final String sender;
  final String text;
  final MessageType type;
  final List<Map<String, dynamic>>? checklist;
  final List<Map<String, String>>? roadmapSteps;

  ChatMessage({
    required this.sender,
    required this.text,
    this.type = MessageType.text,
    this.checklist,
    this.roadmapSteps,
  });

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
        'type': type.name,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        sender: json['sender'],
        text: json['text'],
        type: MessageType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MessageType.text,
        ),
      );
}

class ChatScreen extends StatefulWidget {
  final String? initialQuery;
  final bool startVoiceRecorder;

  const ChatScreen({super.key, this.initialQuery, this.startVoiceRecorder = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  int _storyStep = 0;
  bool _isRecording = false;
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    if (widget.startVoiceRecorder) {
      _isRecording = true;
    } else if (widget.initialQuery != null) {
      _sendMessage(widget.initialQuery!);
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: text));
    });
    _saveEntireSessionHistory();
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 600), () {
      _processStoryResponse(text);
    });
  }

  void _processStoryResponse(String userText) {
    String lower = userText.toLowerCase();

    // Check for thank you response at any point
    if (lower.contains('tnx') || lower.contains('thanks') || lower.contains('ধন্যবাদ')) {
      _addAppMessage("আপনাকে অনেক ধন্যবাদ! Legal GPS-এর সাথে থাকার জন্য স্বাগতম। আপনার যেকোনো আইনি প্রয়োজনে আমি সবসময় আছি।");
      return;
    }

    if (_storyStep == 0) {
      _addAppMessage("Hello! Legal GPS-এ আপনাকে স্বাগতম। গণপ্রজাতন্ত্রী বাংলাদেশের সংবিধান এবং প্রচলিত আইন অনুযায়ী আপনার সমস্যা শুনছি। বলুন কীভাবে সাহায্য করতে পারি?");
      _storyStep = 1;
    } else if (_storyStep == 1 || lower.contains('jomi') || lower.contains('land') || lower.contains('জমি')) {
      _addAppMessage(
        "বাংলাদেশ সংবিধানের ৪২ নম্বর অনুচ্ছেদ (Article 42) অনুযায়ী প্রতিটি নাগরিকের সম্পত্তি অর্জন, ধারণ ও হস্তান্তরের অধিকার রয়েছে।\n\n"
        "জমি ও সম্পত্তি সংক্রান্ত আইনগত সমাধানের জন্য (State Acquisition and Tenancy Act, 1950) অনুযায়ী জমি সংক্রান্ত কাগজপত্র পর্যালোচনা করা প্রয়োজন। চলুন আপনার ডকুমেন্টগুলো চেক করি।",
      );
      _showInitialPartialChecklist();
      _storyStep = 2;
    } else if (_storyStep == 2 || lower.contains('check') || lower.contains('upload') || lower.contains('চেক')) {
      _showAllCompletedChecklist();
      _storyStep = 3;
    } else if (_storyStep == 3 || lower.contains('yes') || lower.contains('হ্যাঁ') || lower.contains('road') || lower.contains('রোডম্যাপ')) {
      _generateRoadmapWidget();
      _storyStep = 4;
    } else {
      _addAppMessage("ধন্যবাদ! অন্য কোনো আইনি তথ্য বা ধারার ব্যাখ্যা জানতে প্রশ্ন করতে পারেন।");
    }
  }

  void _addAppMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(sender: 'app', text: text));
    });
    _saveEntireSessionHistory();
  }

  // First check: Shows 2 uploaded and 2 missing
  void _showInitialPartialChecklist() {
    List<Map<String, dynamic>> initialItems = [
      {'title': 'মূল ক্রয় দলিল (Deed of Sale)', 'checked': true},
      {'title': 'আর.এস / বি.এস খতিয়ান (CS/RS/BS Khatian)', 'checked': true},
      {'title': 'নামজারি ও জমাভাগ পরচা (Mutation Copy)', 'checked': false},
      {'title': 'ভূমি উন্নয়ন কর রসিদ (Land Tax Receipt)', 'checked': false},
    ];

    setState(() {
      _messages.add(
        ChatMessage(
          sender: 'app',
          text: "আপনার আপলোড করা ডকুমেন্টের আইনি চেকলিস্ট অবস্থা:\n\nআপনার ২ টি ডকুমেন্ট পাওয়া গেছে এবং ২ টি অনুপস্থিত (Missing)। অনুগ্রহ করে বাকি ২ টি ডকুমেন্ট আপলোড করে 'Check Again' বলুন।",
          type: MessageType.documentChecklist,
          checklist: initialItems,
        ),
      );
    });
    _saveEntireSessionHistory();
  }

  // Second check: Shows all 4 documents uploaded
  void _showAllCompletedChecklist() {
    List<Map<String, dynamic>> completedItems = [
      {'title': 'মূল ক্রয় দলিল (Deed of Sale)', 'checked': true},
      {'title': 'আর.এস / বি.এস খতিয়ান (CS/RS/BS Khatian)', 'checked': true},
      {'title': 'নামজারি ও জমাভাগ পরচা (Mutation Copy)', 'checked': true},
      {'title': 'ভূমি উন্নয়ন কর রসিদ (Land Tax Receipt)', 'checked': true},
    ];

    setState(() {
      _messages.add(
        ChatMessage(
          sender: 'app',
          text: "ধন্যবাদ! আপনার সকল প্রয়োজনীয় ডকুমেন্ট সফলভাবে আপলোড করা হয়েছে (৪/৪ সম্পন্ন)।\n\nআমি কি এখন আপনার জন্য আইনি অ্যাকশন রোডম্যাপ (Action Roadmap) প্রস্তুত করব?",
          type: MessageType.documentChecklist,
          checklist: completedItems,
        ),
      );
    });
    _saveEntireSessionHistory();
  }

  void _generateRoadmapWidget() {
    List<Map<String, String>> steps = [
      {
        'step': 'Step 1',
        'title': 'রেকর্ড যাচাইকরণ (Sub-Register Office)',
        'law': 'State Acquisition & Tenancy Act, Sec 143',
        'desc': 'সংশ্লিষ্ট সাব-রেজিস্ট্রি অফিসে গিয়ে বি.এস খতিয়ান ও বায়া দলিলের সত্যতা নিরূপণ করুন।'
      },
      {
        'step': 'Step 2',
        'title': 'মিউটেশন/নামজারি আবেদন (AC Land Office)',
        'law': 'Land Reforms Act 2023',
        'desc': 'সহকারী কমিশনার (ভূমি) কার্যালয়ে ই-নামজারি অনলাইন আবেদন দাখিল করে খাজনা পরিশোধ করুন।'
      },
      {
        'step': 'Step 3',
        'title': 'দেওয়ানি প্রতিকার ও মামলা (Civil Suit)',
        'law': 'Specific Relief Act 1877, Sec 42 & 54',
        'desc': 'স্বত্ব ঘোষণা ও স্থায়ী নিষেধাজ্ঞার জন্য দেওয়ানি আদালতে মামলা বা আইনি নোটিশ প্রেরণ করুন।'
      },
    ];

    setState(() {
      _messages.add(
        ChatMessage(
          sender: 'app',
          text: "আপনার সমস্যার জন্য প্রস্তুতকৃত আইনগত সমাধান রোডম্যাপ নিচে দেয়া হলো:",
          type: MessageType.roadmap,
          roadmapSteps: steps,
        ),
      );
    });
    _saveEntireSessionHistory();
  }

  // Saves the whole conversation under a single session entry in SharedPreferences
  Future<void> _saveEntireSessionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawSessions = prefs.getStringList('chat_sessions') ?? [];

    String firstUserMessage = _messages.firstWhere(
      (m) => m.sender == 'user',
      orElse: () => ChatMessage(sender: 'user', text: 'New Consultation'),
    ).text;

    Map<String, dynamic> sessionData = {
      'id': _sessionId,
      'title': firstUserMessage,
      'date': DateTime.now().toString().split(' ')[0],
      'messages': _messages.map((m) => m.toJson()).toList(),
    };

    int existingIndex = rawSessions.indexWhere((s) {
      Map<String, dynamic> decoded = jsonDecode(s);
      return decoded['id'] == _sessionId;
    });

    if (existingIndex != -1) {
      rawSessions[existingIndex] = jsonEncode(sessionData);
    } else {
      rawSessions.add(jsonEncode(sessionData));
    }

    await prefs.setStringList('chat_sessions', rawSessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal GPS Assistant')),
      body: Column(
        children: [
          if (_isRecording) _buildVoiceRecorderPanel(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg.sender == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF0F5257) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14),
                          ),
                        ),
                        if (msg.type == MessageType.documentChecklist && msg.checklist != null)
                          _buildInteractiveChecklistCard(msg.checklist!),
                        if (msg.type == MessageType.roadmap && msg.roadmapSteps != null)
                          _buildGeminiRoadmapCard(msg.roadmapSteps!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your legal query...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0F5257)),
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInteractiveChecklistCard(List<Map<String, dynamic>> items) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rule_folder, color: Color(0xFF0F5257)),
                SizedBox(width: 8),
                Text('Document Verification Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            ...items.map((item) {
              bool isDone = item['checked'] as bool;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : Icons.cancel,
                      color: isDone ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['title'],
                        style: TextStyle(
                          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                          color: isDone ? Colors.black87 : Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isDone ? 'Uploaded' : 'Missing',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDone ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGeminiRoadmapCard(List<Map<String, String>> steps) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0F5257).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF0F5257)),
              SizedBox(width: 8),
              Text('Legal GPS Action Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          ...steps.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: Color(0xFF0F5257), width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s['step']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5257))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text(s['law']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(s['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(s['desc']!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVoiceRecorderPanel() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.graphic_eq, color: Colors.red),
              SizedBox(width: 8),
              Text('Recording audio... (Simulated)', style: TextStyle(color: Colors.red)),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _isRecording = false);
              _sendMessage("আমার জমি সংক্রান্ত সাহায্য লাগবে");
            },
            child: const Text('Stop & Send', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
