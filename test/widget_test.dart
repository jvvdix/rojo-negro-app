import 'package:flutter_test/flutter_test.dart';

import 'package:rojo_negro_app/main.dart';

void main() {
  testWidgets('El menú muestra los 3 modos de juego', (WidgetTester tester) async {
    await tester.pumpWidget(const RojoNegroApp());

    expect(find.text('ROJO O NEGRO'), findsOneWidget);
    expect(find.text('OCALIMOCHO'), findsOneWidget);
    expect(find.text('RINGO'), findsOneWidget);
  });
}
