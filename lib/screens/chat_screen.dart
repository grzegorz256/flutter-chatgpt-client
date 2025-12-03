import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatgpt/core/app_constants.dart';
import 'package:flutter_chatgpt/core/error_handler.dart';
import 'package:flutter_chatgpt/core/scroll_service.dart';
import 'package:flutter_chatgpt/core/theme_service.dart';
import 'package:flutter_chatgpt/model/chat_message.dart';
import 'package:flutter_chatgpt/model/chatmodel.dart';
import 'package:flutter_chatgpt/widgets/ai_message.dart';
import 'package:flutter_chatgpt/widgets/loading.dart';
import 'package:flutter_chatgpt/widgets/user_input.dart';
import 'package:flutter_chatgpt/widgets/user_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

/// Main chat screen
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  late ScrollService _scrollService;

  @override
  void initState() {
    super.initState();
    _scrollService = ScrollService(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleMessageUpdate() {
    _scrollService.scrollToBottomForStream();
  }

  @override
  Widget build(BuildContext context) {
    final chatModel = ref.watch(chatProvider);
    final messages = chatModel.messages;
    final theme = Theme.of(context);

    // Auto-scroll when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollService.scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              return IconButton(
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
                tooltip: 'Przełącz motyw',
              );
            },
          ),
          if (messages.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                switch (value) {
                  case 'export':
                    _exportChat(context, chatModel);
                    break;
                  case 'clear':
                    _clearChat(context, chatModel);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Eksportuj czat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 8),
                      Text('Wyczyść czat'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          if (messages.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rozpocznij rozmowę',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: AppConstants.inputBottomMargin),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageWidget(message, chatModel);
              },
            ),
          UserInput(
            chatcontroller: _textController,
            onMessageSent: _handleMessageUpdate,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(ChatMessage message, ChatModel chatModel) {
    switch (message.sender) {
      case ChatSender.user:
        return UserMessage(
          key: ValueKey(message.id),
          text: message.text,
          timestamp: message.timestamp,
          onDelete: () => chatModel.deleteMessage(message.id),
          onEdit: (newText) => chatModel.editMessage(message.id, newText),
        );
      case ChatSender.assistant:
        if (message.isLoading) {
          return Loading(
            key: ValueKey(message.id),
            text: message.text,
          );
        }
        return AiMessage(
          key: ValueKey(message.id),
          text: message.text,
          imageUrl: message.imageUrl,
          altText: message.altText,
          isStreaming: message.isStreaming,
          timestamp: message.timestamp,
          onCopy: () => _copyToClipboard(context, message.text),
        );
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ErrorHandler.showSuccess(context, 'Skopiowano do schowka');
  }

  Future<void> _exportChat(BuildContext context, ChatModel chatModel) async {
    try {
      final markdown = chatModel.exportChat();
      await share_plus.Share.share(markdown, subject: 'Eksport czatu');
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showError(context, 'Nie udało się wyeksportować czatu');
      }
    }
  }

  Future<void> _clearChat(BuildContext context, ChatModel chatModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wyczyścić czat?'),
        content: const Text('Wszystkie wiadomości zostaną usunięte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Wyczyść'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await chatModel.clearChat();
      if (context.mounted) {
        ErrorHandler.showSuccess(context, 'Czat wyczyszczony');
      }
    }
  }
}

