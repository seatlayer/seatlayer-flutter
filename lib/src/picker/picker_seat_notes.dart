/// SEAT NOTES — the one list of what a seat's own attributes say.
///
/// A seat can carry twelve accommodations, a wheelchair provision, three
/// selling marks and the organizer's own sentence, and every surface that
/// mentioned any of them used to decide for itself which ones matter. The tap
/// card showed a wheelchair line and one limited-view line in which restricted
/// BEAT obstructed, so a seat marked both told the buyer only half; the confirm
/// card showed a different pair; the cart showed two markers; premium reached
/// two surfaces out of five.
///
/// So the ANSWER lives here — [seatLayerSeatNoteRows] decides which rows a seat
/// earns and in what order — and the surfaces only draw it. It mirrors
/// `core/seatNotes.ts` in the runtime row for row, including the two rules
/// worth naming:
///
///  * **Restricted and obstructed are separate rows.** They used to collapse
///    into one line with restricted winning, which meant a seat behind both a
///    rail and a pillar was told about the rail and never about the pillar.
///  * **A wheelchair seat with a provision gets the provision row INSTEAD.**
///    "Empty wheelchair space" already says everything "wheelchair space"
///    would, and more precisely; listing both is one seat explained twice.
///
/// The rows are drawn by [SeatLayerSeatNotes] as full-bleed BANDS. Every popup
/// the picker raises is a stack of bands — the identity grid, then the category
/// band in the category's own colour — and these are the next bands in it. They
/// were rounded plates with their own borders inset inside the card's padding,
/// which read as four small cards floating inside a card.
library;

import 'package:flutter/material.dart';

import 'picker_a11y.dart';
import 'picker_internal.dart';
import 'picker_seat_icons.dart';
import 'picker_strings.dart';
import 'picker_tokens.g.dart';
import 'seat_layer_picker_theme.dart';
import '../payloads.dart';

/// How a note row reads: its meaning is here, its colour is the surface's.
enum SeatLayerSeatNoteTone {
  /// An accommodation or a wheelchair provision — a neutral, factual row.
  access,

  /// A view restriction. Surfaces give this the amber caution treatment.
  warn,

  /// A premium seat — the gold tag.
  premium,

  /// The organizer's own sentence, with no attribute of its own.
  note,
}

/// One row of a seat's notes.
@immutable
class SeatLayerSeatNote {
  /// Creates a note row.
  const SeatLayerSeatNote({
    required this.key,
    required this.iconKey,
    required this.title,
    required this.tone,
    this.note,
  });

  /// Stable identity for the row, for keying and for tests.
  final String key;

  /// Which drawing in [seatLayerSeatGlyphs] this row wears.
  final String iconKey;

  /// The row's title, already in the buyer's language.
  final String title;

  /// The tone the surface paints it in.
  final SeatLayerSeatNoteTone tone;

  /// The organizer's free text, attached to the row it belongs to.
  final String? note;

  @override
  bool operator ==(Object other) =>
      other is SeatLayerSeatNote &&
      other.key == key &&
      other.iconKey == iconKey &&
      other.title == title &&
      other.tone == tone &&
      other.note == note;

  @override
  int get hashCode => Object.hash(key, iconKey, title, tone, note);
}

