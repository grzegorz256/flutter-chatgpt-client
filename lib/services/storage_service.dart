import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chatgpt/core/app_constants.dart';
import 'package:flutter_chatgpt/model/chat_message.dart';

/// Service for persisting chat data
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  /// Save chat history
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => m.toJson()).toList();
    await prefs.setString(
      AppConstants.chatHistoryKey,
      jsonEncode(jsonList),
    );
  }

  /// Load chat history
  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.chatHistoryKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.chatHistoryKey);
  }

  /// Export chat as markdown
  String exportAsMarkdown(List<ChatMessage> messages) {
    final buffer = StringBuffer();
    buffer.writeln('# Chat Export\n');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}\n');

    for (final message in messages) {
      if (!message.isComplete) continue;

      final sender = message.sender == ChatSender.user ? 'User' : 'Assistant';
      final time = message.timestamp.toString().substring(0, 19);
      buffer.writeln('## $sender - $time\n');
      buffer.writeln(message.text);
      buffer.writeln();
    }

    return buffer.toString();
  }
}

