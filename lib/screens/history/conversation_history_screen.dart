import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/conversation.dart';
import '../../providers/chat/chat_initialization_provider.dart';
import '../../providers/chat/chat_provider.dart';
import '../../providers/conversations/conversations_provider.dart';
import '../../router/routes.dart';
import '../../theme/lumina_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/lumina_app_bar.dart';
import '../../widgets/lumina_background.dart';

class ConversationHistoryScreen extends ConsumerWidget {
  const ConversationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: LuminaAppBar(
        title: 'Cronologia',
        onBack: () => context.go(modelSelectionRoute),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewChat(context, ref),
        backgroundColor: LuminaColors.primary,
        foregroundColor: LuminaColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nuova chat'),
      ),
      body: LuminaBackground(
        child: conversations.isEmpty
            ? _EmptyHistory(onNewChat: () => _startNewChat(context, ref))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Le tue conversazioni',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gestisci e riapri le chat passate.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final conversation = conversations[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ConversationTile(
                            conversation: conversation,
                            isActive: ref
                                    .read(conversationsProvider.notifier)
                                    .activeConversationId ==
                                conversation.id,
                            onTap: () =>
                                _openConversation(context, ref, conversation),
                          ),
                        );
                      },
                      childCount: conversations.length,
                    ),
                  ),
                  ),
                ],
              ),
      ),
    );
  }

  void _startNewChat(BuildContext context, WidgetRef ref) {
    ref.invalidate(chatInitializationProvider);
    ref.read(conversationsProvider.notifier).startNewConversation();
    ref.read(chatProvider.notifier).clearMessages();
    context.go(chatRoute);
  }

  void _openConversation(
    BuildContext context,
    WidgetRef ref,
    Conversation conversation,
  ) {
    ref.invalidate(chatInitializationProvider);
    ref.read(conversationsProvider.notifier).loadConversation(conversation.id);
    ref.read(chatProvider.notifier).loadMessages(conversation.messages);
    context.go(chatRoute);
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.isActive,
    required this.onTap,
  });

  final Conversation conversation;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isActive: isActive,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          if (isActive)
            Container(
              width: 4,
              height: 48,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: LuminaColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? LuminaColors.secondaryContainer.withValues(alpha: 0.5)
                  : LuminaColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconData(conversation.iconName),
              color: isActive
                  ? LuminaColors.secondary
                  : LuminaColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _relativeTime(conversation.updatedAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isActive
                                ? LuminaColors.primary
                                : LuminaColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  conversation.preview.isEmpty
                      ? 'Nessun messaggio'
                      : conversation.preview,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconData(String name) {
    return switch (name) {
      'terminal' => Icons.terminal,
      'palette' => Icons.palette_outlined,
      'psychology' => Icons.psychology_outlined,
      _ => Icons.chat_bubble_outline,
    };
  }

  static String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m fa';
    if (diff.inHours < 24) return '${diff.inHours}h fa';
    if (diff.inDays < 7) return '${diff.inDays}g fa';
    return '${time.day}/${time.month}';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onNewChat});

  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 56, color: LuminaColors.outline),
            const SizedBox(height: 16),
            Text(
              'Nessuna conversazione',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Le chat che avvii appariranno qui.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onNewChat,
              icon: const Icon(Icons.add),
              label: const Text('Inizia una chat'),
            ),
          ],
        ),
      ),
    );
  }
}
