import 'package:flutter_test/flutter_test.dart';

import 'package:smart_gallery/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartGalleryApp());

    // Verify the app title is shown
    expect(find.text('Smart Gallery'), findsOneWidget);
  });
}
