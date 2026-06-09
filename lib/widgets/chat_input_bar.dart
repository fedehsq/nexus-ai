import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/lumina_colors.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: LuminaColors.surface.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: LuminaColors.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: isLoading ? null : () {},
                  icon: const Icon(Icons.add, color: LuminaColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        LuminaColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: LuminaColors.surfaceContainerHigh
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      enabled: !isLoading,
                      maxLines: 5,
                      minLines: 1,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Scrivi un messaggio...',
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: LuminaColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: isLoading ? null : onSend,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: Icon(
                        isLoading ? Icons.hourglass_top : Icons.arrow_upward,
                        color: LuminaColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
