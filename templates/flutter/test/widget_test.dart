import 'package:flutter_test/flutter_test.dart';

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
}
