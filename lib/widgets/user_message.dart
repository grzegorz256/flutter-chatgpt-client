import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UserMessage extends StatelessWidget {
  const UserMessage({
    super.key,
    required this.text,
    this.timestamp,
    this.onDelete,
    this.onEdit,
  });

  final String text;
  final DateTime? timestamp;
  final VoidCallback? onDelete;
  final void Function(String)? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF52B534) : FcColors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: SelectionArea(
                          onSelectionChanged: (content) async {
                            if (content != null) {
                              await Clipboard.setData(
                                ClipboardData(text: content.plainText),
                              );
                            }
                          },
                          child: Text(
                            text,
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                color: FcColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (onDelete != null || onEdit != null)
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: FcColors.white,
                            size: 16,
                          ),
                          onSelected: (value) {
                            if (value == 'delete' && onDelete != null) {
                              onDelete!();
                            } else if (value == 'edit' && onEdit != null) {
                              _showEditDialog(context);
                            }
                          },
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edytuj'),
                                  ],
                                ),
                              ),
                            if (onDelete != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 16, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Usuń', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8),
                    child: Text(
                      DateFormat('HH:mm').format(timestamp!),
                      style: TextStyle(
                        fontSize: 10,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edytuj wiadomość'),
        content: TextField(
          controller: controller,
          maxLines: null,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              if (onEdit != null && controller.text.trim().isNotEmpty) {
                onEdit!(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }
}
