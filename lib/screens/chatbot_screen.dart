// lib/screens/chatbot_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:student_app/screens/auth_service.dart' show AuthService;
import 'package:student_app/screens/theme.dart';
import 'package:student_app/screens/user_model.dart';

class ChatbotScreen extends StatefulWidget {
  final UserModel user;
  const ChatbotScreen({super.key, required this.user});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _loading = false;

  static const _apiKey = 'YOUR_ANTHROPIC_API_KEY_HERE'; // Replace with your key

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final h = await AuthService.getChatHistory(widget.user.uid);
    setState(() => _messages = h);
    if (_messages.isEmpty) {
      setState(() => _messages.add({
            'role': 'assistant',
            'content':
                'Hello ${widget.user.name.split(' ').first}! 👋 I\'m your AI Study Tutor. Ask me anything about your subjects, study strategies, or how to improve your academic performance!',
          }));
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    _ctrl.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _loading = true;
    });
    _scroll();

    try {
      // Build context from performance data
      final history = await AuthService.getPerformanceHistory(widget.user.uid);
      String contextStr = '';
      if (history.isNotEmpty) {
        final latest = history.last;
        contextStr =
            'Student context: ${widget.user.name}, Class ${widget.user.studentClass}, '
            'Overall: ${latest.overallPercentage.toStringAsFixed(1)}%, '
            'Attendance: ${latest.attendancePercent}%, '
            'Study hours: ${latest.studyHoursPerDay}h/day. ';
      }

      final apiMessages = _messages
          .where((m) => m['role'] != 'assistant' || _messages.indexOf(m) != 0)
          .map((m) => {'role': m['role'], 'content': m['content']})
          .toList();

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'system': '${contextStr}You are a helpful, encouraging AI Study Tutor for a student. '
              'Help with academics, study techniques, subject doubts, and performance improvement. '
              'Be friendly, concise, and supportive. Use simple language appropriate for a student.',
          'messages': apiMessages,
        }),
      );

      final data = jsonDecode(response.body);
      final reply = data['content']?[0]?['text'] ??
          'Sorry, I could not respond right now.';

      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _loading = false;
      });
      await AuthService.saveChatHistory(widget.user.uid, _messages);
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content':
              'Sorry, I\'m having trouble connecting. Please check your internet connection and try again.'
        });
        _loading = false;
      });
    }
    _scroll();
  }

  void _scroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), AppTheme.primary]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Study Tutor',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Text('Powered by Claude',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppTheme.textSecondary),
            onPressed: () async {
              setState(() => _messages = []);
              await AuthService.saveChatHistory(widget.user.uid, []);
              await _loadHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return _typingIndicator();
                final m = _messages[i];
                final isUser = m['role'] == 'user';
                return _bubble(m['content']!, isUser);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _bubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), AppTheme.primary]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Text(text,
                  style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: isUser ? Colors.white : AppTheme.textPrimary,
                      height: 1.5)),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(widget.user.avatarInitials,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), AppTheme.primary]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _dot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + i * 200),
      builder: (_, v, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.3 + v * 0.7),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask your study question...',
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                hintStyle: GoogleFonts.poppins(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: _loading ? AppTheme.border : AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _loading ? null : _send,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
