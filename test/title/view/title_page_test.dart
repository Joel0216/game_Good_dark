import 'package:echo_world/l10n/l10n.dart';
import 'package:echo_world/title/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TitlePage', () {
    testWidgets('renders TitleFocusHandler', (tester) async {
      await tester.pumpApp(const TitlePage());
      expect(find.byType(TitleFocusHandler), findsOneWidget);
    });
  });

  group('TitleFocusHandler', () {
    testWidgets('renders 6 buttons', (tester) async {
      await tester.pumpApp(const TitleFocusHandler());
      expect(find.byType(ElevatedButton), findsNWidgets(6));
    });

    testWidgets('starts the game when start button is tapped', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final navigator = MockNavigator();
      when(navigator.canPop).thenReturn(true);
      when(
        () => navigator.pushReplacement<void, void>(any()),
      ).thenAnswer((_) async {});

      await tester.pumpApp(const TitleFocusHandler(), navigator: navigator);

      await tester.tap(find.text(l10n.titleButtonStart));

      verify(() => navigator.pushReplacement<void, void>(any())).called(1);
    });
  });
}
