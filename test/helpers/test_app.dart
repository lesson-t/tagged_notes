import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagged_notes/di/providers.dart';
import '../fakes/in_memory_store.dart';

Widget buildTestApp({
  required Widget home,
  InMemoryStore? storeOverride,
}) {
  final store = storeOverride ?? InMemoryStore();

  return ProviderScope(
    overrides: [keyValueStoreProvider.overrideWithValue(store)],
    child: MaterialApp(home: home),
  );
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 50,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsOneWidget);
}

Future<void> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 50,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(step);
    if (finder.evaluate().isEmpty) return;
  }
  // 最後に診断しやすいように失敗させる
  expect(finder, findsNothing);
}

Future<void> setTestSurfaceSize(
  WidgetTester tester, {
  Size size = const Size(3000, 900),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null); // 元に戻す
  });
}

Future<void> tapBarActionByIcon(
  WidgetTester tester,
  IconData icon, {
    int settlePumps = 12,
    Duration step = const Duration(milliseconds: 50),
}) async {
  final finder = find.byIcon(icon).hitTestable();
  // 出るまで待つ
  for (var i = 0; i < 50; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) break;
  }
  expect(finder, findsOneWidget);

  await tester.tap(finder);
  // 遷移開始〜完了まで少し進める（pumpAndSettle回避）
  for (var i = 0; i < settlePumps; i++) {
    await tester.pump(step);
  }
}
