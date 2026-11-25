/// How the phone's cart row stands, worked out from the widths of its words.
///
/// One row: a circle, the words, the button. The button takes the width of its
/// own words, up to 46% of the row and two balanced lines; only where its
/// words need more than that does it go under the others, at full width.
///
/// Arithmetic only, so that it can be tested without a widget.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// The row's own measures, in points at text size 1.
abstract final class PickerCartBarSize {
  /// The line over the row.
  static const double line = 1;

  /// The row's side padding.
  static const double padX = 12;

  /// The row's padding over and under what stands in it.
  static const double padY = 10;

  /// Between the circle, the words and the button.
  static const double gap = 10;

  /// Between the words and a button that stands under them.
  static const double underGap = 8;

  /// The least height of what stands in the row, and the side of the square
  /// the circle is pressed in.
  static const double minHeight = 44;

  /// The circle the arrow stands in.
  static const double disc = 28;

  /// The arrow.
  static const double chevron = 16;

  /// The button's side padding.
  static const double buttonPadX = 14;

  /// The button's padding over and under its words.
  static const double buttonPadY = 6;

  /// The button's least width.
  static const double buttonMinWidth = 112;

  /// The button's corners.
  static const double buttonRadius = 7.7;

  /// The part of the row a button beside the words may take.
  static const double buttonMaxShare = .46;

  /// The button's letters.
  static const double buttonFont = 14;

  /// The button's line height.
  static const double buttonLine = 1.1;

  /// "2 tickets".
  static const double countFont = 13.5;

  /// The total.
  static const double totalFont = 14.5;

  /// Between the count and the total.
  static const double totalGap = 7;

  /// The seats' names.
  static const double namesFont = 12.5;

  /// The height of one line of words.
  static const double wordsLine = 18;

  /// The cards, or the best-seats form, over the row.
  static const double listMaxHeight = 240;

  /// Under the last card, over the line.
  static const double listPadBottom = 10;

  /// The row while a seat card is asking.
  static const double askingOpacity = .58;

  /// The button's letters, the largest that fits first.
  static const List<double> letters = <double>[buttonFont, 12.5, 11.5];
}

/// The widths of one label at one letter size.
@immutable
class PickerCartBarWidths {
  /// Creates a label's widths.
  const PickerCartBarWidths({required this.whole, required this.parts});

  /// The whole label on one line.
  final double whole;

  /// Each part a line may not break.
  final List<double> parts;

  double get _gap {
    if (parts.length < 2) return 0;
    final sum = parts.fold<double>(0, (total, part) => total + part);
    return math.max(0, (whole - sum) / (parts.length - 1));
  }

  double get _longest => parts.fold<double>(0, math.max);

  /// How many lines the label takes in [room], as the text engine breaks it.
  int linesIn(double room) {
    var lines = 1;
    var used = 0.0;
    for (final part in parts) {
      final next = used == 0 ? part : used + _gap + part;
      if (used > 0 && next > room + .01) {
        lines += 1;
        used = part;
      } else {
        used = next;
      }
    }
    return lines;
  }

  /// Whether it stands on two lines of [room] with no part cut.
  bool fitsTwoLines(double room) => _longest <= room && linesIn(room) <= 2;

  /// The narrowest width that keeps the label on as many lines as [room]
  /// gives it.
  double balancedIn(double room) {
    final lines = linesIn(room);
    if (lines < 2) return math.min(room, whole);
    var low = math.min(room, _longest);
    var high = room;
    while (high - low > .5) {
      final middle = (low + high) / 2;
      if (linesIn(middle) <= lines) {
        high = middle;
      } else {
        low = middle;
      }
    }
    return high;
  }
}

/// The parts a line may not break. Scripts written without spaces break
/// between their own letters.
List<String> pickerCartBarParts(String label) => <String>[
      for (final word in label.split(RegExp(r'\s+')))
        if (word.isNotEmpty)
          if (_unspaced.hasMatch(word))
            ...word.runes.map(String.fromCharCode)
          else
            word,
    ];

final RegExp _unspaced = RegExp(
  '[฀-࿿぀-ヿ㐀-鿿豈-﫿]',
);

/// Where the row's parts stand.
@immutable
class PickerCartBarPlan {
  /// Creates a plan.
  const PickerCartBarPlan({
    required this.under,
    required this.buttonWidth,
    required this.textWidth,
    required this.letters,
    required this.wordsWidth,
  });

  /// Works the row out.
  ///
  /// [width] is the row's own, its padding included. [own] is every label
  /// that stays on the button: all of them are tested, so that the row stands
  /// the same in every state. [label] is the one it wears now, at each of
  /// [PickerCartBarSize.letters]; where [labelIsOwn] it never gets smaller.
  factory PickerCartBarPlan.of({
    required double width,
    required List<PickerCartBarWidths> own,
    required List<PickerCartBarWidths> label,
    required bool labelIsOwn,
  }) {
    final inner = math.max(0.0, width - PickerCartBarSize.padX * 2);
    final besideDisc = math.max(
      0.0,
      inner - PickerCartBarSize.disc - PickerCartBarSize.gap,
    );
    final most = inner * PickerCartBarSize.buttonMaxShare;
    const pad = PickerCartBarSize.buttonPadX * 2;
    final room = most - pad;
    final under = own.any((widths) => !widths.fitsTwoLines(room));
    var letters = 0;
    if (!under && !labelIsOwn) {
      final found = label.indexWhere((widths) => widths.fitsTwoLines(room));
      letters = found < 0 ? label.length - 1 : found;
    }
    final worn = label[letters];
    if (under) {
      final textRoom = math.max(0.0, inner - pad);
      return PickerCartBarPlan(
        under: true,
        buttonWidth: inner,
        textWidth: worn.balancedIn(textRoom).ceilToDouble() + 1,
        letters: letters,
        wordsWidth: besideDisc,
      );
    }
    final natural = (worn.whole + pad).ceilToDouble() + 1;
    final buttonWidth = math.min(
      most,
      math.max(PickerCartBarSize.buttonMinWidth, natural),
    );
    final textRoom = buttonWidth - pad;
    return PickerCartBarPlan(
      under: false,
      buttonWidth: buttonWidth,
      textWidth: math.min(
        textRoom,
        worn.balancedIn(textRoom).ceilToDouble() + 1,
      ),
      letters: letters,
      wordsWidth: math.max(0, besideDisc - PickerCartBarSize.gap - buttonWidth),
    );
  }

  /// Whether the button stands under the words.
  final bool under;

  /// The button's width.
  final double buttonWidth;

  /// The room the button's balanced words take.
  final double textWidth;

  /// An index into [PickerCartBarSize.letters].
  final int letters;

  /// The room for the words beside the circle.
  final double wordsWidth;
}

/// Whether the count and the total stand on one line of [room].
bool pickerCartBarTotalBeside({
  required double count,
  required double total,
  required double room,
}) =>
    count + PickerCartBarSize.totalGap + total <= room;
