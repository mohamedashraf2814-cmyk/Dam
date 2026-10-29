import 'package:flutter_test/flutter_test.dart';

import 'package:damstock_code_guide/data/bot.dart';

void main() {
  test('arabic normalization', () {
    expect(CodeBot.normalize('الخريطة؟'), 'الخريطه ');
    expect(CodeBot.tokens('إيه وظيفة الخريطة'), contains('خريطه'));
  });
}
