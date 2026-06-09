import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/chat/chat_screen.dart';
import '../screens/history/conversation_history_screen.dart';
import '../screens/model_selection/model_selection_screen.dart';
import '../screens/settings/model_settings_screen.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: modelSelectionRoute,
  routes: [
    GoRoute(
      path: modelSelectionRoute,
      builder: (context, state) => const ModelSelectionScreen(),
    ),
    GoRoute(
      path: historyRoute,
      builder: (context, state) => const ConversationHistoryScreen(),
    ),
    GoRoute(
      path: chatRoute,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: settingsRoute,
      builder: (context, state) => const ModelSettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route non trovata: ${state.uri}')),
  ),
);
