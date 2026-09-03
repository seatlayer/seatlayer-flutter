// The seat card's own pieces: what the buyer reads before deciding.
//
// Split out of `picker_confirm_card.dart` so the card itself stays a
// legible top-to-bottom description of the question it asks. These are the
// widgets that answer "where is the seat, what does it cost, and what does it
// look like from there" — the identity grid, the category band, the card's
// surface, the photo strip and its no-photo rail, the pills that sit on the
// photo, the ticket-tier picker and the notices under it.
part of 'picker_confirm_card.dart';

/// Where the seat is, as labelled cells rather than one long sentence.
///
/// Section, row and seat each get their own cell with a small eyebrow over the
/// value, so the buyer checking a row letter reads one word instead of parsing
/// `Gallery · Row A · Seat 1`. The three cells are EQUAL and centred: a
/// section like `209` is as short as the row letter beside it, and giving it
/// the widest track and the smallest type made a line of three facts read as a
/// misaligned grid. Only a section longer than [_sectionShortMax] — a venue
/// phrase such as `Upper Grand Circle` — drops to the small wrapping type,
/// because at identity-confirmation time a clipped name is a name the buyer
/// cannot check the map against.
///
/// A screen reader still hears the sentence: the grid is one semantics node
/// carrying the same identity the rest of the picker reads out.
class _IdentityGrid extends StatelessWidget {
  const _IdentityGrid({required this.seat, this.immersive = false});

  final SelectedSeat seat;

