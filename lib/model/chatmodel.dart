import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/core/app_constants.dart';
import 'package:flutter_chatgpt/core/error_handler.dart';
import 'package:flutter_chatgpt/model/chat_message.dart';
import 'package:flutter_chatgpt/repository/openai_repository.dart';
import 'package:flutter_chatgpt/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chat Model
class ChatModel extends ChangeNotifier {
  ChatModel() {
    _loadHistory();
  }

  int _idSeed = 0;

  /// List of messages (immutable view).
  final List<ChatMessage> _messages = [];

  /// Message list getter.
  UnmodifiableListView<ChatMessage> get messages =>
      UnmodifiableListView(_messages);

  /// Load chat history from storage
  Future<void> _loadHistory() async {
    final history = await StorageService.instance.loadChatHistory();
    _messages.clear();
    _messages.addAll(history);
    if (_messages.isNotEmpty) {
      _idSeed = int.tryParse(_messages.last.id) ?? 0;
    }
    notifyListeners();
  }

  /// Save chat history to storage
  Future<void> _saveHistory() async {
    await StorageService.instance.saveChatHistory(_messages);
  }

  /// Sends chat request to OpenAI chat server.
  Future<void> sendChat(String rawInput) async {
    final request = _ChatRequest.parse(rawInput);
    if (request == null) {
      return;
    }

    final placeholder = request.type == _ChatTaskType.image
        ? AppConstants.imagePlaceholder
        : AppConstants.defaultPlaceholder;
    addUserMessage(request.displayText, placeholder: placeholder);

    try {
      if (request.type == _ChatTaskType.image) {
        final imageUrl =
            await OpenAiRepository.generateImage(prompt: request.prompt);
        _completeWithImage(
          imageUrl: imageUrl,
          description: request.prompt,
        );
        return;
      }

      final historySnapshot = List<ChatMessage>.from(_messages);
      var latestContent = '';

      await for (final partial
          in OpenAiRepository.stream(history: historySnapshot)) {
        if (partial.isEmpty) {
          continue;
        }
        latestContent = partial;
        addStreamingUpdate(latestContent);
      }

      if (latestContent.isEmpty) {
        final finalHistory = List<ChatMessage>.from(_messages);
        latestContent = await OpenAiRepository.generate(history: finalHistory);
        if (latestContent.isNotEmpty) {
          addStreamingUpdate(latestContent);
        }
      }

      completeStreaming(latestContent);
    } catch (e) {
      _handleAssistantError(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Adds a new message to the list.
  void addUserMessage(
    String txt, {
    String placeholder = AppConstants.defaultPlaceholder,
  }) {
    final sanitized = txt.trim();
    if (sanitized.isEmpty) {
      return;
    }

    _messages
      ..add(
        ChatMessage(
          id: _nextId(),
          sender: ChatSender.user,
          text: sanitized,
          status: ChatMessageStatus.complete,
          timestamp: DateTime.now(),
        ),
      )
      ..add(
        ChatMessage(
          id: _nextId(),
          sender: ChatSender.assistant,
          text: placeholder,
          status: ChatMessageStatus.loading,
          timestamp: DateTime.now(),
        ),
      );
    notifyListeners();
    _saveHistory();
  }

  /// Adds a streaming message update
  void addStreamingUpdate(String partialContent) {
    if (_messages.isEmpty) {
      return;
    }

    final lastIndex = _messages.length - 1;
    final lastMessage = _messages[lastIndex];

    if (lastMessage.sender != ChatSender.assistant || lastMessage.hasImage) {
      return;
    }

    _messages[lastIndex] = lastMessage.copyWith(
      text: partialContent,
      status: ChatMessageStatus.streaming,
    );
    notifyListeners();
  }

  String _nextId() {
    _idSeed += 1;
    return _idSeed.toString();
  }

  void completeStreaming(String content) {
    if (_messages.isEmpty) {
      return;
    }

    final lastIndex = _messages.length - 1;
    final lastMessage = _messages[lastIndex];
    if (lastMessage.sender != ChatSender.assistant) {
      return;
    }

    if (lastMessage.hasImage) {
      return;
    }

    _messages[lastIndex] = lastMessage.copyWith(
      text: content.isEmpty ? lastMessage.text : content,
      status: ChatMessageStatus.complete,
    );
    notifyListeners();
    _saveHistory();
  }

  void _handleAssistantError(String message) {
    if (_messages.isNotEmpty &&
        _messages.last.sender == ChatSender.assistant &&
        !_messages.last.isComplete) {
      _messages.removeLast();
    }

    _messages.add(
      ChatMessage(
        id: _nextId(),
        sender: ChatSender.assistant,
        text: message,
        status: ChatMessageStatus.complete,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
    _saveHistory();
  }

  void _completeWithImage({
    required String imageUrl,
    required String description,
  }) {
    if (_messages.isEmpty) {
      return;
    }

    final lastIndex = _messages.length - 1;
    final lastMessage = _messages[lastIndex];
    if (lastMessage.sender != ChatSender.assistant) {
      return;
    }

    _messages[lastIndex] = lastMessage.copyWith(
      text: description.isEmpty ? 'Generated image.' : 'Generated image:',
      altText: description.isNotEmpty ? description : null,
      imageUrl: imageUrl,
      status: ChatMessageStatus.complete,
    );
    notifyListeners();
    _saveHistory();
  }

  /// Delete a message by ID
  void deleteMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
    _saveHistory();
  }

  /// Delete all messages
  Future<void> clearChat() async {
    _messages.clear();
    notifyListeners();
    await StorageService.instance.clearChatHistory();
  }

  /// Edit a user message
  void editMessage(String messageId, String newText) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1 && _messages[index].sender == ChatSender.user) {
      _messages[index] = _messages[index].copyWith(
        text: newText.trim(),
        timestamp: DateTime.now(),
      );
      notifyListeners();
      _saveHistory();
    }
  }

  /// Export chat as markdown
  String exportChat() {
    return StorageService.instance.exportAsMarkdown(_messages);
  }
}

final chatProvider = ChangeNotifierProvider((ref) => ChatModel());

enum _ChatTaskType { text, image }

class _ChatRequest {
  const _ChatRequest({
    required this.type,
    required this.displayText,
    required this.prompt,
  });

  final _ChatTaskType type;
  final String displayText;
  final String prompt;

  static _ChatRequest? parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final lower = trimmed.toLowerCase();
    const prefixes = ['/image', '/img', 'image:', 'img:'];
    for (final prefix in prefixes) {
      if (lower.startsWith(prefix)) {
        final prompt = trimmed.substring(prefix.length).trim();
        if (prompt.isEmpty) {
          break;
        }
        return _ChatRequest(
          type: _ChatTaskType.image,
          displayText: trimmed,
          prompt: prompt,
        );
      }
    }

    return _ChatRequest(
      type: _ChatTaskType.text,
      displayText: trimmed,
      prompt: trimmed,
    );
  }
}