/// Every row a seat's attributes earn, in reading order.
///
/// The order is fixed and is not discovery order: what the seat PROVIDES first
/// (accommodations, then the physical wheelchair fact), then what a buyer
/// should know before paying (restricted, obstructed, premium), then the
/// organizer's own words. Two seats with the same attributes always produce
/// the same list.
List<SeatLayerSeatNote> seatLayerSeatNoteRows({
  required SeatLayerPickerStrings strings,
  List<String>? accessibility,
  String? wheelchairSpaceType,
  SeatCommercialAttributes? commercial,
}) {
  final rows = <SeatLayerSeatNote>[];
  final provision = wheelchairSpaceType;
  for (final type in accessibility ?? const <String>[]) {
    if (type == _wheelchairKey && provision != null) continue;
    final label = strings.accessNeeds[type];
    if (label == null) continue; // a key this build's taxonomy does not know
    rows.add(SeatLayerSeatNote(
      key: 'access:$type',
      iconKey: type,
      title: label,
      tone: SeatLayerSeatNoteTone.access,
    ));
  }
  if (provision == 'no-seat') {
    rows.add(SeatLayerSeatNote(
      key: 'wheelchair:no-seat',
      iconKey: _wheelchairKey,
      title: strings.emptyWheelchairSpace,
      tone: SeatLayerSeatNoteTone.access,
    ));
  } else if (provision == 'seat-present') {
    rows.add(SeatLayerSeatNote(
      key: 'wheelchair:seat-present',
      iconKey: _wheelchairKey,
      title: strings.accessiblePhysicalSeat,
      tone: SeatLayerSeatNoteTone.access,
    ));
  }
  if (commercial?.restrictedView == true) {
    rows.add(SeatLayerSeatNote(
      key: 'mark:restrictedView',
      iconKey: 'restrictedView',
      title: strings.restrictedView,
      tone: SeatLayerSeatNoteTone.warn,
    ));
  }
  if (commercial?.obstructedView == true) {
    rows.add(SeatLayerSeatNote(
      key: 'mark:obstructedView',
      iconKey: 'obstructedView',
      title: strings.obstructedView,
      tone: SeatLayerSeatNoteTone.warn,
    ));
  }
  if (commercial?.premium == true) {
    rows.add(SeatLayerSeatNote(
      key: 'mark:premium',
      iconKey: 'premium',
      title: strings.premiumSeat,
      tone: SeatLayerSeatNoteTone.premium,
    ));
  }
  final note = commercial?.note?.trim();
  if (note == null || note.isEmpty) return rows;
  // The sentence belongs to the FIRST selling mark on the seat: an organizer
  // writing "pillar at the aisle end" is explaining the restriction, not
  // adding a second unrelated fact. With no mark to explain, it is its own row.
  final owner = rows.indexWhere((row) =>
      row.tone == SeatLayerSeatNoteTone.warn ||
      row.tone == SeatLayerSeatNoteTone.premium);
  if (owner >= 0) {
    final explained = rows[owner];
    rows[owner] = SeatLayerSeatNote(
      key: explained.key,
      iconKey: explained.iconKey,
      title: explained.title,
      tone: explained.tone,
      note: note,
    );
    return rows;
  }
  rows.add(SeatLayerSeatNote(
    key: 'note',
    iconKey: 'note',
    title: strings.organizerNote,
    tone: SeatLayerSeatNoteTone.note,
    note: note,
  ));
  return rows;
}

/// The rows a selected seat earns, read from the runtime's own fields.
List<SeatLayerSeatNote> seatLayerSeatNotesFor(
  SelectedSeat seat,
  SeatLayerPickerStrings strings,
) =>
    seatLayerSeatNoteRows(
      strings: strings,
      accessibility: seat.accessibility,
      wheelchairSpaceType: seat.wheelchairSpaceType,
      commercial: seat.commercial,
    );

const String _wheelchairKey = 'wheelchair';

/// What one tone paints: the band's ground, its title ink, its body ink.
@immutable
class SeatLayerSeatNoteToneColors {
  /// Creates a resolved tone.
  const SeatLayerSeatNoteToneColors({
    required this.ground,
    required this.ink,
    required this.bodyInk,
    required this.iconInk,
  });

  /// The band's own ground, tinted out of the surface it sits on.
  final Color ground;

  /// The title's ink, measured against [ground] rather than against the
  /// surface the ground is mixed from.
  final Color ink;

  /// The organizer's second line, one step quieter than [ink].
  final Color bodyInk;

  /// The glyph's ink.
  final Color iconInk;
}

