
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:okey_hesaplama/main.dart';

void main() {
  testWidgets('SetupPage has default values', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OkeySkorApp());

    // Verify that HistoryPage is shown by finding "Oyun Geçmişi" title.
    expect(find.text('Oyun Geçmişi'), findsOneWidget);
  });
}
