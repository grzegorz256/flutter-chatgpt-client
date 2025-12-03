import 'package:flutter/material.dart';

/// Service for managing scroll behavior
class ScrollService {
  ScrollService(this._controller);

  final ScrollController _controller;

  /// Scrolls to bottom immediately
  void scrollToBottom() {
    if (!_controller.hasClients) return;
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  /// Scrolls to bottom with animation
  Future<void> scrollToBottomAnimated() async {
    if (!_controller.hasClients) return;
    await _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Scrolls to bottom after frame is built
  void scrollToBottomAfterFrame() {
    if (!_controller.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }

  /// Scrolls to bottom with retry logic for streaming updates
  void scrollToBottomForStream() {
    if (!_controller.hasClients) return;

    scrollToBottom();
    scrollToBottomAfterFrame();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }
}

