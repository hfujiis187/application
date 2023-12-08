//MyAppとMapPage用
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:task2/main.dart';

void main() {
  testWidgets('MyApp Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Flutter Map Demo'), findsOneWidget);
  });

  testWidgets('MapPage Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MapPage()));

    expect(find.byType(MapPage), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Flutter Map Demo'), findsOneWidget);
  });
}
