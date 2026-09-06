/// ONE drawing per seat attribute, shared with every other SeatLayer surface.
///
/// The buyer picker names twelve accommodations, three selling marks and the
/// organizer's own note, and until now the native chrome drew them with
/// whatever Material icon came closest — a wheelchair for every accommodation
/// on the accessibility sheet, an eye for a view restriction, a filled star
/// for premium. Material's set is not the set the map, the designer and the
/// web popups draw, so the same seat wore a different mark on every surface.
///
/// The geometry here is transcribed VERBATIM from the shared icon set in the
/// runtime (`core/render-assets/seatTypeIcons.ts`), which is itself the
/// designer's own artwork. That is why the box is 20 rather than Material's
/// 24, and why every glyph is stroke-only: a row's tone (neutral, amber, gold,
/// muted) is one colour away, with no second icon set to keep in step.
///
/// Two rules make this safe to copy into the iOS, Android and React Native
/// ports:
///
///  * **No emoji and no platform icon.** An emoji arrives in a colour, weight
///    and baseline the host font decides, and no theme can reach it.
///  * **The path data is the contract.** Ports transcribe these same strings.
///    Redrawing a glyph "close enough" is how five surfaces drifted apart.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'picker_tokens.g.dart';

/// The square every glyph below is authored in.
const double seatLayerSeatIconViewBox = 20;

/// Stroke weight at the authored box size, scaled with the drawn size.
const double seatLayerSeatIconStrokeWidth = 1.45;

/// One glyph: circles the web draws as `<circle>`, then its `<path>` data.
///
/// Kept apart rather than folded into one path string so the transcription can
/// be read against the web source element for element.
@immutable
class SeatLayerSeatGlyph {
  /// Creates a glyph from its circles and path data.
  const SeatLayerSeatGlyph({
    this.circles = const <List<double>>[],
    this.paths = const <String>[],
    this.fills = const <String>[],
  });

  /// `[cx, cy, r]` per circle, in the 20-unit box.
  final List<List<double>> circles;

  /// SVG path data, in the 20-unit box, stroked.
  final List<String> paths;

  /// SVG path data painted FILLED — the web's `fill="currentColor"` shapes.
  final List<String> fills;
}

