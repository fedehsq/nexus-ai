import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../theme/lumina_colors.dart';
import 'lumina_markdown_body.dart';

class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  final AppChatMessage message;
  final bool isStreaming;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool _userExpandedReasoning = false;

  @override
  void didUpdateWidget(ChatMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.isReasoningInProgress &&
        !widget.message.isReasoningInProgress) {
      _userExpandedReasoning = false;
    }
  }

  bool get _autoExpandReasoning =>
      widget.message.isReasoningInProgress ||
      (widget.isStreaming &&
          widget.message.reasoning != null &&
          widget.message.content.trim().isEmpty);

  bool get _showReasoningExpanded =>
      _userExpandedReasoning || _autoExpandReasoning;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == AppChatRole.user;
    final hasReasoning = widget.message.reasoning != null && !isUser;
    final hasResponse = widget.message.content.trim().isNotEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: LuminaColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Nexus AI',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (hasReasoning)
              Padding(
                padding: EdgeInsets.only(bottom: hasResponse ? 10 : 0),
                child: _ThinkingPanel(
                  reasoning: widget.message.reasoning!,
                  isStreaming: widget.message.isReasoningInProgress,
                  isExpanded: _showReasoningExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() => _userExpandedReasoning = expanded);
                  },
                ),
              ),
            if (hasResponse || isUser)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser
                      ? LuminaColors.primary
                      : LuminaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color: LuminaColors.outlineVariant.withValues(
                            alpha: 0.15,
                          ),
                        ),
                  boxShadow: isUser
                      ? [
                          BoxShadow(
                            color:
                                LuminaColors.primary.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: LuminaMarkdownBody(
                  data: widget.message.content,
                  isUser: isUser,
                ),
              ),
            if (!isUser &&
                widget.message.isReasoningInProgress &&
                !hasResponse)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LuminaColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sto formulando la risposta...',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: LuminaColors.onSurfaceVariant
                                .withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              _formatTime(widget.message.timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _ThinkingPanel extends StatelessWidget {
  const _ThinkingPanel({
    required this.reasoning,
    required this.isStreaming,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  final String reasoning;
  final bool isStreaming;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  static const _mutedTextOpacity = 0.38;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineCount = reasoning.split('\n').where((l) => l.trim().isNotEmpty).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onExpansionChanged(!isExpanded),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: LuminaColors.surfaceContainerHighest.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(
                color: LuminaColors.primary.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.blur_on_rounded,
                    size: 14,
                    color: isStreaming
                        ? LuminaColors.primary.withValues(alpha: 0.75)
                        : LuminaColors.onSurfaceVariant
                            .withValues(alpha: _mutedTextOpacity + 0.15),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isStreaming ? 'Thinking...' : 'Thinking',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w500,
                        color: LuminaColors.onSurfaceVariant
                            .withValues(alpha: _mutedTextOpacity + 0.12),
                      ),
                    ),
                  ),
                  if (isStreaming)
                    SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: LuminaColors.primary.withValues(alpha: 0.55),
                      ),
                    )
                  else
                    Text(
                      isExpanded ? '▾' : '▸',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: LuminaColors.onSurfaceVariant
                            .withValues(alpha: _mutedTextOpacity),
                      ),
                    ),
                ],
              ),
              if (!isExpanded && !isStreaming) ...[
                const SizedBox(height: 4),
                Text(
                  'Processo interno · $lineCount righe',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: LuminaColors.onSurfaceVariant
                        .withValues(alpha: _mutedTextOpacity),
                  ),
                ),
              ],
              if (isExpanded) ...[
                const SizedBox(height: 8),
                _ThinkingBody(
                  reasoning: reasoning,
                  isStreaming: isStreaming,
                ),
              ] else if (isStreaming) ...[
                const SizedBox(height: 6),
                _ThinkingPreview(reasoning: reasoning),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThinkingPreview extends StatelessWidget {
  const _ThinkingPreview({required this.reasoning});

  final String reasoning;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white,
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Text(
              reasoning,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    height: 1.4,
                    color: LuminaColors.onSurfaceVariant
                        .withValues(alpha: _ThinkingPanel._mutedTextOpacity),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThinkingBody extends StatelessWidget {
  const _ThinkingBody({
    required this.reasoning,
    required this.isStreaming,
  });

  final String reasoning;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11.5,
          height: 1.45,
          letterSpacing: 0.15,
          color: LuminaColors.onSurfaceVariant
              .withValues(alpha: _ThinkingPanel._mutedTextOpacity),
        );

    final child = Text(reasoning, style: textStyle);

    if (!isStreaming) return child;

    return ClipRect(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.85),
          ],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: child,
      ),
    );
  }
}
