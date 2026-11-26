// `buyerAccessTokenProvider` written inline in `build`, as the README shows it:
// a new function on every rebuild, for the same page.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seatlayer/seatlayer.dart';

import 'fake_webview_platform.dart';
import 'run_harness.dart';
import 'season_harness.dart';

/// Plays the event page's part of the bridge.
class _EventPage extends SeasonPage {
  _EventPage(super.fake);

  @override
  Future<void> boot(WidgetTester tester) async {
    post(EnvelopeKind.hello, 'hello', <String, Object?>{
      'bundle': '1.0.3',
      'protocol': <String, Object?>{'min': 1, 'max': 1},
      'events': <String>['sys.ready'],
      'commands': <String>[],
    });
    await tester.pump();
    evt('sys.ready', <String, Object?>{'protocol': 1, 'transport': 'flutter'});
    await tester.pump();
    await tester.pump();
  }
}

/// Builds [view] with a provider of its own each time [rebuild] is pressed.
class _Inline extends StatefulWidget {
  const _Inline(this.view);

  final Widget Function(BuyerAccessTokenProvider? provider) view;

  @override
  State<_Inline> createState() => _InlineState();
}

class _InlineState extends State<_Inline> {
  var count = 0;
  var private = true;

  void rebuild({bool? private}) => setState(() {
        count += 1;
        this.private = private ?? this.private;
      });

  @override
  Widget build(BuildContext context) {
    final built = count;
    return MaterialApp(
      home: widget.view(
        private ? (request) => BuyerAccessToken(token: 'token-$built') : null,
      ),
    );
  }
}

void main() {
  late SeatLayerController event;
  setUp(() => event = SeatLayerController());
  tearDown(() => event.dispose());

  final views = <String,
      (
    Widget Function(BuyerAccessTokenProvider? provider),
    SeasonPage Function(FakeWebViewPlatform fake),
  )>{
    'an event': (
      (provider) => SeatLayerView(
            controller: event,
            configuration: SeatLayerConfiguration(
              event: 'ev_test',
              buyerAccessTokenProvider: provider,
            ),
          ),
      _EventPage.new,
    ),
    'a Season': (
      (provider) => SeatLayerSeasonPicker(
            configuration: SeatLayerSeasonConfiguration(
              season: 'sea_test',
              buyerAccessTokenProvider: provider,
            ),
            onContinue: (_) {},
          ),
      SeasonPage.new,
    ),
    'a run': (
      (provider) => SeatLayerRunPicker(
            configuration: SeatLayerRunConfiguration(
              run: 'pg_test',
              buyerAccessTokenProvider: provider,
            ),
            onContinue: (_) {},
          ),
      RunPage.new,
    ),
  };

  for (final MapEntry(key: name, value: (view, pageOf)) in views.entries) {
    testWidgets('$name keeps its page over a rebuild, and asks the newest',
        (tester) async {
      final fake = useFakeWebViewPlatform();
      final page = pageOf(fake);
      await tester.pumpWidget(_Inline(view));
      await page.boot(tester);
      final state = tester.state<_InlineState>(find.byType(_Inline));

      for (var i = 0; i < 3; i += 1) {
        state.rebuild();
        await tester.pump();
        await tester.pump();
      }
      expect(fake.loads, hasLength(1));
      expect(
        page.sent.where((envelope) => envelope.type.endsWith('.destroy')),
        isEmpty,
      );

      page.evt('access.token.request', <String, Object?>{
        'requestId': 'r1',
        'reason': 'expired',
      });
      await tester.pump();
      await tester.pump();
      expect(
        page.last('access.token.provide').payload,
        <String, Object?>{'requestId': 'r1', 'token': 'token-3'},
      );
    });

    testWidgets('$name loads again when the provider is taken away',
        (tester) async {
      final fake = useFakeWebViewPlatform();
      final page = pageOf(fake);
      await tester.pumpWidget(_Inline(view));
      await page.boot(tester);
      tester.state<_InlineState>(find.byType(_Inline)).rebuild(private: false);
      await tester.pump();
      // A page that is told to end answers before the next one loads.
      for (final sent in page.sent) {
        if (!sent.type.endsWith('.destroy')) continue;
        page.answer(sent.type, const <String, Object?>{});
        break;
      }
      await tester.pump();
      await tester.pump();
      expect(fake.loads, hasLength(2));
    });
  }
}