/// The colours [tone] paints in [theme].
///
/// Public and pure so a test can measure the contrast of every pair against
/// the ground it actually paints on, in both themes, rather than against the
/// surface each tint is mixed from — which is how a 1.8:1 amber shipped.
SeatLayerSeatNoteToneColors seatLayerSeatNoteToneColors(
  SeatLayerResolvedPickerTheme theme,
  SeatLayerSeatNoteTone tone,
) {
  final (Color ground, Color ink) = switch (tone) {
    SeatLayerSeatNoteTone.warn => (
        Color.alphaBlend(
          pickerAlpha(theme.warning, SeatLayerOpacityTokens.noteToneWash),
          theme.surface,
        ),
        theme.warnText,
      ),
    SeatLayerSeatNoteTone.premium => (
        Color.alphaBlend(
          pickerAlpha(theme.premium, SeatLayerOpacityTokens.noteToneWash),
          theme.surface,
        ),
        theme.premiumText,
      ),
    _ => (
        Color.alphaBlend(
          pickerAlpha(theme.text, SeatLayerOpacityTokens.noteNeutralWash),
          theme.surface,
        ),
        theme.text,
      ),
  };
  return SeatLayerSeatNoteToneColors(
    ground: ground,
    ink: ink,
    // The organizer's second line is the muted ink walked a quarter of the way
    // toward the text: bare muted on the tint measures below the bar.
    bodyInk: Color.lerp(
      theme.mutedText,
      theme.text,
      1 - SeatLayerOpacityTokens.noteBodyInk,
    )!,
    iconInk: tone == SeatLayerSeatNoteTone.warn ||
            tone == SeatLayerSeatNoteTone.premium
        ? ink
        : theme.mutedText,
  );
}

/// A seat's notes, as full-bleed bands under the category band.
///
/// No radius, no border and no inset: a band is the card's full width or it is
/// a plate again. The hairline lives on the JOIN, so the first band sits flush
/// against the category band above it and the block reads as a continuation of
/// that band rather than as a new object.
///
/// [compact] is the tap card's form — a narrower popup floating over the map,
/// so the type comes down a rung and the text inset moves to the tap card's
/// own leading inset. The bands stay bands.
class SeatLayerSeatNotes extends StatelessWidget {
  /// Creates the note block for [rows].
  const SeatLayerSeatNotes({
    super.key,
    required this.rows,
    this.compact = false,
  });

  /// The rows, already in reading order from [seatLayerSeatNoteRows].
  final List<SeatLayerSeatNote> rows;

  /// Whether to draw the tap card's tighter form.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final theme = seatLayerPickerThemeOf(context);
    final hairline = pickerAlpha(
      theme.divider,
      theme.divider.a * SeatLayerOpacityTokens.noteHairline,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < rows.length; index++)
          _NoteBand(
            row: rows[index],
            compact: compact,
            // Only BETWEEN bands: a line above the first one would fight the
            // category band's own edge.
            hairline: index == 0 ? null : hairline,
          ),
      ],
    );
  }
}

class _NoteBand extends StatelessWidget {
  const _NoteBand({
    required this.row,
    required this.compact,
    required this.hairline,
  });

  final SeatLayerSeatNote row;
  final bool compact;
  final Color? hairline;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final tone = seatLayerSeatNoteToneColors(theme, row.tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.ground,
        border:
            hairline == null ? null : Border(top: BorderSide(color: hairline!)),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          compact
              ? SeatLayerSizeTokens.noteCompactPadLeading
              : SeatLayerSizeTokens.notePadX,
          compact
              ? SeatLayerSizeTokens.noteCompactPadY
              : SeatLayerSizeTokens.notePadY,
          compact
              ? SeatLayerSizeTokens.noteCompactPadX
              : SeatLayerSizeTokens.notePadX,
          compact
              ? SeatLayerSizeTokens.noteCompactPadY
              : SeatLayerSizeTokens.notePadY,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: SeatLayerSeatIcon(
                iconKey: row.iconKey,
                color: tone.iconInk,
                size: compact
                    ? SeatLayerSizeTokens.noteCompactIconSize
                    : SeatLayerSizeTokens.noteIconSize,
              ),
            ),
            const SizedBox(width: SeatLayerSizeTokens.noteIconGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    row.title,
                    style: TextStyle(
                      color: tone.ink,
                      fontSize: compact ? 11.5 : 12.5,
                      fontWeight: seatLayerBoldWeight(
                        context,
                        compact ? FontWeight.w700 : FontWeight.w800,
                      ),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                  if (row.note != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        row.note!,
                        style: TextStyle(
                          color: tone.bodyInk,
                          fontSize: compact ? 10.5 : 11,
                          height: 1.4,
                          fontFamily: theme.fontFamily,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
