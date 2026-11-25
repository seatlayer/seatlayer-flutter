// Generates the per-locale defaults for `SeatLayerPickerStrings`.
//
//   dart run tool/gen_locale_strings.dart          # write the files
//   dart run tool/gen_locale_strings.dart --check  # fail if any is stale
//
// Input is `design/locale_strings.json`, which is itself rebuilt from the
// SeatLayer runtime's own dictionaries by `tool/extract_runtime_locales.mjs`.
// Output is one `lib/src/picker/picker_strings.<locale>.g.dart` per locale and
// one index the resolver reads.
//
// Why generated and not hand-written: the runtime already ships a reviewed
// translation of these sentences for forty-three locales. Writing them again
// on this side would be the same words drifting in two places.
import 'dart:convert';
import 'dart:io';

const String _input = 'design/locale_strings.json';
const String _outputDirectory = 'lib/src/picker';
const String _indexFile = 'lib/src/picker/picker_strings_locales.g.dart';

/// Strings that are one value and nothing else.
const List<String> _plainFields = <String>[
  'close',
  'overview',
  'backToVenue',
  'cancel',
  'select',
  'removeSeat',
  'viewFromHere',
  'openVenue360',
  'recentre',
  'viewFromYourSeat',
  'emptyTrayHint',
  'anyTicketType',
  'anyVenueZone',
  'bestSeats',
  'showLess',
  'undo',
  'holdAndCheckout',
  'poweredBy',
  'testMode',
  'accessibility',
  'accessibilityTitle',
  'fitVenue',
  'fitWholeVenue',
  'loading',
  'errorMessage',
  'retry',
  'accessRefresh',
  'noSeatsSelected',
  'findBestSeatsCta',
  'organizerNote',
  'accessiblePhysicalSeat',
  'emptyWheelchairSpace',
  'findSeatsTogether',
  'aboutBestSeats',
  'closestGroupChosenInstantly',
  'hideLimitedView',
  'colorblindSafe',
  'notAvailable',
  'viewGroupTitle',
  'restrictedView',
  'obstructedView',
  'premiumSeat',
  // Also composed into `continueWithTotal` below. It is a standalone button
  // label in its own right — the cart sheet, the checkout action and the
  // access panel all print it alone — so it has to be emitted here too, or
  // every locale but English says "Continue" under a translated map.
  'continueWord',
  'allFloors',
  'previousSection',
  'nextSection',
  'addSeat',
  'added',
  'sectionWord',
  'rowWord',
  'seatWord',
  'seeItIn3D',
  'viewFromThisSeat',
  'allPrices',
  'ticketPrices',
  'yourSeats',
  'ticketType',
  'tierCompanionGuidance',
  'findingBestSeats',
  'findSeats',
  'expandCart',
  'collapseCart',
  'continueToCheckout',
  'secureMore',
  'selectSeats',
  'pickYourSeats',
  'salesClosedPill',
  'salesClosedCta',
  'confirmOrCancelSeat',
  'securingSeats',
  'openingCheckout',
  'testModeExplained',
  'displayOptions',
  'companionSeatsNote',
  'zoomIn',
  'zoomOut',
  'rotateVenue',
  'moveVenue',
  'mapView',
  'flat2dMap',
  'interactive3dVenueView',
  'venueView',
  'holdLapsedTitle',
  'salesClosed',
  'salesClosedCopy',
  'salesClosedToast',
  'soldOutEyebrow',
  'soldOutTitle',
  'soldOutCopy',
  'holdExpired',
  'addingEllipsis',
  'moreTimeAdded',
  'couldNotAddMoreTime',
  'seatsJustTaken',
  'ticketTypeSoldOut',
  'seatsNoLongerAvailableTryAnother',
  'companionPairRequired',
  'ticketOptionNotApplicable',
  'maintenancePausedShortly',
  'guestsOnly',
  'guestChoiceClosed',
  'maxOneTicketForOrder',
  'tooManyAttempts',
  'seatHeldForRenewal',
  'seatUnavailable',
  'eventUnavailable',
  'savedSeatsNotRestored',
  'allSetTitle',
  'confirmedAndOnWay',
  'backToMap',
  'mapDidNotLoad',
  'checkConnection',
  'accessPausedTitle',
  'accessPausedCopy',
  'accessRevokedTitle',
  'accessRevokedCopy',
  'accessUnverifiedTitle',
  'accessUnverifiedCopy',
  'generalAdmission',
  'numberOfGuests',
  'chooseGuestsCopy',
  'fewerGuests',
  'moreGuests',
  'selectTable',
  'updateTable',
  'removeWord',
  'floorWord',
  'totalWord',
  'adjustSelection',
  'backToSeatMap',
  // From the runtime's app strings: sentences only the app SDKs draw.
  'chooseSeats',
  'chooseTickets',
  'placeWord',
  'ticketWord',
  'passport',
  'venue3D',
  'venueZone',
  'venueMapHint',
  'previousSeat',
  'nextSeat',
  'orbitMode',
  'panMode',
  'openInteractive3dVenue',
  'showSeatsFor',
  'accessJumpFirstSection',
  'accessJumpNextSection',
  'fewerTickets',
  'moreTickets',
  'addTickets',
  'noSelectableSeats',
  'confirmYourTickets',
  'seatsSecuredOpeningCheckout',
  'holdInCheckoutTitle',
  'holdInCheckoutBody',
  'releaseAndChangeSeats',
  'holdAlreadyHeldTitle',
  'holdAlreadyHeldBody',
  'accessExpiredTitle',
  'accessExpiredCopy',
  'dismissError',
  'testModeLong',
  'seatRemoved',
  'reloadSeatMap',
];

