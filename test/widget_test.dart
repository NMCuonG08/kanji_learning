import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_learning/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KanjiApp());
    expect(find.text('漢字マスター'), findsOneWidget);
  });
}