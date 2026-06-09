import 'package:cactus/cactus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/lumina_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CactusConfig.isTelemetryEnabled = false;
  FlutterGemma.initialize();
  runApp(const ProviderScope(child: SmartChatApp()));
}

class SmartChatApp extends StatelessWidget {
  const SmartChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nexus AI',
      debugShowCheckedModeBanner: false,
      theme: LuminaTheme.dark,
      darkTheme: LuminaTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