/// The wire keys of the twelve accommodations, whose translated names are
/// rebuilt into the `accessNeeds` map.
///
/// Extracted as `accessNeeds.<key>` rather than as twelve fields because that
/// is the shape the picker reads them in: a row, a seat-note title and the
/// map's own filter all look the need up by the runtime's own key.
const List<String> _accessNeedKeys = <String>[
  'wheelchair',
  'companion',
  'semi-ambulatory',
  'designated-aisle',
  'step-free',
  'hearing',
  'cart',
  'sign-language',
  'low-vision',
  'sensory-friendly',
  'plus-size',
  'lift-armrest',
];

/// One placeholder in a runtime sentence, and the Dart parameter that fills it.
typedef _Slot = ({String parameter, String type, String placeholder});

/// Strings the runtime writes with placeholders, and the Dart parameters that
/// fill them, in the order the Dart signature takes them.
const Map<String, List<_Slot>> _interpolated = <String, List<_Slot>>{
  'seatsLeft': <_Slot>[
    (parameter: 'count', type: 'int', placeholder: '{count}'),
  ],
  'moreCount': <_Slot>[
    (parameter: 'count', type: 'int', placeholder: '{count}'),
  ],
  'addMinutes': <_Slot>[
    (parameter: 'minutes', type: 'int', placeholder: '{count}'),
  ],
  'fromPrice': <_Slot>[
    (parameter: 'money', type: 'String', placeholder: '{price}'),
  ],
  'sightline': <_Slot>[
    (parameter: 'metres', type: 'String', placeholder: '{m}'),
  ],
  'secureMoreAndCheckout': <_Slot>[
    (parameter: 'count', type: 'int', placeholder: '{count}'),
  ],
  'accessFreeCount': <_Slot>[
    (parameter: 'count', type: 'int', placeholder: '{count}'),
  ],
  'seatJustTakenByAnother': <_Slot>[
    (parameter: 'label', type: 'String', placeholder: '{label}'),
  ],
  'labelNoLongerAvailable': <_Slot>[
    (parameter: 'label', type: 'String', placeholder: '{labels}'),
  ],
  'labelsNoLongerAvailable': <_Slot>[
    (parameter: 'labels', type: 'String', placeholder: '{labels}'),
  ],
  'couldNotFindSeatsTogether': <_Slot>[
    (parameter: 'count', type: 'int', placeholder: '{count}'),
  ],
  'maxTicketsForOrder': <_Slot>[
    (parameter: 'count', type: 'int', placeholder: '{count}'),
  ],
  'couldNotRemoveLabel': <_Slot>[
    (parameter: 'label', type: 'String', placeholder: '{label}'),
  ],
  'peekSecured': <_Slot>[
    (parameter: 'count', type: 'int', placeholder: '{count}'),
    (parameter: 'total', type: 'String', placeholder: '{total}'),
  ],
  'venueMap': <_Slot>[
    (parameter: 'venue', type: 'String', placeholder: '{venue}'),
  ],
  'accessibleStep': <_Slot>[
    (parameter: 'index', type: 'int', placeholder: '{index}'),
    (parameter: 'total', type: 'int', placeholder: '{total}'),
  ],
  'chooseMinMaxGuests': <_Slot>[
    (parameter: 'min', type: 'int', placeholder: '{min}'),
    (parameter: 'max', type: 'int', placeholder: '{max}'),
  ],
  'chooseMore': <_Slot>[
    (parameter: 'count', type: 'int', placeholder: '{count}'),
  ],
  'seatsHeldForNeedMoreTime': <_Slot>[
    (parameter: 'time', type: 'String', placeholder: '{time}'),
  ],
  // The runtime's pair is `{first} · {second}`; the need comes first.
  'accessNeedWithCount': <_Slot>[
    (parameter: 'need', type: 'String', placeholder: '{first}'),
    (parameter: 'count', type: 'int', placeholder: '{second}'),
  ],
};

