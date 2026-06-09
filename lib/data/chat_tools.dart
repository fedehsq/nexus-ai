import 'package:cactus/cactus.dart' as cactus;
import 'package:flutter_gemma/flutter_gemma.dart';

abstract final class ChatTools {
  static const webSearchName = 'web_search';

  static const webSearchDescription =
      'Cerca informazioni aggiornate sul web quando la domanda '
      'riguarda eventi recenti, notizie, dati in tempo reale o fatti '
      'non presenti nella conoscenza del modello.';

  static const List<Tool> gemmaTools = [
    Tool(
      name: webSearchName,
      description: webSearchDescription,
      parameters: {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description':
                'Query di ricerca concisa in italiano o nella lingua della domanda.',
          },
        },
        'required': ['query'],
      },
    ),
  ];

  static List<cactus.CactusTool> get cactusTools => [
        cactus.CactusTool(
          name: webSearchName,
          description: webSearchDescription,
          parameters: cactus.ToolParametersSchema(
            properties: {
              'query': cactus.ToolParameter(
                type: 'string',
                description:
                    'Query di ricerca concisa in italiano o nella lingua della domanda.',
                required: true,
              ),
            },
          ),
        ),
      ];
}