  /// Whether the card is being read over the 3D venue, where the cells take a
  /// point more padding and a point less type: the scene is behind the card
  /// rather than beside it, so the grid can breathe and the names — read at a
  /// glance against a venue the buyer is already inside — need less weight.
  final bool immersive;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final section = seat.sectionLabel?.trim() ?? '';
    final row = pickerRowLabel(
      seat.rowLabel,
      seat.sectionLabel,
      sectionCode: pickerSectionCode(
        SeatLayerPickerScope.stateOf(context),
        seat.sectionLabel,
      ),
    );
    final number = seat.seatNumber?.trim().isNotEmpty ?? false
        ? seat.seatNumber!.trim()
        : seat.buyerFacingLabel;
    final rowWord = _rowWord(seat, strings);
    final seatWord = _seatWord(seat, strings);
    final layout = theme.layout;
    final hasSection = section.isNotEmpty;
    final cells = <(String, String)>[
      if (hasSection) (strings.sectionWord, section),
      if (row.isNotEmpty) (rowWord, row),
      (seatWord, number),
    ];
    final children = <Widget>[];
    for (var index = 0; index < cells.length; index++) {
      if (index > 0) {
        children.add(
            ColoredBox(color: theme.divider, child: const SizedBox(width: 1)));
      }
      children.add(
        Expanded(
          // Three equal tracks. The section is no longer the odd one out: the
          // cells are the same width whether or not there is a section to
          // show, so the eye lands on the same three places every time.
          child: _cell(
            context,
            cells[index].$1,
            cells[index].$2,
            longSection: hasSection &&
                index == 0 &&
                cells[index].$2.length > _sectionShortMax,
          ),
        ),
      );
    }
    return Semantics(
      container: true,
      label: strings.seatIdentity(<String>[
        if (hasSection) section,
        if (row.isNotEmpty) '$rowWord $row',
        '$seatWord $number',
      ]),
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.divider)),
          ),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: layout.confirmIdentityHeight),
            // Intrinsic, so a section name that needs its second line gets
            // one and the hairlines between the cells still run the full
            // height of whatever the tallest cell turned out to be.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    String eyebrow,
    String value, {
    required bool longSection,
  }) {
    final theme = seatLayerPickerThemeOf(context);
    return Padding(
      padding: immersive
          ? const EdgeInsets.fromLTRB(
              SeatLayerSizeTokens.confirmImmersiveCellSide,
              SeatLayerSizeTokens.confirmImmersiveCellTop,
              SeatLayerSizeTokens.confirmImmersiveCellSide,
              SeatLayerSizeTokens.confirmImmersiveCellBottom,
            )
          : const EdgeInsets.fromLTRB(6, 8, 6, 7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            eyebrow.toUpperCase(),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: SeatLayerSizeTokens.confirmIdentityKeyFontSize,
              height: 1.2,
              letterSpacing:
                  SeatLayerSizeTokens.confirmIdentityKeyFontSize * .1,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
              fontFamily: theme.fontFamily,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            // Only a LONG section name is worth a second line, and only it
            // gives up the big type to get one. `209` stays the same size as
            // the row letter and the seat number beside it.
            maxLines: longSection ? 2 : 1,
            softWrap: longSection,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.text,
              fontSize: longSection
                  ? (immersive
                      ? SeatLayerSizeTokens.confirmImmersiveSectionFontSize
                      : SeatLayerSizeTokens.confirmIdentityLongSectionFontSize)
                  : (immersive
                      ? SeatLayerSizeTokens.confirmImmersiveValueFontSize
                      : SeatLayerSizeTokens.confirmIdentityValueFontSize),
              height: longSection ? 1.2 : 1.1,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
              fontFamily: theme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  /// What the chart calls a row, where it called it anything.
  static String _rowWord(SelectedSeat seat, SeatLayerPickerStrings strings) =>
      seat.displayType?.trim().isNotEmpty ?? false
          ? seat.displayType!.trim()
          : seat.rowType?.trim().isNotEmpty ?? false
              ? seat.rowType!.trim()
              : strings.rowWord;

  static String _seatWord(SelectedSeat seat, SeatLayerPickerStrings strings) =>
      seat.objectType == ObjectType.booth
          ? strings.placeWord
          : strings.seatWord;
}

/// The longest section label that keeps the identity grid's big centred type.
///
/// Six characters covers every numbered section a chart writes — `209`,
/// `A12`, `Box 4` — and stops at the venue phrases that need to wrap.
const int _sectionShortMax = SeatLayerSizeTokens.confirmSectionShortMax;

/// How far down the card has to be pushed before letting go cancels.
///
/// Far enough that a thumb resting on the card while the map settles cannot
/// reach it, and short enough to be one comfortable flick.
const double _dismissDrag = 72;

/// A downward flick this fast cancels however short it was.
///
/// Points per second. A deliberate flick clears it easily; the drift at the
/// end of a slow, reconsidered drag does not.
const double _dismissVelocity = 700;

/// The category, in the category's own colour, and what it costs.
///
/// The map is already painted in these colours, so the band is the one place
/// on the card where naming the category earns its line: the buyer matches the
/// colour to the seat they just tapped. It is the colour ITSELF, full bleed —
/// a tint under a nine-point disc said the colour twice and loudly enough
/// neither time. The words take [pickerBandInk], chosen per colour, so a pale
/// yellow category keeps its name. The price lives here rather than on the
/// button, where it would be the same number the cart is about to say.
///
/// It prints the name and the price and NOTHING else. A remaining count beside
/// them — "6,600 left" — said nothing a buyer choosing one seat could act on,
/// and it pushed the price into the card's edge. The legend still carries the
/// count, where a buyer comparing categories is actually looking.
class _CategoryBand extends StatelessWidget {
  const _CategoryBand({
    required this.category,
    required this.color,
    required this.price,
    required this.currency,
    this.immersive = false,
  });

  final SeatLayerPickerCategory category;
  final Color color;
  final double? price;
  final String currency;

  /// Whether the card is being read over the 3D venue, where the band gives
  /// back a few points and the price steps down one size: the scene behind
  /// the card is the loud thing there, not the card.
  final bool immersive;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final layout = theme.layout;
    final ink = pickerBandInk(color);
    return DecoratedBox(
      // The colour the legend and the map speak, undiluted.
      decoration: BoxDecoration(color: color),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: layout.confirmBandHeight),
        child: Padding(
          padding: immersive
              ? const EdgeInsetsDirectional.symmetric(
                  vertical: SeatLayerSizeTokens.confirmImmersiveBandPadY,
                  horizontal: SeatLayerSizeTokens.confirmImmersiveBandPadX,
                )
              : const EdgeInsetsDirectional.fromSTEB(
                  SeatLayerSizeTokens.confirmBandPadLeading,
                  SeatLayerSizeTokens.confirmBandPadTop,
                  SeatLayerSizeTokens.confirmBandPadTrailing,
                  SeatLayerSizeTokens.confirmBandPadBottom,
                ),
          child: Row(
            children: [
              // The name takes the room and gives way first; the price is the
              // fact the buyer came for and never truncates.
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ink,
                    fontSize: SeatLayerSizeTokens.confirmBandNameFontSize,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ),
              if (price != null) ...[
                const SizedBox(width: 8),
                Text(
                  pickerMoney(context, price!, currency),
                  softWrap: false,
                  style: TextStyle(
                    color: ink,
                    fontSize: immersive
                        ? SeatLayerSizeTokens
                            .confirmImmersiveBandPriceFontSize
                        : SeatLayerSizeTokens.confirmBandPriceFontSize,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                    fontFamily: theme.fontFamily,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The card's own box: the surface, its hairline, and the shadow under it.
///
/// Split out so the shadow can be a real `BoxShadow` — long, offset downwards
/// and drawn tighter than it is blurred — rather than a Material elevation,
/// which cannot spread inwards. A host that names its own elevation gets
/// Material's shadow instead, because that is what it asked for.
class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.style, required this.child});

  final SeatLayerSurfaceStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final radius = BorderRadius.circular(SeatLayerRadiusTokens.confirmCard);
    final surface = Material(
      key: const ValueKey<String>('seatlayer.confirm-card.surface'),
      color: style.color ?? theme.surface,
      elevation: style.elevation ?? 0,
      shadowColor: pickerAlpha(const Color(0xFF000000), .72),
      shape: style.shape ??
          RoundedRectangleBorder(
            borderRadius: radius,
            // The card's edge is the divider pulled towards the ink, so it
            // holds against a map of any colour behind it.
            side: BorderSide(color: Color.lerp(theme.divider, theme.text, .3)!),
          ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
    if (style.elevation != null) return surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: pickerAlpha(const Color(0xFF000000), .72),
            blurRadius: 64,
            spreadRadius: -18,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: surface,
    );
  }
}

/// The seat photograph, with both ways into it riding its bottom corners.
///
/// The photograph is authored: the runtime names it as an event-scoped API
/// path on the seat, and the bytes come back through
/// [SeatLayerBuyerAssetLoader] because a private event answers that path only
/// for the buyer's own bearer. Until they land the strip is the neutral
/// gradient it has always been; if they never land the strip animates itself
/// away and leaves the card entirely, exactly as the web's
/// `.sl-confirm-thumb-out` does.
///
/// It is full-bleed inside the card's own radius — a photograph inset from the
/// card's edge reads as an illustration in an article rather than as the view
/// being sold.
class _PhotoStrip extends StatefulWidget {
  const _PhotoStrip({
    required this.onViewFromSeat,
    required this.onShow3D,
    this.thumb,
    this.sightlineMetres,
    this.onMissed,
  });

  final VoidCallback? onViewFromSeat;
  final VoidCallback? onShow3D;

  /// Told once when the photograph is known not to be coming.
  final VoidCallback? onMissed;

  /// Where the photograph lives, or null when the runtime named none.
  final SeatViewThumb? thumb;

  /// Distance to the stage, when the chart has one.
  final double? sightlineMetres;

  @override
  State<_PhotoStrip> createState() => _PhotoStripState();
}

class _PhotoStripState extends State<_PhotoStrip> {
  Uint8List? _bytes;
  String? _requested;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant _PhotoStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.thumb?.reference != widget.thumb?.reference) _fetch();
  }

  /// Ask for this seat's photograph, once per reference.
  ///
  /// Started when the card opens rather than when it settles: the runtime
  /// resolves the seat after the card is already mounted, and a buyer looking
  /// at a card should not wait for an animation to end before the picture
  /// starts arriving. Nothing is cancelled on dismissal — the loader's cache
  /// is what makes reopening the same seat instant.
  void _fetch() {
    final reference = widget.thumb?.reference;
    if (reference == null || reference == _requested) return;
    _requested = reference;
    _bytes = null;
    final loader = SeatLayerPickerScope.controllerOf(context).assetLoader;
    unawaited(
      loader.load(reference).then((bytes) {
        if (!mounted || _requested != reference) return;
        // A miss is evicted so the next open of the same seat tries again:
        // the usual reason for one is a bearer that had just expired.
        if (bytes == null) {
          loader.evict(reference);
          widget.onMissed?.call();
          return;
        }
        setState(() => _bytes = bytes);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final layout = theme.layout;
    final reduced = SeatLayerPickerMotion.reduced(context);
    final bytes = _bytes;
    return SizedBox(
      height: layout.confirmPhotoHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color.alphaBlend(
                      pickerAlpha(theme.accent, .22),
                      theme.surface,
                    ),
                    Color.alphaBlend(
                      pickerAlpha(theme.text, .12),
                      theme.surface,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (bytes != null)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: 1,
                duration:
                    reduced ? Duration.zero : SeatLayerPickerMotion.crossfade,
                // The picture is what the pills open, and the pills say what
                // they open: a second name for the same thing would be read
                // out twice.
                child: ExcludeSemantics(
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          if (widget.sightlineMetres != null)
            Positioned(
              right: 6,
              top: 6,
              child: _SightlinePill(metres: widget.sightlineMetres!),
            ),
          Positioned(
            left: 6,
            bottom: 6,
            child: _Pill(
              icon: Icons.visibility_outlined,
              label: strings.viewFromHere,
              semanticsLabel: strings.viewFromHere,
              onPlate: true,
              onPressed: widget.onViewFromSeat,
            ),
          ),
          if (widget.onShow3D != null)
            Positioned(
              right: 6,
              bottom: 6,
              child: _Pill(
                icon: Icons.view_in_ar_rounded,
                label: strings.venue3D,
                // The pill says "3D"; a screen reader hears the sentence.
                semanticsLabel: strings.seeItIn3D,
                onPlate: true,
                onPressed: widget.onShow3D,
              ),
            ),
        ],
      ),
    );
  }
}

/// The photo strip, and the nothing it collapses into, as one animated slot.
///
/// The web animates height and opacity for 160 ms when the image never
/// arrives, and the strip then leaves the card entirely. Doing the same here
/// keeps the card from jumping under a thumb already reaching for `Add seat`.
///
/// [missed] is the card's own state, not this widget's: when the photograph
/// goes, the 3D action has to appear in the decision row below, and only the
/// card can put it there.
class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.thumb,
    required this.missed,
    required this.sightlineMetres,
    required this.onMissed,
    required this.onViewFromSeat,
    required this.onShow3D,
  });

  final SeatViewThumb thumb;
  final bool missed;
  final double? sightlineMetres;
  final VoidCallback onMissed;
  final VoidCallback? onViewFromSeat;
  final VoidCallback? onShow3D;

  @override
  Widget build(BuildContext context) {
    final reduced = SeatLayerPickerMotion.reduced(context);
    return AnimatedSize(
      duration: reduced ? Duration.zero : SeatLayerPickerMotion.thumbOut,
      alignment: Alignment.topCenter,
      child: missed
          ? const SizedBox(width: double.infinity)
          : _PhotoStrip(
              thumb: thumb,
              sightlineMetres: sightlineMetres,
              onViewFromSeat: onViewFromSeat,
              onShow3D: onShow3D,
              onMissed: onMissed,
            ),
    );
  }
}

/// The same sentence on the photograph, where it takes the photo plate.
class _SightlinePill extends StatelessWidget {
  const _SightlinePill({required this.metres});

  final double metres;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _plate,
        borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SeatLayerSizeTokens.confirmSightPadX,
          vertical: SeatLayerSizeTokens.confirmSightPadY,
        ),
        child: Text(
          strings.sightline(_sightlineFigure(metres)),
          softWrap: false,
          style: TextStyle(
            color: _plateInk,
            fontSize: SeatLayerSizeTokens.confirmSightFont,
            fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
            fontFamily: theme.fontFamily,
          ),
        ),
      ),
    );
  }
}