/// Every glyph the picker can ask for, by the runtime's own key.
///
/// The twelve accommodation keys are the runtime's `accessibility[]` values;
/// `restrictedView`, `obstructedView` and `premium` are its commercial marks;
/// `note` is the organizer's free sentence.
const Map<String, SeatLayerSeatGlyph> seatLayerSeatGlyphs =
    <String, SeatLayerSeatGlyph>{
  // A seated figure over a wheel — authored as an outline so it does not read
  // as a blob beside eleven outline siblings.
  'wheelchair': SeatLayerSeatGlyph(
    circles: <List<double>>[
      <double>[10.6, 3.7, 1.7],
      <double>[9.7, 13.3, 4.7],
    ],
    paths: <String>['M8.9 6.3v4.3a1.3 1.3 0 0 0 1.3 1.3h3.4l1.9 4.5h1.9'],
  ),
  'companion': SeatLayerSeatGlyph(
    circles: <List<double>>[
      <double>[6, 6, 2],
      <double>[14, 6, 2],
    ],
    paths: <String>[
      'M2.5 16v-3.5A3.5 3.5 0 0 1 6 9a3.5 3.5 0 0 1 3.5 3.5V16'
          'M10.5 16v-3.5A3.5 3.5 0 0 1 14 9a3.5 3.5 0 0 1 3.5 3.5V16',
    ],
  ),
  'semi-ambulatory': SeatLayerSeatGlyph(
    circles: <List<double>>[
      <double>[8, 4, 1.7],
    ],
    paths: <String>['m8 6 2 4 3 2M10 10l-2 3-1 4M10 10l2 7M14 7l2 10'],
  ),
  'designated-aisle': SeatLayerSeatGlyph(
    paths: <String>[
      'M3.5 5.5v7h8.5V10H6.5M5 12.5V17M11 12.5V17',
      'M13.5 6.5H19M16.5 4l2.5 2.5L16.5 9',
    ],
  ),
  'step-free': SeatLayerSeatGlyph(
    circles: <List<double>>[
      <double>[5.5, 5, 1.7],
    ],
    paths: <String>['M5.5 7v4l3 2M2.5 16.5H8l7-7h3M8 16.5h10'],
  ),
  'hearing': SeatLayerSeatGlyph(
    paths: <String>[
      'M7 16c-1-1.2-1.5-2.4-1.5-3.8V9a5 5 0 1 1 10 0c0 2.2-1.2 3.2-2.6 4'
          '-1.2.7-1.7 1.4-1.7 2.4A2.6 2.6 0 0 1 8.6 18',
    ],
  ),
  'cart': SeatLayerSeatGlyph(
    paths: <String>['M8 6.5A4 4 0 1 0 8 13M17 6.5a4 4 0 1 0 0 6.5'],
  ),
  'sign-language': SeatLayerSeatGlyph(
    paths: <String>[
      'M6 16V8.5a1 1 0 0 1 2 0v3M8 11V5.5a1 1 0 0 1 2 0V11M10 11V4.5a1 1 0 0 '
          '1 2 0V11M12 11V6a1 1 0 0 1 2 0v6l1-1.5a1.2 1.2 0 0 1 2 1.3L14 17H9.5'
          'A3.5 3.5 0 0 1 6 13.5',
    ],
  ),
  'low-vision': SeatLayerSeatGlyph(
    circles: <List<double>>[
      <double>[10, 10, 2.5],
    ],
    paths: <String>[
      'M2.5 10s3-5 7.5-5 7.5 5 7.5 5-3 5-7.5 5-7.5-5-7.5-5Z',
      'm15 4 .5-1.5M17 5l1.5-.8',
    ],
  ),
  'sensory-friendly': SeatLayerSeatGlyph(
    paths: <String>[
      'M4 11v-1a6 6 0 0 1 12 0v1M4 11h2.5v5H5a1 1 0 0 1-1-1v-4ZM16 11h-2.5v5'
          'H15a1 1 0 0 0 1-1v-4Z',
      'M8.5 11.5c.8.7 2.2.7 3 0M9 14c.6.4 1.4.4 2 0',
    ],
  ),
  'plus-size': SeatLayerSeatGlyph(
    paths: <String>[
      'M5 9V6.5A2.5 2.5 0 0 1 7.5 4h5A2.5 2.5 0 0 1 15 6.5V9M3.5 8.5v5h13v-5'
          'M6 13.5V17M14 13.5V17',
    ],
  ),
  'lift-armrest': SeatLayerSeatGlyph(
    paths: <String>[
      'M5 10V6.5A2.5 2.5 0 0 1 7.5 4h4A2.5 2.5 0 0 1 14 6.5V10M4 9v4h11V9'
          'M6 13v4M13 13v4',
      'M17 11V4M15 6l2-2 2 2',
    ],
  ),
  // An eye struck through: the view is BLOCKED, not merely poor.
  'obstructedView': SeatLayerSeatGlyph(
    paths: <String>[
      'M2.5 10s3-5 7.5-5 7.5 5 7.5 5-3 5-7.5 5-7.5-5-7.5-5Z',
      'm4 17 12-14',
    ],
  ),
  // An eye carrying a caution mark: you can see, with a caveat.
  'restrictedView': SeatLayerSeatGlyph(
    paths: <String>[
      'M2.5 10s3-5 7.5-5 7.5 5 7.5 5-3 5-7.5 5-7.5-5-7.5-5Z',
      'M10 7.5v3.5M10 13.5h.01',
    ],
  ),
  'premium': SeatLayerSeatGlyph(
    paths: <String>[
      'm10 2.5 2.2 4.6 5 .7-3.6 3.5.9 5-4.5-2.4-4.5 2.4.9-5-3.6-3.5 5-.7Z',
    ],
  ),
  // The organizer's own words about this seat — an ⓘ, replacing the ℹ emoji.
  'note': SeatLayerSeatGlyph(
    circles: <List<double>>[
      <double>[10, 10, 7.5],
    ],
    paths: <String>['M10 9.2v4.6M10 6.3h.01'],
  ),
  // NOT a seat attribute, and deliberately not in the shared set: the
  // accessibility sheet's colour row recolours the map rather than picking
  // seats, so it wears a contrast disc rather than an eye or a seat mark.
  'contrast': SeatLayerSeatGlyph(
    circles: <List<double>>[
      <double>[10, 10, 7.5],
    ],
    fills: <String>['M10 2.5a7.5 7.5 0 0 1 0 15Z'],
  ),
};

