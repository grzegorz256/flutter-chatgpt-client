import 'package:flutter/foundation.dart';

enum ChatSender {
  user,
  assistant,
}

enum ChatMessageStatus {
  loading,
  streaming,
  complete,
}

@immutable
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.status,
    this.imageUrl,
    this.altText,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime(1970);

  final String id;

  final ChatSender sender;

  final String text;

  final String? imageUrl;

  final String? altText;

  final ChatMessageStatus status;

  final DateTime timestamp;

  bool get isLoading => status == ChatMessageStatus.loading;

  bool get isStreaming => status == ChatMessageStatus.streaming;

  bool get isComplete => status == ChatMessageStatus.complete;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    ChatSender? sender,
    String? text,
    ChatMessageStatus? status,
    String? imageUrl,
    String? altText,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      altText: altText ?? this.altText,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.name,
      'text': text,
      'status': status.name,
      'imageUrl': imageUrl,
      'altText': altText,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sender: ChatSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => ChatSender.user,
      ),
      text: json['text'] as String,
      status: ChatMessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChatMessageStatus.complete,
      ),
      imageUrl: json['imageUrl'] as String?,
      altText: json['altText'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