/// The metre figure as the runtime rounded it.
///
/// The number arrives already rounded, so this only decides whether to print
/// a decimal point at all: `7` rather than `7.0`, `7.4` unchanged.
String _sightlineFigure(double metres) =>
    metres == metres.roundToDouble() ? '${metres.round()}' : '$metres';

/// The 3D way in as a square in the decision row, in front of `Cancel`.
///
/// Where there is no photograph there is no strip to hold a pill, and a 44 pt
/// bar carrying one control was dead height on a card that already covers a
/// third of the phone. The action keeps its full target and its full spoken
/// name; what it loses is a row of its own.
class _See3dSquare extends StatelessWidget {
  const _See3dSquare({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final side = seatLayerScaledExtent(
      context,
      SeatLayerSizeTokens.minimumHitTarget,
      max: SeatLayerTypeScaleTokens.card,
    );
    return SizedBox(
      width: side,
      height: side,
      child: Material(
        // The accent, held back to a tint: this is the way further in, not
        // the answer to the card's question.
        color: Color.alphaBlend(pickerAlpha(theme.accent, .12), theme.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.button),
          side: BorderSide(color: theme.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.view_in_ar_rounded, size: 15, color: theme.text),
              const SizedBox(height: 1),
              Text(
                strings.venue3D,
                // The square has no room for the sentence; a screen reader
                // hears it anyway.
                semanticsLabel: strings.seeItIn3D,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: theme.text,
                  fontSize: SeatLayerSizeTokens.confirm3dSquareFontSize,
                  height: 1.1,
                  letterSpacing: .4,
                  fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The card's inspection row inside the 3D venue.
///
/// One line of compact chips, not a stack of full-width rows. The passport and
/// the view from the seat used to be two 44 pt bars above the two answers,
/// which put the card over the very section the buyer had just flown into.
/// They are 40 pt chips side by side now, and the card is roughly a hundred
/// points shorter for it.
///
/// The web's third chip, `Save to compare`, is absent: nothing in
/// `seatlayer.picker.snapshot/1` carries a compare set, and a control that
/// cannot say anything true is worse than an absent one.
class _InspectionRow extends StatelessWidget {
  const _InspectionRow({
    required this.onPassport,
    required this.onViewFromSeat,
  });

  /// Opens the runtime's seat-confidence passport, or null where the card is
  /// showing the teaser instead.
  final VoidCallback? onPassport;

  /// Opens the view from this seat, or null where the runtime cannot.
  final VoidCallback? onViewFromSeat;

  @override
  Widget build(BuildContext context) {
    final strings = SeatLayerPickerScope.stringsOf(context);
    final chips = <Widget>[
      if (onPassport != null)
        _InspectChip(
          // The accent dot is the passport's mark on the web chip; the word
          // beside it is the whole label at this size.
          dot: true,
          label: strings.passport,
          semanticsLabel: strings.passport,
          onPressed: onPassport,
        ),
      if (onViewFromSeat != null)
        _InspectChip(
          dot: false,
          // The seat is named twice directly above this chip, so the visible
          // word is the short one; a screen reader still hears the sentence.
          label: strings.viewFromHere,
          semanticsLabel: strings.viewFromThisSeat,
          onPressed: onViewFromSeat,
        ),
    ];
    return Row(
      children: <Widget>[
        for (var index = 0; index < chips.length; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(child: chips[index]),
        ],
      ],
    );
  }
}

/// One 40 pt chip on the 3D card's inspection row.
class _InspectChip extends StatelessWidget {
  const _InspectChip({
    required this.dot,
    required this.label,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final bool dot;
  final String label;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: SeatLayerSizeTokens.confirmInspectChipHeight,
      ),
      child: Material(
        // The accent, held back to a tint: these are ways further in, not
        // the answer to the card's question, and the answer is the only
        // filled button on the card.
        color: Color.alphaBlend(pickerAlpha(theme.accent, .12), theme.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.button),
          side: BorderSide(color: theme.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dot) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: theme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    // The chip prints the word that fits; a screen reader
                    // hears the whole sentence.
                    semanticsLabel: semanticsLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: SeatLayerSizeTokens.confirmInspectChipFontSize,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What the runtime is willing to say about how this seat's view was made.
///
/// 3D only, as on the web: outside the scene there is no model on screen to be
/// honest about. It is the teaser, not the passport — the passport itself is
/// the runtime's own surface and the bridge exposes no command to open it — so
/// this is a BUTTON only where a host has taken
/// [SeatLayerPickerCallbacks.onSeatConfidence] and can show something. With no
/// callback it stays an information row: a control that opens nothing is worse
/// than a line of text.
class _ConfidenceTeaser extends StatelessWidget {
  const _ConfidenceTeaser({required this.disclosure, required this.onOpen});

  final SeatConfidenceDisclosure disclosure;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final detail = disclosure.modeledTarget ?? disclosure.reality;
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SeatLayerSizeTokens.confidenceTeaserPadX,
        vertical: SeatLayerSizeTokens.confidenceTeaserPadY,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  disclosure.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: SeatLayerSizeTokens.confidenceTeaserHeadFont,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
                    fontFamily: theme.fontFamily,
                  ),
                ),
                if (detail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.mutedText,
                        fontSize:
                            SeatLayerSizeTokens.confidenceTeaserDetailFont,
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            strings.passport,
            softWrap: false,
            style: TextStyle(
              color: theme.accentText,
              fontSize: SeatLayerSizeTokens.confidenceTeaserBadgeFont,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w700),
              fontFamily: theme.fontFamily,
            ),
          ),
        ],
      ),
    );
    final open = onOpen;
    return Padding(
      padding: const EdgeInsets.only(
        top: SeatLayerSizeTokens.confidenceTeaserTop,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: SeatLayerSizeTokens.confidenceTeaserMinHeight,
        ),
        child: Material(
          color:
              Color.alphaBlend(pickerAlpha(theme.accent, .07), theme.surface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SeatLayerSizeTokens.confidenceTeaserRadius,
            ),
            side: BorderSide(
              color: Color.alphaBlend(
                pickerAlpha(theme.accent, .35),
                theme.divider,
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: open == null
              // Not focusable, not a button, and not announced as one: there
              // is nothing behind it to press.
              ? row
              : Semantics(
                  button: true,
                  child: InkWell(onTap: open, child: row),
                ),
        ),
      ),
    );
  }
}

/// One pill on the photo strip, or on the rail that stands in for it.
///
/// On a photograph it takes a dark plate and white ink in both themes: a
/// photograph can be any colour, and the one pairing that survives all of
/// them is white on near-black. On the rail there is no photograph to survive,
/// so it takes the card's own tokens instead.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onPlate,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final bool onPlate;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final layout = theme.layout;
    final ink = onPlate ? _plateInk : theme.text;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
      side: onPlate ? BorderSide.none : BorderSide(color: theme.divider),
    );
    final pill = Material(
      color: onPlate ? _plate : theme.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: layout.confirmPillHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: ink),
                const SizedBox(width: 5),
                Text(
                  label,
                  softWrap: false,
                  style: TextStyle(
                    color: ink,
                    fontSize: 11,
                    fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: onPlate
          // The plate is translucent, so what is behind it is softened rather
          // than merely darkened — the same treatment the web pill gets.
          ? ClipRRect(
              borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: pill,
              ),
            )
          : pill,
    );
  }
}

