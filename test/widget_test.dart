import 'package:flutter_test/flutter_test.dart';

import 'package:centro_juegos/main.dart';

void main() {
  testWidgets(
    'La aplicación inicia correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CentroJuegosApp());

      expect(
        find.text('🎮 Centro de Juegos'),
        findsOneWidget,
      );
    },
  );
}