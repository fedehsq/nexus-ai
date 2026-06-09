import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/chat_params.dart';

part 'chat_params_provider.g.dart';

@Riverpod(keepAlive: true)
class ChatParamsNotifier extends _$ChatParamsNotifier {
  @override
  ChatParams build() => const ChatParams();

  void setTemperature(double value) {
    state = state.copyWith(temperature: value);
  }

  void setMaxTokens(int value) {
    state = state.copyWith(maxTokens: value);
  }

  void setWebSearchEnabled(bool value) {
    state = state.copyWith(webSearchEnabled: value);
  }
}
