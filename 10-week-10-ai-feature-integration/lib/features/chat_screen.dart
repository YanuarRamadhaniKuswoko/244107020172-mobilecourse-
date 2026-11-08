import 'dart:async';
import 'package:flutter/material.dart';

import '../ai/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  final AiService? aiService;

  const ChatScreen({super.key, this.aiService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final AiService _aiService;
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isStreaming = false;

  // System prompt sesuai Jobsheet Bagian 3
  static const String _systemPrompt =
      'Kamu asisten kampus ramah, jawab dalam Bahasa Indonesia, maksimal 2 kalimat.';

  @override
  void initState() {
    super.initState();
    _aiService = widget.aiService ?? AiService();
    _messages.add(
      ChatMessage(
        text: 'Halo! Saya asisten AI kampus. Ada yang bisa saya bantu hari ini?',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Catatan Keamanan Jobsheet:
  /// Jangan kirim NIK, nomor telepon, atau data sensitif ke AI API.
  bool _containsSensitiveData(String text) {
    // Deteksi NIK (16 digit berurutan)
    final nikRegex = RegExp(r'\b\d{16}\b');
    // Deteksi nomor HP Indonesia (+62/62/08 dilanjutkan 8-12 digit)
    final phoneRegex = RegExp(r'(\+62|62|08)[0-9]{8,12}');

    return nikRegex.hasMatch(text) || phoneRegex.hasMatch(text);
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading || _isStreaming) return;

    // Validasi privasi sesuai kebijakan keamanan jobsheet
    if (_containsSensitiveData(text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Peringatan Privasi: Pesan mengandung NIK/Nomor Telepon sensitif. Harap gunakan data anonim.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Gabungkan system prompt dan user prompt
      final fullPrompt = '$_systemPrompt Pertanyaan: $text';
      final response = await _aiService.ask(fullPrompt);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isStreaming = true;
        // Tambahkan placeholder pesan AI yang akan di-stream
        _messages.add(ChatMessage(text: '', isUser: false));
      });

      // Streaming response animasi kata per kata
      final words = response.split(' ');
      String currentText = '';
      for (int i = 0; i < words.length; i++) {
        if (!mounted) break;
        currentText += (i == 0 ? '' : ' ') + words[i];
        final streamedText = currentText;
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            text: streamedText,
            isUser: false,
          );
        });
        _scrollToBottom();
        await Future.delayed(const Duration(milliseconds: 40));
      }

      if (mounted) {
        setState(() {
          _isStreaming = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isStreaming = false;
      });

      // Dialog Fallback sesuai materi jobsheet
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Layanan AI Sibuk'),
          content: const Text('Coba lagi nanti atau gunakan mode offline.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showApiKeyDialog();
              },
              child: const Text('Atur API Key'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showApiKeyDialog() async {
    final currentKey = await _aiService.getApiKey() ?? '';
    if (!mounted) return;

    final keyController = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengaturan API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Google Gemini API Key. Kunci akan disimpan aman via FlutterSecureStorage.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final newKey = keyController.text.trim();
              await _aiService.saveApiKey(newKey);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('API Key berhasil disimpan ke secure storage.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Campus Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            tooltip: 'Pengaturan API Key',
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner privasi aman
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Privasi terjaga: Jangan menyertakan NIK, password, atau nomor HP.',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI sedang mengetik jawaban...',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          // Input row
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan sesuatu ke AI asisten...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: (_isLoading || _isStreaming) ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                    tooltip: 'Kirim Pesan',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? 'Anda' : 'AI Assistant',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUser
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isUser
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