/// The photo scrim, dark in both themes because a photograph can be anything.
const Color _plate = Color(0xB80A0E16);

/// Its ink. Measured at 7.5:1 over a pure-white photograph.
const Color _plateInk = Color(0xFFFFFFFF);

/// Which ticket the seat is being bought as.
///
/// A labelled set of rows rather than a dropdown: on a card this small the
/// prices are the point of the choice, and a closed menu hides them.
class _TierPicker extends StatelessWidget {
  const _TierPicker({
    required this.tiers,
    required this.currency,
    required this.selectedId,
    required this.enabled,
    required this.onSelected,
  });

  final List<CategoryTier> tiers;
  final String currency;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              strings.ticketType.toUpperCase(),
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                fontFamily: theme.fontFamily,
              ),
            ),
          ),
          for (var index = 0; index < tiers.length; index++)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 6),
              child: SeatLayerPickerSeatTierChoice(
                tier: tiers[index],
                currency: currency,
                selected: selectedId == tiers[index].id,
                enabled: enabled,
                compact: true,
                onTap: () => onSelected(tiers[index].id),
              ),
            ),
        ],
      ),
    );
  }
}

/// The one thing a single ticket type has to say for itself.
class _TierNote extends StatelessWidget {
  const _TierNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        note,
        style: TextStyle(
          color: theme.mutedText,
          fontSize: 11,
          height: 1.4,
          fontFamily: theme.fontFamily,
        ),
      ),
    );
  }
}