/// The slot every counted string fills.
const List<_Slot> _countSlot = <_Slot>[
  (parameter: 'count', type: 'int', placeholder: '{count}'),
];

/// The plural categories a counted string may carry besides `other`, in the
/// order the generated `switch` lists them.
const List<String> _pluralForms = <String>['zero', 'one', 'two', 'few', 'many'];

/// Strings with a singular and a plural form.
const List<String> _plurals = <String>[
  'ticketCount',
  'findBestSeats',
  'reselectSeats',
  'seatsFree',
  'seatsLeftInSection',
  'holdLapsedStillFree',
  'holdLapsedSomeTaken',
  'holdLapsedAllTaken',
  'accessibleSections',
  'placesAvailable',
  'removeTickets',
  'holdMinutesLeft',
  'holdSecondsLeft',
  'holdLapsedBody',
  'seatsNotRecovered',
  'activeFilters',
  'accessibilityFiltersActive',
  'onlyLeft',
  'maintenancePaused',
];

void main(List<String> args) {
  final check = args.contains('--check');
  final raw =
      jsonDecode(File(_input).readAsStringSync()) as Map<String, Object?>;
  final table = raw['strings']! as Map<String, Object?>;
  final locales = table.keys.toList()..sort();

  final wanted = <String, String>{};
  for (final locale in locales) {
    wanted[_pathFor(locale)] = _formatted(
        renderLocale(locale, (table[locale]! as Map<String, Object?>)));
  }
  wanted[_indexFile] = _formatted(_renderIndex(locales));

  final stale = <String>[];
  for (final entry in wanted.entries) {
    final file = File(entry.key);
    final current = file.existsSync() ? file.readAsStringSync() : '';
    if (current == entry.value) continue;
    stale.add(entry.key);
    if (!check) file.writeAsStringSync(entry.value);
  }
  // A locale removed upstream leaves a file behind that nothing imports and
  // every reader still believes.
  for (final orphan in _orphans(wanted.keys.toSet())) {
    stale.add(orphan);
    if (!check) File(orphan).deleteSync();
  }

  if (!check) {
    stdout.writeln('wrote ${wanted.length} files (${stale.length} changed)');
    return;
  }
  if (stale.isEmpty) {
    stdout.writeln('${wanted.length} locale files are up to date');
    return;
  }
  stderr.writeln(
    'stale: ${stale.join(', ')}\n'
    'Run `dart run tool/gen_locale_strings.dart`.',
  );
  exitCode = 1;
}

