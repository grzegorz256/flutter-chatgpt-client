import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_chatgpt/model/chatmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class UserInput extends ConsumerWidget {
  const UserInput({
    super.key,
    required this.chatcontroller,
    this.onMessageSent,
  });

  final TextEditingController chatcontroller;
  final VoidCallback? onMessageSent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void sendCurrentText() {
      final text = chatcontroller.text;
      if (text.trim().isEmpty) {
        return;
      }
      ref.read(chatProvider).sendChat(text);
      chatcontroller.clear();
      onMessageSent?.call();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 5,
          right: 5,
        ),
        decoration: const BoxDecoration(
          color: FcColors.white,
          border: Border(
            top: BorderSide(
              color: FcColors.white,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'images/user-question.svg',
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                onFieldSubmitted: (e) {
                  sendCurrentText();
                },
                controller: chatcontroller,
                textInputAction: TextInputAction.send,
                style: const TextStyle(
                  color: FcColors.black,
                ),
                decoration: InputDecoration(
                  focusColor: FcColors.gray,
                  filled: true,
                  fillColor: FcColors.white,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: FcColors.gray,
                    ),
                    onPressed: sendCurrentText,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FcColors.gray,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FcColors.gray,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