/// What the organizer has declared about this seat, before the buyer buys it.
///
/// Both blocks are disclosures rather than decoration, so they sit between the
/// price and the answer, where they cannot be scrolled past by accident.
class _SeatNotices extends StatelessWidget {
  const _SeatNotices({
    required this.premium,
    required this.viewNotice,
    required this.note,
  });

  final bool premium;
  final String? viewNotice;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final blocks = <Widget>[
      if (premium)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                pickerAlpha(_premium, .13),
                theme.surface,
              ),
              borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.pill),
              border: Border.all(
                color: Color.alphaBlend(
                  pickerAlpha(_premium, .38),
                  theme.divider,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 12, color: _premium),
                  const SizedBox(width: 6),
                  Text(
                    strings.premiumSeat,
                    style: TextStyle(
                      color: _premiumInk,
                      fontSize: 11,
                      letterSpacing: .22,
                      fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      if (viewNotice != null || note != null)
        DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              pickerAlpha(theme.warning, .13),
              theme.surface,
            ),
            borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.button),
            border: Border.all(
              color: Color.alphaBlend(
                pickerAlpha(theme.warning, .40),
                theme.divider,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  // A view worth warning about gets the half-blocked glyph; a
                  // note the organizer simply wanted read gets an `i`.
                  viewNotice == null
                      ? Icons.info_outline_rounded
                      : Icons.visibility_off_outlined,
                  size: 14,
                  color: theme.warning,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (viewNotice != null)
                        Text(
                          viewNotice!,
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 12,
                            fontWeight:
                                seatLayerBoldWeight(context, FontWeight.w800),
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                      if (note != null)
                        Text(
                          note!,
                          style: TextStyle(
                            color: theme.mutedText,
                            fontSize: 11,
                            height: 1.4,
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var index = 0; index < blocks.length; index++)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 6),
              child: blocks[index],
            ),
        ],
      ),
    );
  }
}

/// The premium badge's own gold, and the ink that reads on it.
const Color _premium = Color(0xFFE8C15A);
const Color _premiumInk = Color(0xFFC9A24B);