/// Generated files under [_outputDirectory] that [wanted] does not claim.
List<String> _orphans(Set<String> wanted) {
  final directory = Directory(_outputDirectory);
  if (!directory.existsSync()) return const <String>[];
  return <String>[
    for (final entity in directory.listSync())
      if (entity is File &&
          RegExp(r'picker_strings\.[a-z_]+\.g\.dart$').hasMatch(entity.path) &&
          !wanted.contains(entity.path))
        entity.path,
  ]..sort();
}

String _pathFor(String locale) =>
    '$_outputDirectory/picker_strings.${_fileTag(locale)}.g.dart';

/// `zh-Hans` as it appears in a file name.
String _fileTag(String locale) => locale.toLowerCase().replaceAll('-', '_');

/// `zh-Hans` as it appears in an identifier.
String _identifier(String locale) => locale
    .split('-')
    .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
    .join();

/// Whether any counted string in [values] has a form besides `other`, and so
/// has a category to choose by.
bool _usesPluralRules(Map<String, Object?> values) => _plurals.any(
      (field) => _pluralForms.any((form) => values['$field.$form'] != null),
    );

/// The generated Dart for one locale's [values]. Public for its test.
String renderLocale(String locale, Map<String, Object?> values) {
  final buffer = StringBuffer()
    ..writeln(_header(locale))
    ..writeln(
      _usesPluralRules(values)
          ? "import 'picker_plural_rules.dart';\nimport 'picker_strings.dart';"
          : "import 'picker_strings.dart';",
    )
    ..writeln();

  final suffix = _identifier(locale);
  final functions = <String, String>{};

  for (final entry in _interpolated.entries) {
    final value = values[entry.key] as String?;
    if (value == null) continue;
    final name = '_${entry.key}$suffix';
    functions[entry.key] = name;
    buffer
      ..writeln(
        'String $name(${_parameters(entry.value)}) => '
        '${_template(value, entry.value)};',
      )
      ..writeln();
  }

  for (final field in _plurals) {
    final other = values['$field.other'] as String?;
    if (other == null) continue;
    final name = '_$field$suffix';
    functions[field] = name;
    // Every form the runtime has for this locale, chosen the way the runtime
    // chooses it: by the locale's own plural category. A form the locale's
    // dictionary lacks falls to `other`, as the runtime's `tCount` does. A
    // locale with only `other` (Japanese, Chinese, Korean…) needs no choice.
    final forms = <String, String>{
      for (final form in _pluralForms)
        if (values['$field.$form'] case final String value) form: value,
    };
    if (forms.isEmpty) {
      buffer
        ..writeln(
          'String $name(int count) => ${_template(other, _countSlot)};',
        )
        ..writeln();
      continue;
    }
    buffer
      ..writeln('String $name(int count) =>')
      ..writeln("    switch (pickerPluralCategory('$locale', count)) {");
    forms.forEach((form, value) {
      buffer.writeln(
        '      PickerPluralCategory.$form => ${_template(value, _countSlot)},',
      );
    });
    buffer
      ..writeln('      _ => ${_template(other, _countSlot)},')
      ..writeln('    };')
      ..writeln();
  }

  final continueWord = values['continueWord'] as String?;
  if (continueWord != null) {
    const name = '_continueWithTotal';
    functions['continueWithTotal'] = '$name$suffix';
    buffer
      ..writeln(
        'String $name$suffix(String money) => '
        "'${escapeDartString(continueWord)} \\u00b7 \$money';",
      )
      ..writeln();
  }

  buffer
    ..writeln('/// The `$locale` defaults for the native picker chrome.')
    ..writeln(
      'const SeatLayerPickerStrings seatLayerPickerStrings$suffix =',
    )
    ..writeln('    SeatLayerPickerStrings(');
  for (final field in _plainFields) {
    final value = values[field] as String?;
    if (value == null) continue;
    buffer.writeln("  $field: '${escapeDartString(value)}',");
  }
  final needs = <String, String>{
    for (final key in _accessNeedKeys)
      if (values['accessNeeds.$key'] != null)
        key: values['accessNeeds.$key']! as String,
  };
  if (needs.isNotEmpty) {
    buffer.writeln('  accessNeeds: <String, String>{');
    needs.forEach((key, value) {
      buffer.writeln("    '$key': '${escapeDartString(value)}',");
    });
    buffer.writeln('  },');
  }
  for (final entry in functions.entries) {
    buffer.writeln('  ${entry.key}: ${entry.value},');
  }
  buffer.writeln(');');
  return buffer.toString();
}

