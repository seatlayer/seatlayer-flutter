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
/// `Gallery · Row A · Seat 1`. The section takes whatever the other two leave,
/// because it is the only one of the three that is ever a real name; with no
/// section to show, the remaining cells share the width evenly.
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
          // The section is the only one of the three that is ever a real
          // name, so it gets the widest track and the seat number — always
          // short, always the thing the buyer came for — the narrowest.
          flex: hasSection ? _identityTracks[index] : _identityEvenTrack,
          child: _cell(
            context,
            cells[index].$1,
            cells[index].$2,
            section: hasSection && index == 0,
            centred: !hasSection || index > 0,
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
    required bool section,
    required bool centred,
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
          : const EdgeInsets.fromLTRB(8, 7, 8, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            centred ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            maxLines: 1,
            textAlign: centred ? TextAlign.center : TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 8.5,
              height: 1.2,
              letterSpacing: .85,
              fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
              fontFamily: theme.fontFamily,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            // A section name is the one value worth a second line: at
            // identity-confirmation time a clipped name is a name the buyer
            // cannot check the map against.
            maxLines: section ? 2 : 1,
            softWrap: section,
            textAlign: centred ? TextAlign.center : TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.text,
              fontSize: section
                  ? (immersive
                      ? SeatLayerSizeTokens.confirmImmersiveSectionFontSize
                      : 12.5)
                  : (immersive
                      ? SeatLayerSizeTokens.confirmImmersiveValueFontSize
                      : 15),
              height: section ? 1.2 : 1.1,
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

/// The identity grid's three tracks, as the web picker weights them.
///
/// `1.12 : 1 : .58` — the section takes the most, the seat number the least.
const List<int> _identityTracks = <int>[112, 100, 58];

/// With no section to show, the remaining cells share the width evenly.
const int _identityEvenTrack = 1;

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
/// tint to the seat they just tapped. The price lives here rather than on the
/// button, where it would be the same number the cart is about to say.
class _CategoryBand extends StatelessWidget {
  const _CategoryBand({
    required this.category,
    required this.color,
    required this.price,
    required this.currency,
  });

  final SeatLayerPickerCategory category;
  final Color color;
  final double? price;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final layout = theme.layout;
    // A count the buyer cannot trust is worse than no count. A runtime that
    // reports live free seats is believed even at zero; an older one's
    // availability reads zero before counts arrive, so only a positive
    // number from it is printed, and otherwise the band says nothing.
    final count =
        category.free ?? (category.available > 0 ? category.available : null);
    final known = count != null;
    final name = Text(
      category.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: theme.text,
        fontSize: 12.5,
        fontWeight: seatLayerBoldWeight(context, FontWeight.w800),
        fontFamily: theme.fontFamily,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        // A tint, not a fill: the ink stays the theme's own, so no category
        // colour has to have a readable ink manufactured for it.
        color: Color.alphaBlend(pickerAlpha(color, .11), theme.surface),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: layout.confirmBandHeight),
        child: Stack(
          children: [
            // The rail is the category's colour on the leading edge, drawn
            // under the padding rather than beside it.
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: SizedBox(width: 3, child: ColoredBox(color: color)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: pickerAlpha(theme.text, .22)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // The name keeps its width first; the count is the cell
                  // that gives way, because a truncated category name is a
                  // seat the buyer cannot identify.
                  if (known) name else Expanded(child: name),
                  if (known) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.seatsLeft(count),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.mutedText,
                          fontSize: 11,
                          fontWeight:
                              seatLayerBoldWeight(context, FontWeight.w700),
                          fontFamily: theme.fontFamily,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (price != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      pickerMoney(context, price!, currency),
                      softWrap: false,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 15,
                        fontWeight:
                            seatLayerBoldWeight(context, FontWeight.w800),
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
          ],
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
/// away and the no-photo rail takes over, exactly as the web's
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

/// The photo strip and the rail it collapses into, as one animated slot.
///
/// The web animates height and opacity for 160 ms when the image never
/// arrives, and the strip is replaced in place by the rail. Doing the same
/// here keeps the card from jumping under a thumb already reaching for
/// `Add seat`.
class _PhotoSlot extends StatefulWidget {
  const _PhotoSlot({
    required this.thumb,
    required this.sightlineMetres,
    required this.onViewFromSeat,
    required this.onShow3D,
  });

  final SeatViewThumb thumb;
  final double? sightlineMetres;
  final VoidCallback? onViewFromSeat;
  final VoidCallback? onShow3D;

  @override
  State<_PhotoSlot> createState() => _PhotoSlotState();
}

class _PhotoSlotState extends State<_PhotoSlot> {
  bool _missed = false;

  @override
  void didUpdateWidget(covariant _PhotoSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A different seat is a different photograph: the last one's absence says
    // nothing about this one.
    if (oldWidget.thumb.reference != widget.thumb.reference) _missed = false;
  }

  @override
  Widget build(BuildContext context) {
    final reduced = SeatLayerPickerMotion.reduced(context);
    return AnimatedSize(
      duration: reduced ? Duration.zero : SeatLayerPickerMotion.thumbOut,
      alignment: Alignment.topCenter,
      child: _missed
          ? _NoPhotoRail(
              sightlineMetres: widget.sightlineMetres,
              onShow3D: widget.onShow3D,
            )
          : _PhotoStrip(
              thumb: widget.thumb,
              sightlineMetres: widget.sightlineMetres,
              onViewFromSeat: widget.onViewFromSeat,
              onShow3D: widget.onShow3D,
              onMissed: () {
                if (mounted) setState(() => _missed = true);
              },
            ),
    );
  }
}

/// The rail, with the sight line printed above it when there is one.
///
/// With no photograph the web keeps only the sight line, in its desktop form:
/// a small muted line rather than a pill, because there is no photograph for a
/// plate to survive. `View from here` is not offered — there is nothing to
/// open.
class _NoPhotoRail extends StatelessWidget {
  const _NoPhotoRail({required this.sightlineMetres, required this.onShow3D});

  final double? sightlineMetres;
  final VoidCallback? onShow3D;

  @override
  Widget build(BuildContext context) {
    final metres = sightlineMetres;
    final rail = onShow3D == null
        ? const SizedBox.shrink()
        : _ActionRail(onShow3D: onShow3D);
    if (metres == null) return rail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [_SightlineCaption(metres: metres), rail],
    );
  }
}

/// "≈ 7 m to stage" as a caption, off the photograph.
class _SightlineCaption extends StatelessWidget {
  const _SightlineCaption({required this.metres});

  final double metres;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: Text(
        strings.sightline(_sightlineFigure(metres)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.mutedText,
          fontSize: 11,
          fontWeight: seatLayerBoldWeight(context, FontWeight.w500),
          fontFamily: theme.fontFamily,
        ),
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

/// The strip with no picture in it: a plain rail carrying the same pills.
///
/// An empty gradient frame promises a photograph nothing is going to open, so
/// where the only action is 3D the strip loses the picture and keeps the way
/// in, on the card's own tokens rather than on a photo scrim.
class _ActionRail extends StatelessWidget {
  const _ActionRail({required this.onShow3D});

  final VoidCallback? onShow3D;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    final layout = theme.layout;
    return SizedBox(
      height: seatLayerScaledExtent(
        context,
        layout.confirmRailHeight,
        max: SeatLayerTypeScaleTokens.card,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pickerAlpha(theme.divider, theme.divider.a * .26),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              _Pill(
                icon: Icons.view_in_ar_rounded,
                label: strings.venue3D,
                semanticsLabel: strings.seeItIn3D,
                onPlate: false,
                onPressed: onShow3D,
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
/// In the scene the venue is already the picture, so there is nothing for a
/// photo strip to stand in for: the one view the buyer has not had is the one
/// from the seat itself, and it takes the whole row rather than half of it.
/// The web card puts `Save to compare` and a confidence teaser in the other
/// half; neither has any data behind it in
/// `seatlayer.picker.snapshot/1`, and a control that cannot say anything true
/// is worse than an absent one.
class _InspectionRow extends StatelessWidget {
  const _InspectionRow({required this.onViewFromSeat});

  final VoidCallback? onViewFromSeat;

  @override
  Widget build(BuildContext context) {
    final theme = seatLayerPickerThemeOf(context);
    final strings = SeatLayerPickerScope.stringsOf(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: SeatLayerSizeTokens.minimumHitTarget,
      ),
      child: Material(
        // The accent, held back to a tint: this is the way further in, not
        // the answer to the card's question, and the answer is the only
        // filled button on the card.
        color: Color.alphaBlend(pickerAlpha(theme.accent, .12), theme.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeatLayerRadiusTokens.button),
          side: BorderSide(color: theme.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onViewFromSeat,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.view_in_ar_rounded, size: 15, color: theme.text),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    strings.viewFromThisSeat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 12,
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
