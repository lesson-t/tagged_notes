import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagged_notes/di/providers.dart';
import '../fakes/in_memory_store.dart';

Widget buildTestApp({required Widget home}) {
  return ProviderScope(
    overrides: [keyValueStoreProvider.overrideWithValue(InMemoryStore())],
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

Future<void> setTestSurfaceSize(
  WidgetTester tester, {
  Size size = const Size(1200, 900),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null); // 元に戻す
  });
}