/// The glyph [key] names in the 20-unit box, or null where this build has none.
///
/// An unknown key returns null rather than a placeholder: a row whose drawing
/// is missing prints its words alone, which is a correct row, where a broken
/// box would be a defect the buyer can see.
Path? seatLayerSeatIconPath(String key) {
  final glyph = seatLayerSeatGlyphs[key];
  if (glyph == null) return null;
  final path = Path();
  for (final circle in glyph.circles) {
    path.addOval(
      Rect.fromCircle(
        center: Offset(circle[0], circle[1]),
        radius: circle[2],
      ),
    );
  }
  for (final data in glyph.paths) {
    path.addPath(seatLayerParseSvgPath(data), Offset.zero);
  }
  return path;
}

/// The filled half of the glyph [key] names, or null where it has none.
Path? seatLayerSeatIconFillPath(String key) {
  final fills = seatLayerSeatGlyphs[key]?.fills ?? const <String>[];
  if (fills.isEmpty) return null;
  final path = Path();
  for (final data in fills) {
    path.addPath(seatLayerParseSvgPath(data), Offset.zero);
  }
  return path;
}

/// The picker's own SVG path reader, for the transcribed glyph data.
///
/// Deliberately small and deliberately local: the package takes no third-party
/// dependency for sixteen drawings, and the only data it has to read is the
/// data in this file. It understands `M m L l H h V v C c S s A a Z z`, which
/// is every command the shared set uses.
///
/// Arc flags must be separated from their neighbours, as they are in the
/// authored data. The compact SVG form that glues `0 1 0` into `010` is not
/// accepted, and would be a transcription error rather than a new glyph style.
Path seatLayerParseSvgPath(String data) {
  final path = Path();
  final tokens = _SvgPathScanner(data);
  var current = Offset.zero;
  var start = Offset.zero;
  // Where a smooth cubic reflects its control point from.
  var lastControl = Offset.zero;
  var lastWasCubic = false;
  var command = '';

  while (true) {
    final next = tokens.command();
    if (next == null) break;
    command = next;
    final relative = command.toLowerCase() == command;
    switch (command.toUpperCase()) {
      case 'M':
        final point = tokens.point(relative ? current : Offset.zero);
        path.moveTo(point.dx, point.dy);
        current = start = point;
        lastWasCubic = false;
        // Further pairs after a moveto are lines, per the SVG grammar.
        while (tokens.hasNumber) {
          final line = tokens.point(relative ? current : Offset.zero);
          path.lineTo(line.dx, line.dy);
          current = line;
        }
      case 'L':
        while (tokens.hasNumber) {
          final point = tokens.point(relative ? current : Offset.zero);
          path.lineTo(point.dx, point.dy);
          current = point;
        }
        lastWasCubic = false;
      case 'H':
        while (tokens.hasNumber) {
          final x = tokens.number() + (relative ? current.dx : 0);
          current = Offset(x, current.dy);
          path.lineTo(current.dx, current.dy);
        }
        lastWasCubic = false;
      case 'V':
        while (tokens.hasNumber) {
          final y = tokens.number() + (relative ? current.dy : 0);
          current = Offset(current.dx, y);
          path.lineTo(current.dx, current.dy);
        }
        lastWasCubic = false;
      case 'C':
        while (tokens.hasNumber) {
          final origin = relative ? current : Offset.zero;
          final first = tokens.point(origin);
          final second = tokens.point(origin);
          final end = tokens.point(origin);
          path.cubicTo(
              first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
          current = end;
          lastControl = second;
          lastWasCubic = true;
        }
      case 'S':
        while (tokens.hasNumber) {
          final origin = relative ? current : Offset.zero;
          final second = tokens.point(origin);
          final end = tokens.point(origin);
          final first = lastWasCubic ? current * 2 - lastControl : current;
          path.cubicTo(
              first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
          current = end;
          lastControl = second;
          lastWasCubic = true;
        }
      case 'A':
        while (tokens.hasNumber) {
          final rx = tokens.number();
          final ry = tokens.number();
          final rotation = tokens.number();
          final largeArc = tokens.number() != 0;
          final sweep = tokens.number() != 0;
          final end = tokens.point(relative ? current : Offset.zero);
          _arcTo(path, current, end, rx, ry, rotation, largeArc, sweep);
          current = end;
        }
        lastWasCubic = false;
      case 'Z':
        path.close();
        current = start;
        lastWasCubic = false;
      default:
        throw FormatException('unsupported SVG path command', data);
    }
  }
  return path;
}

/// Append the elliptical arc SVG's `A` describes, as cubic segments.
///
/// The endpoint-to-centre conversion of the SVG specification, then at most
/// four cubics per arc — the standard approximation, whose error at a quarter
/// turn is far below one drawn pixel at these sizes.
void _arcTo(
  Path path,
  Offset from,
  Offset to,
  double rx,
  double ry,
  double rotationDegrees,
  bool largeArc,
  bool sweep,
) {
  if (rx == 0 || ry == 0 || from == to) {
    path.lineTo(to.dx, to.dy);
    return;
  }
  var radiusX = rx.abs();
  var radiusY = ry.abs();
  final phi = rotationDegrees * math.pi / 180;
  final cosPhi = math.cos(phi);
  final sinPhi = math.sin(phi);
  final dx2 = (from.dx - to.dx) / 2;
  final dy2 = (from.dy - to.dy) / 2;
  final x1 = cosPhi * dx2 + sinPhi * dy2;
  final y1 = -sinPhi * dx2 + cosPhi * dy2;

  // An arc too small for its radii is grown until it fits, exactly as the
  // specification says, rather than dropped.
  final lambda =
      (x1 * x1) / (radiusX * radiusX) + (y1 * y1) / (radiusY * radiusY);
  if (lambda > 1) {
    final scale = math.sqrt(lambda);
    radiusX *= scale;
    radiusY *= scale;
  }

  final sign = largeArc == sweep ? -1.0 : 1.0;
  final numerator = math.max(
    0.0,
    radiusX * radiusX * radiusY * radiusY -
        radiusX * radiusX * y1 * y1 -
        radiusY * radiusY * x1 * x1,
  );
  final denominator = radiusX * radiusX * y1 * y1 + radiusY * radiusY * x1 * x1;
  final coefficient = sign * math.sqrt(numerator / denominator);
  final cx1 = coefficient * radiusX * y1 / radiusY;
  final cy1 = -coefficient * radiusY * x1 / radiusX;
  final centre = Offset(
    cosPhi * cx1 - sinPhi * cy1 + (from.dx + to.dx) / 2,
    sinPhi * cx1 + cosPhi * cy1 + (from.dy + to.dy) / 2,
  );

  double angle(double ux, double uy, double vx, double vy) {
    final dot = ux * vx + uy * vy;
    final length = math.sqrt(ux * ux + uy * uy) * math.sqrt(vx * vx + vy * vy);
    final value = math.acos((dot / length).clamp(-1.0, 1.0));
    return ux * vy - uy * vx < 0 ? -value : value;
  }

  final startAngle = angle(1, 0, (x1 - cx1) / radiusX, (y1 - cy1) / radiusY);
  var sweepAngle = angle(
    (x1 - cx1) / radiusX,
    (y1 - cy1) / radiusY,
    (-x1 - cx1) / radiusX,
    (-y1 - cy1) / radiusY,
  );
  if (!sweep && sweepAngle > 0) {
    sweepAngle -= 2 * math.pi;
  } else if (sweep && sweepAngle < 0) {
    sweepAngle += 2 * math.pi;
  }

  final segments = math.max(1, (sweepAngle.abs() / (math.pi / 2)).ceil());
  final delta = sweepAngle / segments;
  final handle = 4 / 3 * math.tan(delta / 4);
  var theta = startAngle;
  for (var index = 0; index < segments; index++) {
    final next = theta + delta;
    Offset onArc(double t) => Offset(
          centre.dx +
              radiusX * math.cos(t) * cosPhi -
              radiusY * math.sin(t) * sinPhi,
          centre.dy +
              radiusX * math.cos(t) * sinPhi +
              radiusY * math.sin(t) * cosPhi,
        );
    Offset derivative(double t) => Offset(
          -radiusX * math.sin(t) * cosPhi - radiusY * math.cos(t) * sinPhi,
          -radiusX * math.sin(t) * sinPhi + radiusY * math.cos(t) * cosPhi,
        );
    final startPoint = onArc(theta);
    final endPoint = onArc(next);
    final first = startPoint + derivative(theta) * handle;
    final second = endPoint - derivative(next) * handle;
    path.cubicTo(
        first.dx, first.dy, second.dx, second.dy, endPoint.dx, endPoint.dy);
    theta = next;
  }
}

/// Reads commands and numbers out of SVG path data.
class _SvgPathScanner {
  _SvgPathScanner(this._data);

  final String _data;
  int _index = 0;

  void _skipSeparators() {
    while (_index < _data.length) {
      final code = _data.codeUnitAt(_index);
      // Space, tab, carriage return, newline, comma.
      if (code == 0x20 ||
          code == 0x09 ||
          code == 0x0d ||
          code == 0x0a ||
          code == 0x2c) {
        _index++;
      } else {
        return;
      }
    }
  }

  /// Whether a number follows, which is how a repeated command is detected.
  bool get hasNumber {
    _skipSeparators();
    if (_index >= _data.length) return false;
    final code = _data.codeUnitAt(_index);
    return (code >= 0x30 && code <= 0x39) ||
        code == 0x2d ||
        code == 0x2b ||
        code == 0x2e;
  }

  /// The next command letter, or null at the end of the data.
  String? command() {
    _skipSeparators();
    if (_index >= _data.length) return null;
    final character = _data[_index];
    if (hasNumber) {
      throw FormatException(
          'a number where a command was expected', _data, _index);
    }
    _index++;
    return character;
  }

  /// The next number.
  double number() {
    _skipSeparators();
    final start = _index;
    if (_index < _data.length &&
        (_data.codeUnitAt(_index) == 0x2d ||
            _data.codeUnitAt(_index) == 0x2b)) {
      _index++;
    }
    var seenDot = false;
    while (_index < _data.length) {
      final code = _data.codeUnitAt(_index);
      if (code >= 0x30 && code <= 0x39) {
        _index++;
      } else if (code == 0x2e && !seenDot) {
        // A second dot starts the NEXT number: `2.2.7` is two of them.
        seenDot = true;
        _index++;
      } else {
        break;
      }
    }
    final text = _data.substring(start, _index);
    final value = double.tryParse(text);
    if (value == null) {
      throw FormatException('not a number: "$text"', _data, start);
    }
    return value;
  }

  /// The next coordinate pair, offset by [origin] for a relative command.
  Offset point(Offset origin) => origin + Offset(number(), number());
}

/// One attribute glyph, stroked in the row's own ink.
///
/// Sized in the caller's points and scaled from the authored 20-unit box, so a
/// row can ask for 17 on a card and 15 on the compact one without a second
/// drawing. Hidden from screen readers: every caller prints the same fact in
/// words beside it, and announcing it twice is all this could add.
class SeatLayerSeatIcon extends StatelessWidget {
  /// Creates the glyph [iconKey] names.
  const SeatLayerSeatIcon({
    super.key,
    required this.iconKey,
    required this.color,
    this.size = SeatLayerSizeTokens.noteIconSize,
  });

  /// The runtime's own key for this attribute.
  final String iconKey;

  /// Ink for the stroke; the glyph carries no colour of its own.
  final Color color;

  /// Drawn box, in logical points.
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = seatLayerSeatIconPath(iconKey);
    if (path == null) return SizedBox.square(dimension: size);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _SeatIconPainter(
          path: path,
          fill: seatLayerSeatIconFillPath(iconKey),
          color: color,
          box: size,
        ),
      ),
    );
  }
}

class _SeatIconPainter extends CustomPainter {
  const _SeatIconPainter({
    required this.path,
    required this.fill,
    required this.color,
    required this.box,
  });

  final Path path;
  final Path? fill;
  final Color color;
  final double box;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / seatLayerSeatIconViewBox;
    canvas.save();
    canvas.scale(scale);
    final solid = fill;
    if (solid != null) {
      canvas.drawPath(solid, Paint()..color = color);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = seatLayerSeatIconStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeatIconPainter old) =>
      old.color != color ||
      old.path != path ||
      old.fill != fill ||
      old.box != box;
}
