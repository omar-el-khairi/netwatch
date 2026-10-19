import 'package:flutter_test/flutter_test.dart';
import 'package:supervision_mobile/main.dart';

void main() {
  testWidgets('NetWatch app builds', (tester) async {
    await tester.pumpWidget(const NetWatchApp());
    await tester.pump();
    expect(find.text('NetWatch'), findsWidgets);
  });
}
