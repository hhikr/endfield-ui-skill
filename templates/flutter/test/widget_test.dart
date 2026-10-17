import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:endfield_example/ef/tokens.dart';
import 'package:endfield_example/main.dart';

void main() {
  testWidgets('every tab opens its screen', (tester) async {
    await tester.pumpWidget(const EfApp());
    expect(find.text('仓储网络的工作记录'), findsOneWidget);

    for (final (tab, title) in [('记录', '搜索标题、编号'), ('状态', '有 2 条记录等待审核。'), ('设置', '保存')]) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('the list opens and closes its action sheet', (tester) async {
    await tester.pumpWidget(const EfApp());
    await tester.tap(find.text('记录').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('筛选'));
    await tester.pumpAndSettle();
    expect(find.text('复制编号'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('复制编号'), findsNothing);
  });

  test('another accent reaches fills, and the dark trace line', () {
    final light = efTheme(Brightness.light, accent: EfAccent.ice).extension<EfColors>()!;
    final dark = efTheme(Brightness.dark, accent: EfAccent.ice).extension<EfColors>()!;
    expect(light.signal, EfAccent.ice);
    expect(light.trace, EfColors.light.ink);
    expect(dark.trace, EfAccent.ice);
  });
}
