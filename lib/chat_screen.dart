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
        'checklist': checklist,
        'roadmapSteps': roadmapSteps,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        sender: json['sender'],
        text: json['text'],
        type: MessageType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MessageType.text,
        ),
        checklist: json['checklist'] != null
            ? List<Map<String, dynamic>>.from(json['checklist'])
            : null,
        roadmapSteps: json['roadmapSteps'] != null
            ? (json['roadmapSteps'] as List)
                .map((e) => Map<String, String>.from(e))
                .toList()
            : null,
      );
}

class ChatScreen extends StatefulWidget {
  final String? initialQuery;
  final bool startVoiceRecorder;
  final String? existingSessionId;

  const ChatScreen({
    super.key,
    this.initialQuery,
    this.startVoiceRecorder = false,
    this.existingSessionId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  int _storyStep = 0; // State variable step
  bool _isRecording = false;
  bool _isTyping = false;
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.existingSessionId ?? DateTime.now().millisecondsSinceEpoch.toString();

    if (widget.existingSessionId != null) {
      _loadExistingSession(widget.existingSessionId!);
    } else if (widget.startVoiceRecorder) {
      _isRecording = true;
    } else if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _sendMessage(widget.initialQuery!);
    }
  }

  Future<void> _loadExistingSession(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawSessions = prefs.getStringList('chat_sessions') ?? [];

    for (String s in rawSessions) {
      Map<String, dynamic> decoded = jsonDecode(s);
      if (decoded['id'] == sessionId) {
        List messagesJson = decoded['messages'] ?? [];
        setState(() {
          _messages.clear();
          _messages.addAll(messagesJson.map((m) => ChatMessage.fromJson(m)).toList());
          // RESTORE THE STORY STEP
          _storyStep = decoded['storyStep'] ?? 0;
        });
        break;
      }
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: text));
      _isTyping = true;
    });
    _saveSessionHistory();
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isTyping = false);
        _processStoryResponse(text);
      }
    });
  }

  void _processStoryResponse(String userText) {
    String lower = userText.toLowerCase();

    if (lower.contains('tnx') || lower.contains('thanks') || lower.contains('ধন্যবাদ')) {
      _addAppMessage("আপনাকে অনেক ধন্যবাদ! Legal GPS-এর সাথে থাকার জন্য স্বাগতম। আপনার যেকোনো আইনি প্রয়োজনে আমি আছি।");
      return;
    }

    if (lower.contains('jomi') || lower.contains('land') || lower.contains('জমি')) {
      _addAppMessage(
        "বাংলাদেশ সংবিধানের ৪২ নম্বর অনুচ্ছেদ (Article 42) অনুযায়ী প্রতিটি নাগরিকের সম্পত্তি অর্জন, ধারণ ও হস্তান্তরের অধিকার রয়েছে।\n\n"
        "এছাড়া State Acquisition and Tenancy Act, 1950 অনুযায়ী জমি সংক্রান্ত বিরোধ নিষ্পত্তিতে মালিকানা দলিল ও খতিয়ান অতি জরুরি।\n\n"
        "আমি কি আপনার প্রয়োজনীয় ডকুমেন্টগুলোর বর্তমান অবস্থা পরীক্ষা (Check) করে দেখব?",
      );
      _storyStep = 2;
      _saveSessionHistory();
      return;
    }

    if (_storyStep == 0) {
      _addAppMessage("Hello! Legal GPS-এ আপনাকে স্বাগতম। গণপ্রজাতন্ত্রী বাংলাদেশের সংবিধান এবং প্রচলিত আইন অনুযায়ী আপনার সমস্যা শুনছি। বলুন কীভাবে সাহায্য করতে পারি?");
      _storyStep = 1;
    } else if (_storyStep == 2 && (_isAffirmative(lower) || lower.contains('check') || lower.contains('চেক'))) {
      _showInitialPartialChecklist();
      _storyStep = 3;
    } else if (_storyStep == 3 && (lower.contains('again') || lower.contains('check') || lower.contains('upload') || lower.contains('চেক'))) {
      _showAllCompletedChecklist();
      _storyStep = 4;
    } else if (_storyStep == 4 && (_isAffirmative(lower) || lower.contains('roadmap') || lower.contains('রোডম্যাপ'))) {
      _generateRoadmapWidget();
      _storyStep = 5;
    } else {
      _addAppMessage("ধন্যবাদ! অন্য যেকোনো আইনি পরামর্শ বা ধারা জানতে আমাকে প্রশ্ন করতে পারেন।");
    }

    _saveSessionHistory();
  }

  bool _isAffirmative(String input) {
    return input.contains('yes') || input.contains('koro') || input.contains('হ্যাঁ') || input.contains('করো') || input.contains('ok') || input.contains('করুন');
  }

  void _addAppMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(sender: 'app', text: text));
    });
  }

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
          text: "আপনার আপলোডকৃত ডকুমেন্টস পরীক্ষা করে পাওয়া গেছে:\n\n• ২ টি দলিল পাওয়া গেছে (Uploaded)\n• ২ টি দলিল অনুপস্থিত (Missing)\n\nঅনুপস্থিত ফাইলগুলো আপলোড করে আমাকে 'Check Again' বললে আমি পুনরায় পুরোটি রিভিউ করব।",
          type: MessageType.documentChecklist,
          checklist: initialItems,
        ),
      );
    });
  }

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
          text: "চমৎকার! আপনার সকল প্রয়োজনীয় ফাইল সফলভাবে জমা হয়েছে (৪/৪ সম্পন্ন)।\n\nসবগুলো তথ্য সঠিকভাবে নিবন্ধিত মনে হচ্ছে। আমি কি আপনার আইনি সমাধানের জন্য অ্যাকশন রোডম্যাপ (Roadmap) তৈরি করব?",
          type: MessageType.documentChecklist,
          checklist: completedItems,
        ),
      );
    });
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
          text: "আপনার জন্য প্রস্তুতকৃত আইনি পদক্ষেপের বিস্তারিত সমাধান রোডম্যাপ:",
          type: MessageType.roadmap,
          roadmapSteps: steps,
        ),
      );
    });
  }

  Future<void> _saveSessionHistory() async {
    if (_messages.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawSessions = prefs.getStringList('chat_sessions') ?? [];

    String firstUserMessage = _messages.firstWhere(
      (m) => m.sender == 'user',
      orElse: () => ChatMessage(sender: 'user', text: 'Legal Consultation'),
    ).text;

    Map<String, dynamic> sessionData = {
      'id': _sessionId,
      'title': firstUserMessage,
      'date': DateTime.now().toString().split(' ')[0],
      'storyStep': _storyStep, // PERSIST STORY STEP
      'messages': _messages.map((m) => m.toJson()).toList(),
    };

    int existingIndex = rawSessions.indexWhere((s) {
      Map<String, dynamic> decoded = jsonDecode(s);
      return decoded['id'] == _sessionId;
    });

    if (existingIndex != -1) {
      rawSessions[existingIndex] = jsonEncode(sessionData);
    } else {
      rawSessions.insert(0, jsonEncode(sessionData));
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
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }

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

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F5257)),
            ),
            const SizedBox(width: 10),
            Text(
              'Legal GPS thinking...',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
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