String _renderIndex(List<String> locales) {
  final buffer = StringBuffer()
    ..writeln(_header('every locale'))
    ..writeln("import 'picker_strings.dart';");
  for (final locale in locales) {
    buffer.writeln("import 'picker_strings.${_fileTag(locale)}.g.dart';");
  }
  buffer
    ..writeln()
    ..writeln('/// The defaults for every locale the runtime translates.')
    ..writeln('///')
    ..writeln('/// Keyed by the runtime\'s own dictionary name, which is a')
    ..writeln('/// language code or a language-and-script tag.')
    ..writeln(
      'const Map<String, SeatLayerPickerStrings> '
      'seatLayerPickerStringsByLocale =',
    )
    ..writeln('    <String, SeatLayerPickerStrings>{');
  for (final locale in locales) {
    buffer
        .writeln("  '$locale': seatLayerPickerStrings${_identifier(locale)},");
  }
  buffer.writeln('};');
  return buffer.toString();
}

String _header(String subject) => '''
// GENERATED — do not edit.
//
// Source: $_input ($subject)
// Regenerate: dart run tool/gen_locale_strings.dart
//
// The wording is the SeatLayer runtime's own, so the drawn map and the native
// chrome around it say the same things in the same words.
''';

/// The Dart parameter list for [slots]: `int count, String total`.
String _parameters(List<_Slot> slots) =>
    slots.map((slot) => '${slot.type} ${slot.parameter}').join(', ');

/// Characters that would be read as part of an interpolated name.
final RegExp _identifierPart = RegExp(r'[A-Za-z0-9_]');

/// [value] as a Dart string with each slot's placeholder replaced by its
/// parameter.
String _template(String value, List<_Slot> slots) {
  final escaped = escapeDartString(value);
  // `escapeDartString` turns a literal `$` into `\$`, so the only `$` this can
  // introduce is the interpolation being asked for. Braces go on only where
  // the next character would otherwise join the name: Japanese writes the
  // unit straight after the figure ("約{m}m"), where a bare `$metres` parses
  // as an identifier called `metresm`. Bracing everything instead would be
  // simpler and would trip `unnecessary_brace_in_string_interps` on every
  // other locale.
  final buffer = StringBuffer();
  var rest = escaped;
  while (true) {
    // The earliest placeholder left, whichever slot it fills: a translation
    // is free to put the figures in another order than English does.
    _Slot? next;
    var at = -1;
    for (final slot in slots) {
      final index = rest.indexOf(slot.placeholder);
      if (index >= 0 && (at < 0 || index < at)) {
        at = index;
        next = slot;
      }
    }
    if (next == null) break;
    final after = at + next.placeholder.length;
    final joins = after < rest.length && _identifierPart.hasMatch(rest[after]);
    final parameter = next.parameter;
    buffer
      ..write(rest.substring(0, at))
      ..write(joins ? '\${$parameter}' : '\$$parameter');
    rest = rest.substring(after);
  }
  buffer.write(rest);
  return "'$buffer'";
}

/// [value] as the inside of a single-quoted Dart string literal.
///
/// A line break is written as its escape: a raw one ends the literal, and
/// `dart format` then fails on the whole generated file.
String escapeDartString(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll(r'$', r'\$')
    .replaceAll("'", r"\'")
    .replaceAll('\r', r'\r')
    .replaceAll('\n', r'\n');

/// [source] as `dart format` would write it.
String _formatted(String source) {
  final scratch = Directory.systemTemp.createTempSync('seatlayer-locales');
  try {
    final file = File('${scratch.path}/generated.dart')
      ..writeAsStringSync(source);
    final result = Process.runSync('dart', <String>['format', file.path]);
    if (result.exitCode != 0) {
      throw StateError('dart format failed: ${result.stderr}');
    }
    return file.readAsStringSync();
  } finally {
    scratch.deleteSync(recursive: true);
  }
}
