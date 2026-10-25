import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/conversations/presentation/qoshni_conversation_validation.dart';

void main() {
  test('normalizes whitespace in message body', () {
    expect(
      normalizeQoshniConversationMessageBody('  hello   demo  '),
      'hello demo',
    );
  });

  test('rejects empty and markup bodies', () {
    expect(qoshniConversationMessageBodyValidationError('   '), 'empty_message');
    expect(
      qoshniConversationMessageBodyValidationError('<b>hi</b>'),
      'markup_not_allowed',
    );
    expect(
      qoshniConversationMessageBodyValidationError('visit https://evil.test'),
      'url_not_allowed',
    );
  });
}
