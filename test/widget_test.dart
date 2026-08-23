// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:suarawarga_ai/app/app.dart';
import 'package:suarawarga_ai/core/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots up smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.initLocalStorage(); // avoid errors with local storage

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const SuaraWargaApp(),
      ),
    );

    // Verify that the MaterialApp initializes correctly.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
